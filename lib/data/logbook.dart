/// What storage must be able to do. The only place the rest of the app talks
/// to a database, and it never mentions one.
library;

import '../model/job.dart';
import '../model/work_day.dart';
import '../model/writer.dart';

class DuplicateWriterException implements Exception {
  DuplicateWriterException(this.name);
  final String name;

  @override
  String toString() => 'a writer called $name already exists';
}

class WriterInUseException implements Exception {
  WriterInUseException(this.id);
  final int id;

  @override
  String toString() => 'writer $id has jobs against them and cannot be deleted';
}

abstract interface class Logbook {
  Future<int> addWriter(String name);
  Future<void> renameWriter(int id, String name);
  Future<void> deleteWriter(int id);
  Future<List<Writer>> writers();

  Future<int> saveJob(Job job);
  Future<void> deleteJob(int id);
  Future<List<Job>> jobsBetween(DateTime from, DateTime to);

  /// Replaces any day already recorded for the same date.
  Future<void> saveDay(WorkDay day);
  Future<List<WorkDay>> daysBetween(DateTime from, DateTime to);
}
