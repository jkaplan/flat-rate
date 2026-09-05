/// Rolling one pay period's jobs and days into the numbers a technician reads.
///
/// Pure: it takes what it needs and touches no storage.
library;

import 'pay_periods.dart';
import 'ratios.dart' as ratios;
import '../model/job.dart';
import '../model/work_day.dart';

class PeriodSummary {
  PeriodSummary({
    required this.period,
    required this.flaggedHours,
    required this.scheduledHours,
    required this.clockedHours,
    required this.jobCount,
    required this.jobsMissingActualHours,
    required this.flaggedByPayType,
    required this.flaggedByWriter,
  });

  final DateRange period;
  final double flaggedHours;
  final double scheduledHours;
  final double clockedHours;
  final int jobCount;

  /// How often the second number did not get written down. The instrument for
  /// the assumption this build proceeds without testing.
  final int jobsMissingActualHours;

  final Map<PayType, double> flaggedByPayType;
  final Map<int, double> flaggedByWriter;

  double? get efficiency =>
      ratios.efficiency(flagged: flaggedHours, available: scheduledHours);

  double? get proficiency =>
      ratios.proficiency(flagged: flaggedHours, clocked: clockedHours);
}

PeriodSummary summarise({
  required DateRange period,
  required List<Job> jobs,
  required List<WorkDay> days,
}) {
  final inPeriod = jobs.where((job) => period.contains(job.date)).toList();
  final daysInPeriod = days.where((day) => period.contains(day.date));

  final byPayType = {for (final type in PayType.values) type: 0.0};
  final byWriter = <int, double>{};

  for (final job in inPeriod) {
    byPayType[job.payType] = byPayType[job.payType]! + job.flaggedHours;
    byWriter[job.writerId] = (byWriter[job.writerId] ?? 0) + job.flaggedHours;
  }

  return PeriodSummary(
    period: period,
    flaggedHours: _sum(inPeriod.map((job) => job.flaggedHours)),
    scheduledHours: _sum(daysInPeriod.map((day) => day.scheduledHours)),
    clockedHours: _sum(daysInPeriod.map((day) => day.clockedHours ?? 0)),
    jobCount: inPeriod.length,
    jobsMissingActualHours: inPeriod.where((job) => !job.isComplete).length,
    flaggedByPayType: Map.unmodifiable(byPayType),
    flaggedByWriter: Map.unmodifiable(byWriter),
  );
}

double _sum(Iterable<double> values) =>
    values.fold(0.0, (total, value) => total + value);
