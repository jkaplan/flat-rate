import 'package:test/test.dart';
import 'package:flat_rate/logic/pay_periods.dart';
import 'package:flat_rate/logic/period_summary.dart';
import 'package:flat_rate/model/job.dart';
import 'package:flat_rate/model/work_day.dart';

final period = DateRange(DateTime(2026, 9, 1), DateTime(2026, 9, 7));

Job job({
  String ro = '1',
  int day = 1,
  PayType payType = PayType.customer,
  int writerId = 1,
  double flagged = 1.0,
  double? actual = 1.0,
}) =>
    Job(
      repairOrder: ro,
      date: DateTime(2026, 9, day),
      payType: payType,
      writerId: writerId,
      flaggedHours: flagged,
      actualHours: actual,
    );

WorkDay workDay({int day = 1, double scheduled = 8.0, double? clocked = 8.0}) =>
    WorkDay(
      date: DateTime(2026, 9, day),
      scheduledHours: scheduled,
      clockedHours: clocked,
    );

void main() {
  group('the two ratios come out of the period, not out of a single job', () {
    test('a good week', () {
      final summary = summarise(
        period: period,
        jobs: [job(flagged: 10.0), job(ro: '2', day: 2, flagged: 12.0)],
        days: [workDay(), workDay(day: 2)],
      );
      expect(summary.flaggedHours, equals(22.0));
      expect(summary.scheduledHours, equals(16.0));
      expect(summary.clockedHours, equals(16.0));
      expect(summary.efficiency, closeTo(1.375, 1e-9));
      expect(summary.proficiency, closeTo(1.375, 1e-9));
    });

    test('the product argument, in one summary', () {
      // Scheduled 8, stayed 10, flagged 9. Busy shop, slow job.
      final summary = summarise(
        period: period,
        jobs: [job(flagged: 9.0)],
        days: [workDay(scheduled: 8.0, clocked: 10.0)],
      );
      expect(summary.efficiency, greaterThan(1.0));
      expect(summary.proficiency, lessThan(1.0));
    });
  });

  group('nothing outside the period is counted', () {
    test('a job dated after the period is ignored', () {
      final summary = summarise(
        period: period,
        jobs: [job(flagged: 5.0), job(ro: '2', day: 8, flagged: 100.0)],
        days: [workDay()],
      );
      expect(summary.flaggedHours, equals(5.0));
    });

    test('a day dated before the period is ignored', () {
      final summary = summarise(
        period: DateRange(DateTime(2026, 9, 8), DateTime(2026, 9, 14)),
        jobs: const [],
        days: [workDay(day: 1)],
      );
      expect(summary.scheduledHours, equals(0.0));
    });
  });

  group('missing actual time is reported, not absorbed', () {
    test('a job with no actual hours still counts its flagged hours', () {
      final summary = summarise(
        period: period,
        jobs: [job(flagged: 4.0, actual: null)],
        days: [workDay()],
      );
      expect(summary.flaggedHours, equals(4.0));
    });

    test('the summary says how many jobs are missing their second number', () {
      // The instrument for the assumption this build skipped. If these come
      // back high in real use, the paper week's prediction was right.
      final summary = summarise(
        period: period,
        jobs: [
          job(flagged: 4.0, actual: 3.0),
          job(ro: '2', flagged: 2.0, actual: null),
          job(ro: '3', flagged: 1.0, actual: null),
        ],
        days: [workDay()],
      );
      expect(summary.jobCount, equals(3));
      expect(summary.jobsMissingActualHours, equals(2));
    });

    test('a day with no clocked hours makes proficiency undefined, not wrong', () {
      final summary = summarise(
        period: period,
        jobs: [job(flagged: 4.0)],
        days: [workDay(scheduled: 8.0, clocked: null)],
      );
      expect(summary.clockedHours, equals(0.0));
      expect(summary.proficiency, isNull);
      expect(summary.efficiency, closeTo(0.5, 1e-9));
    });
  });

  group('a period with nothing in it is empty, not zero', () {
    test('no jobs and no days means both ratios are undefined', () {
      final summary = summarise(period: period, jobs: const [], days: const []);
      expect(summary.efficiency, isNull);
      expect(summary.proficiency, isNull);
      expect(summary.flaggedHours, equals(0.0));
    });
  });

  group('splits that make a bad week readable', () {
    test('flagged hours split by pay type', () {
      final summary = summarise(
        period: period,
        jobs: [
          job(flagged: 6.0),
          job(ro: '2', payType: PayType.warranty, flagged: 3.0),
          job(ro: '3', payType: PayType.recall, flagged: 1.0),
        ],
        days: [workDay()],
      );
      expect(summary.flaggedByPayType[PayType.customer], equals(6.0));
      expect(summary.flaggedByPayType[PayType.warranty], equals(3.0));
      expect(summary.flaggedByPayType[PayType.recall], equals(1.0));
      expect(summary.flaggedByPayType[PayType.internal], equals(0.0));
    });

    test('flagged hours split by writer — the field no competitor has', () {
      final summary = summarise(
        period: period,
        jobs: [
          job(writerId: 1, flagged: 8.0),
          job(ro: '2', writerId: 2, flagged: 2.0),
          job(ro: '3', writerId: 1, flagged: 4.0),
        ],
        days: [workDay()],
      );
      expect(summary.flaggedByWriter[1], equals(12.0));
      expect(summary.flaggedByWriter[2], equals(2.0));
    });

    test('every pay type appears even when unused, so a zero is visible', () {
      final summary = summarise(
        period: period,
        jobs: [job(flagged: 1.0)],
        days: [workDay()],
      );
      expect(summary.flaggedByPayType.keys, containsAll(PayType.values));
    });
  });
}
