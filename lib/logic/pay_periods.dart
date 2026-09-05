/// Bucketing days into pay periods, and pay periods into whole weeks.
///
/// Dates are handled as whole days. Anything with a time on it is either
/// truncated (a job entered at 4pm belongs to that day) or refused (an anchor
/// with a time would drift every period).
library;

enum PaySchedule {
  weekly(7),
  fortnightly(14);

  const PaySchedule(this.lengthInDays);

  final int lengthInDays;
}

class DateRange {
  DateRange(this.start, this.end);

  /// Both ends are inside the range.
  final DateTime start;
  final DateTime end;

  int get lengthInDays => _daysBetween(start, end) + 1;

  bool contains(DateTime moment) {
    final day = _dayOf(moment);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  @override
  String toString() => 'DateRange($start..$end)';
}

DateRange periodContaining(
  DateTime day, {
  required PaySchedule schedule,
  required DateTime anchor,
}) {
  if (anchor != _dayOf(anchor)) {
    throw ArgumentError.value(
        anchor, 'anchor', 'must be a whole day with no time of day');
  }

  final length = schedule.lengthInDays;
  final offset = _daysBetween(anchor, _dayOf(day));

  // Floor division, so that work dated before the anchor lands in the period
  // before it rather than in the one starting on it.
  final index = (offset / length).floor();
  final start = _addDays(anchor, index * length);

  return DateRange(start, _addDays(start, length - 1));
}

/// Whole weeks inside [period], in order. Never a partial week: the wage-floor
/// check that arrives later is defined over whole weeks, and a split one would
/// make it wrong.
List<DateRange> weeksIn(DateRange period) {
  if (period.lengthInDays % 7 != 0) {
    throw StateError(
        'a pay period of ${period.lengthInDays} days does not divide into weeks');
  }

  return [
    for (var offset = 0; offset < period.lengthInDays; offset += 7)
      DateRange(_addDays(period.start, offset), _addDays(period.start, offset + 6)),
  ];
}

DateTime _dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Adding to the date parts rather than to a Duration, so that a day the
/// clocks change is still one day.
DateTime _addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);

int _daysBetween(DateTime from, DateTime to) =>
    to.difference(from).inHours ~/ 24;
