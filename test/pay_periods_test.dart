import 'package:test/test.dart';
import 'package:flat_rate/logic/pay_periods.dart';

// Monday 1 September 2026 is the anchor in most of these — the first day of
// the first pay period the technician tells us about.
final anchor = DateTime(2026, 9, 1);

void main() {
  group('a weekly period is seven days, ending on the seventh', () {
    test('the anchor day falls in the first period', () {
      final period = periodContaining(DateTime(2026, 9, 1),
          schedule: PaySchedule.weekly, anchor: anchor);
      expect(period.start, equals(DateTime(2026, 9, 1)));
      expect(period.end, equals(DateTime(2026, 9, 7)));
    });

    test('the last day of a period is inside it, not the next one', () {
      final period = periodContaining(DateTime(2026, 9, 7),
          schedule: PaySchedule.weekly, anchor: anchor);
      expect(period.start, equals(DateTime(2026, 9, 1)));
    });

    test('the next day starts the next period', () {
      final period = periodContaining(DateTime(2026, 9, 8),
          schedule: PaySchedule.weekly, anchor: anchor);
      expect(period.start, equals(DateTime(2026, 9, 8)));
      expect(period.end, equals(DateTime(2026, 9, 14)));
    });
  });

  group('a fortnightly period is fourteen days', () {
    test('day fourteen is still the first period', () {
      final period = periodContaining(DateTime(2026, 9, 14),
          schedule: PaySchedule.fortnightly, anchor: anchor);
      expect(period.start, equals(DateTime(2026, 9, 1)));
      expect(period.end, equals(DateTime(2026, 9, 14)));
    });

    test('day fifteen is the second', () {
      final period = periodContaining(DateTime(2026, 9, 15),
          schedule: PaySchedule.fortnightly, anchor: anchor);
      expect(period.start, equals(DateTime(2026, 9, 15)));
    });
  });

  group('work dated before the anchor still lands somewhere', () {
    // A technician who enters last week's jobs after setting the app up.
    test('the day before the anchor is the period before it', () {
      final period = periodContaining(DateTime(2026, 8, 31),
          schedule: PaySchedule.weekly, anchor: anchor);
      expect(period.start, equals(DateTime(2026, 8, 25)));
      expect(period.end, equals(DateTime(2026, 8, 31)));
    });
  });

  group('the clocks changing does not move a pay period', () {
    // US daylight saving ends 1 November 2026, which falls inside the week of
    // 27 October. That week is still seven days, not seven days and an hour.
    test('a week across the change is still seven days', () {
      final period = periodContaining(DateTime(2026, 11, 2),
          schedule: PaySchedule.weekly, anchor: DateTime(2026, 10, 27));
      expect(period.start, equals(DateTime(2026, 10, 27)));
      expect(period.end, equals(DateTime(2026, 11, 2)));
      expect(period.lengthInDays, equals(7));
    });

    test('the day after that week starts a new period', () {
      final period = periodContaining(DateTime(2026, 11, 3),
          schedule: PaySchedule.weekly, anchor: DateTime(2026, 10, 27));
      expect(period.start, equals(DateTime(2026, 11, 3)));
    });
  });

  group('weeks nest inside pay periods without being cut', () {
    test('a weekly period contains exactly one week', () {
      final period = periodContaining(DateTime(2026, 9, 3),
          schedule: PaySchedule.weekly, anchor: anchor);
      expect(weeksIn(period), hasLength(1));
    });

    test('a fortnightly period contains exactly two whole weeks', () {
      final period = periodContaining(DateTime(2026, 9, 3),
          schedule: PaySchedule.fortnightly, anchor: anchor);
      final weeks = weeksIn(period);
      expect(weeks, hasLength(2));
      expect(weeks.first.start, equals(DateTime(2026, 9, 1)));
      expect(weeks.first.end, equals(DateTime(2026, 9, 7)));
      expect(weeks.last.start, equals(DateTime(2026, 9, 8)));
      expect(weeks.last.end, equals(DateTime(2026, 9, 14)));
    });

    test('no week is ever split by a pay period boundary', () {
      // The invariant that lets the wage-floor check be added later without
      // reshaping anything. It cannot fail while only weekly and fortnightly
      // exist; it is here so that adding semi-monthly trips a test rather
      // than shipping a wrong number.
      for (final schedule in PaySchedule.values) {
        final period =
            periodContaining(DateTime(2026, 9, 3), schedule: schedule, anchor: anchor);
        for (final week in weeksIn(period)) {
          expect(week.lengthInDays, equals(7),
              reason: '$schedule produced a partial week');
        }
      }
    });
  });

  group('a period knows what it contains', () {
    test('its own days, and not the day after', () {
      final period = periodContaining(DateTime(2026, 9, 3),
          schedule: PaySchedule.weekly, anchor: anchor);
      expect(period.contains(DateTime(2026, 9, 1)), isTrue);
      expect(period.contains(DateTime(2026, 9, 7)), isTrue);
      expect(period.contains(DateTime(2026, 9, 8)), isFalse);
      expect(period.contains(DateTime(2026, 8, 31)), isFalse);
    });

    test('a time of day inside a day still counts as that day', () {
      // Jobs get entered at 4pm. That must not fall out of the period.
      final period = periodContaining(DateTime(2026, 9, 3),
          schedule: PaySchedule.weekly, anchor: anchor);
      expect(period.contains(DateTime(2026, 9, 7, 16, 30)), isTrue);
    });
  });

  group('bad input throws rather than bucketing wrongly', () {
    test('an anchor with a time of day is refused', () {
      // An anchor at 09:00 would drift every period. Refuse it at the door.
      expect(
        () => periodContaining(DateTime(2026, 9, 3),
            schedule: PaySchedule.weekly, anchor: DateTime(2026, 9, 1, 9)),
        throwsArgumentError,
      );
    });
  });
}
