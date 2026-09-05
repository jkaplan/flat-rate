import 'package:flutter_test/flutter_test.dart';
import 'package:flat_rate/data/in_memory_logbook.dart';
import 'package:flat_rate/data/logbook.dart';
import 'package:flat_rate/model/job.dart';
import 'package:flat_rate/model/work_day.dart';
import 'package:flat_rate/model/writer.dart';

late Logbook logbook;

Job job({String ro = '1', int day = 1, int writerId = 1, double flagged = 1.0}) => Job(
      repairOrder: ro,
      date: DateTime(2026, 9, day),
      payType: PayType.customer,
      writerId: writerId,
      flaggedHours: flagged,
      actualHours: 1.0,
    );

void main() {
  setUp(() => logbook = InMemoryLogbook());

  group('writers are rows, not typed names', () {
    test('a saved writer comes back with an id', () async {
      final id = await logbook.addWriter('Dave Ruiz');
      final writers = await logbook.writers();
      expect(writers, hasLength(1));
      expect(writers.single, isA<Writer>().having((w) => w.id, 'id', id));
      expect(writers.single.name, equals('Dave Ruiz'));
    });

    test('the same name twice is the same writer', () {
      // Otherwise the grouping the whole field exists for quietly splits.
      expect(() async {
        await logbook.addWriter('Dave Ruiz');
        await logbook.addWriter('dave ruiz');
      }, throwsA(isA<DuplicateWriterException>()));
    });

    test('a writer can be renamed without their history moving', () async {
      final id = await logbook.addWriter('Dave');
      await logbook.saveJob(job(writerId: id));
      await logbook.renameWriter(id, 'Dave Ruiz');

      final jobs = await logbook.jobsBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 7));
      expect(jobs.single.writerId, equals(id));
      expect((await logbook.writers()).single.name, equals('Dave Ruiz'));
    });

    test('an empty writer name is refused', () {
      expect(() => logbook.addWriter('  '), throwsArgumentError);
    });
  });

  group('jobs come back by date range, because that is how they are read', () {
    test('only jobs inside the range', () async {
      await logbook.saveJob(job(ro: '1', day: 3));
      await logbook.saveJob(job(ro: '2', day: 9));

      final jobs = await logbook.jobsBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 7));
      expect(jobs.map((j) => j.repairOrder), equals(['1']));
    });

    test('the range includes both of its end days', () async {
      await logbook.saveJob(job(ro: 'first', day: 1));
      await logbook.saveJob(job(ro: 'last', day: 7));

      final jobs = await logbook.jobsBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 7));
      expect(jobs, hasLength(2));
    });

    test('a saved job gets an id, and keeps its values', () async {
      final id = await logbook.saveJob(job(ro: '00412', flagged: 0.3));
      final jobs = await logbook.jobsBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 7));
      expect(jobs.single.id, equals(id));
      expect(jobs.single.repairOrder, equals('00412'));
      expect(jobs.single.flaggedHours, equals(0.3));
    });

    test('two jobs can share a repair order, because they do', () async {
      // One RO often carries several paid operations.
      await logbook.saveJob(job(ro: '184922', flagged: 1.2));
      await logbook.saveJob(job(ro: '184922', flagged: 0.4));
      final jobs = await logbook.jobsBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 7));
      expect(jobs, hasLength(2));
    });
  });

  group('a day is recorded once, and correcting it replaces it', () {
    test('saving the same date twice leaves one day, not two', () async {
      await logbook.saveDay(WorkDay(
          date: DateTime(2026, 9, 1), scheduledHours: 8.0, clockedHours: 8.0));
      await logbook.saveDay(WorkDay(
          date: DateTime(2026, 9, 1), scheduledHours: 8.0, clockedHours: 9.5));

      final days = await logbook.daysBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 7));
      expect(days, hasLength(1));
      expect(days.single.clockedHours, equals(9.5));
    });

    test('a day entered with a time on it still lands on its date', () async {
      await logbook.saveDay(WorkDay(
          date: DateTime(2026, 9, 3, 17, 45),
          scheduledHours: 8.0,
          clockedHours: 8.0));
      final days = await logbook.daysBetween(DateTime(2026, 9, 3), DateTime(2026, 9, 3));
      expect(days, hasLength(1));
    });
  });

  group('deleting', () {
    test('a deleted job is gone', () async {
      final id = await logbook.saveJob(job());
      await logbook.deleteJob(id);
      expect(await logbook.jobsBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 7)),
          isEmpty);
    });

    test('a writer with jobs against them cannot be deleted', () async {
      // Deleting would orphan history, which is the one asset here.
      final id = await logbook.addWriter('Dave');
      await logbook.saveJob(job(writerId: id));
      expect(() => logbook.deleteWriter(id), throwsA(isA<WriterInUseException>()));
    });
  });
}
