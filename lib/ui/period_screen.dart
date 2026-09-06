/// The two ratios, for the pay period containing today, with the weeks under
/// it. Undefined shows as a dash: a technician who was not scheduled has no
/// efficiency, and 0% would read as a bad week rather than as no week.
library;

import 'package:flutter/material.dart';

import '../data/logbook.dart';
import '../logic/pay_periods.dart';
import '../logic/period_summary.dart';
import '../logic/ratio_display.dart';
import '../model/job.dart';

class PeriodScreen extends StatefulWidget {
  const PeriodScreen({
    super.key,
    required this.logbook,
    required this.schedule,
    required this.anchor,
  });

  final Logbook logbook;
  final PaySchedule schedule;
  final DateTime anchor;

  @override
  State<PeriodScreen> createState() => _PeriodScreenState();
}

class _PeriodScreenState extends State<PeriodScreen> {
  PeriodSummary? _summary;
  List<PeriodSummary> _weeks = const [];
  Map<int, String> _writerNames = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final period = periodContaining(DateTime.now(),
        schedule: widget.schedule, anchor: widget.anchor);

    final jobs = await widget.logbook.jobsBetween(period.start, period.end);
    final days = await widget.logbook.daysBetween(period.start, period.end);
    final writers = await widget.logbook.writers();

    if (!mounted) return;
    setState(() {
      _summary = summarise(period: period, jobs: jobs, days: days);
      _weeks = [
        for (final week in weeksIn(period))
          summarise(period: week, jobs: jobs, days: days)
      ];
      _writerNames = {for (final writer in writers) writer.id: writer.name};
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    if (summary == null) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${_readable(summary.period.start)} — ${_readable(summary.period.end)}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              _Ratio(label: 'Vs schedule', value: summary.efficiency.asPercent),
              _Ratio(label: 'Vs hours worked', value: summary.proficiency.asPercent),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Vs hours worked blends job speed with time spent off jobs. It is '
            'not a measure of how fast the work itself went.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _Ratio(
            label: summary.jobsWithActualHours == summary.jobCount
                ? 'Job-time performance'
                : 'Job-time performance '
                    '(${summary.jobsWithActualHours} of ${summary.jobCount} jobs)',
            value: summary.jobTimePerformance.asPercent,
          ),
          const SizedBox(height: 16),
          _line('Flagged', summary.flaggedHours),
          _line('Scheduled', summary.scheduledHours),
          _line('Clocked', summary.clockedHours),
          if (summary.jobsMissingActualHours > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${summary.jobsMissingActualHours} of ${summary.jobCount} jobs '
                'have no actual time — job-time performance excludes them '
                'rather than counting them as zero',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const Divider(height: 32),
          Text('By pay type', style: Theme.of(context).textTheme.titleSmall),
          for (final entry in summary.flaggedByPayType.entries)
            _line(_payTypeName(entry.key), entry.value),
          const Divider(height: 32),
          Text('By writer', style: Theme.of(context).textTheme.titleSmall),
          if (summary.flaggedByWriter.isEmpty) const Text('Nothing yet'),
          for (final entry in summary.flaggedByWriter.entries)
            _line(_writerNames[entry.key] ?? 'Writer ${entry.key}', entry.value),
          const Divider(height: 32),
          Text('Weeks', style: Theme.of(context).textTheme.titleSmall),
          for (final week in _weeks)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                  '${_readable(week.period.start)} — ${_readable(week.period.end)}'),
              trailing: Text(
                  'eff ${week.efficiency.asPercent}  ·  prof ${week.proficiency.asPercent}'),
            ),
        ],
      ),
    );
  }

  Widget _line(String label, double hours) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(_plain(hours))],
        ),
      );
}

class _Ratio extends StatelessWidget {
  const _Ratio({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}

String _payTypeName(PayType type) => switch (type) {
      PayType.customer => 'Customer',
      PayType.warranty => 'Warranty',
      PayType.internal => 'Internal',
      PayType.recall => 'Recall',
    };

String _readable(DateTime day) => '${day.day}/${day.month}';

String _plain(double hours) =>
    hours == hours.roundToDouble() ? hours.toStringAsFixed(0) : '$hours';
