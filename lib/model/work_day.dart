/// One day at the shop: what was promised, and what was actually spent there.
library;

class WorkDay {
  WorkDay({
    required this.date,
    required this.scheduledHours,
    required this.clockedHours,
  }) {
    _guardHours(scheduledHours, 'scheduledHours');
    if (clockedHours != null) _guardHours(clockedHours!, 'clockedHours');
  }

  final DateTime date;

  /// What the rota said. The denominator of efficiency.
  final double scheduledHours;

  /// What the clock said. The denominator of proficiency, and the figure the
  /// wage-floor check will need if it is ever built.
  final double? clockedHours;
}

void _guardHours(double hours, String name) {
  if (hours.isNaN || hours.isInfinite) {
    throw ArgumentError.value(hours, name, 'must be a real number of hours');
  }
  if (hours < 0) {
    throw ArgumentError.value(hours, name, 'hours cannot be negative');
  }
}
