/// A logbook that forgets everything when the app closes.
///
/// Exists so the storage contract can be tested without a device, and so the
/// screens can be built against something before SQLite is wired in. Every
/// test that runs against this must also pass against the real one.
library;

import '../model/job.dart';
import '../model/work_day.dart';
import '../model/writer.dart';
import 'logbook.dart';

class InMemoryLogbook implements Logbook {
  final _writers = <int, Writer>{};
  final _jobs = <int, Job>{};
  final _days = <DateTime, WorkDay>{};

  int _nextWriterId = 1;
  int _nextJobId = 1;

  @override
  Future<int> addWriter(String name) async {
    final trimmed = _requireName(name);
    if (_writers.values.any((w) => _sameName(w.name, trimmed))) {
      throw DuplicateWriterException(trimmed);
    }

    final id = _nextWriterId++;
    _writers[id] = Writer(id: id, name: trimmed);
    return id;
  }

  @override
  Future<void> renameWriter(int id, String name) async {
    final trimmed = _requireName(name);
    _writers[id] = Writer(id: id, name: trimmed);
  }

  @override
  Future<void> deleteWriter(int id) async {
    if (_jobs.values.any((job) => job.writerId == id)) {
      throw WriterInUseException(id);
    }
    _writers.remove(id);
  }

  @override
  Future<List<Writer>> writers() async => _writers.values.toList();

  @override
  Future<int> saveJob(Job job) async {
    final id = job.id ?? _nextJobId++;
    _jobs[id] = Job(
      id: id,
      repairOrder: job.repairOrder,
      date: job.date,
      payType: job.payType,
      writerId: job.writerId,
      flaggedHours: job.flaggedHours,
      actualHours: job.actualHours,
    );
    return id;
  }

  @override
  Future<void> deleteJob(int id) async => _jobs.remove(id);

  @override
  Future<List<Job>> jobsBetween(DateTime from, DateTime to) async =>
      _jobs.values.where((job) => _within(job.date, from, to)).toList();

  @override
  Future<void> saveDay(WorkDay day) async {
    _days[_dayOf(day.date)] = WorkDay(
      date: _dayOf(day.date),
      scheduledHours: day.scheduledHours,
      clockedHours: day.clockedHours,
    );
  }

  @override
  Future<List<WorkDay>> daysBetween(DateTime from, DateTime to) async =>
      _days.values.where((day) => _within(day.date, from, to)).toList();
}

String _requireName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(name, 'name', 'a writer needs a name');
  }
  return trimmed;
}

bool _sameName(String a, String b) => a.toLowerCase() == b.toLowerCase();

bool _within(DateTime moment, DateTime from, DateTime to) {
  final day = _dayOf(moment);
  return !day.isBefore(_dayOf(from)) && !day.isAfter(_dayOf(to));
}

DateTime _dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);
