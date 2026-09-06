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
    required this.matchedFlaggedHours,
    required this.matchedActualHours,
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

  /// Flagged hours from jobs that also have actual hours recorded — the
  /// matched set that [jobTimePerformance] divides. Excludes any job still
  /// missing its second number, rather than treating that job as a zero.
  final double matchedFlaggedHours;

  /// Actual hours from the same matched set.
  final double matchedActualHours;

  final Map<PayType, double> flaggedByPayType;
  final Map<int, double> flaggedByWriter;

  int get jobsWithActualHours => jobCount - jobsMissingActualHours;

  /// Recorded output against the schedule: did the shop hand out enough work
  /// to fill the hours it scheduled? Answers a dispatch question, not a job
  /// speed question.
  double? get efficiency =>
      ratios.efficiency(flagged: flaggedHours, available: scheduledHours);

  /// Recorded output against every hour clocked, on jobs or off them. This is
  /// a utilization number — it blends job speed with time spent outside jobs
  /// — and it is identical to [efficiency] whenever scheduled and clocked
  /// hours match, because both are then the same denominator applied to the
  /// same numerator. It does not measure how a technician performs on the
  /// jobs they were actually given; [jobTimePerformance] does that.
  double? get proficiency =>
      ratios.proficiency(flagged: flaggedHours, clocked: clockedHours);

  /// Flagged hours against actual job hours, for jobs where actual hours were
  /// recorded — the only measure of job speed itself. Null when no job in the
  /// period has a second number to compare against, and never treats a
  /// missing actual time as zero. Read alongside [jobsWithActualHours]: a
  /// performance number built from one job out of twelve is not the same
  /// claim as one built from twelve out of twelve.
  double? get jobTimePerformance =>
      ratios.proficiency(flagged: matchedFlaggedHours, clocked: matchedActualHours);
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

  final matched = inPeriod.where((job) => job.isComplete);

  return PeriodSummary(
    period: period,
    flaggedHours: _sum(inPeriod.map((job) => job.flaggedHours)),
    scheduledHours: _sum(daysInPeriod.map((day) => day.scheduledHours)),
    clockedHours: _sum(daysInPeriod.map((day) => day.clockedHours ?? 0)),
    jobCount: inPeriod.length,
    jobsMissingActualHours: inPeriod.where((job) => !job.isComplete).length,
    matchedFlaggedHours: _sum(matched.map((job) => job.flaggedHours)),
    matchedActualHours: _sum(matched.map((job) => job.actualHours!)),
    flaggedByPayType: Map.unmodifiable(byPayType),
    flaggedByWriter: Map.unmodifiable(byWriter),
  );
}

double _sum(Iterable<double> values) =>
    values.fold(0.0, (total, value) => total + value);
