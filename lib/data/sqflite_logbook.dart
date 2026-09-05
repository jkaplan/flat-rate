/// The real logbook: a SQLite file on the device, and nothing anywhere else.
library;

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../model/job.dart';
import '../model/work_day.dart';
import '../model/writer.dart';
import 'logbook.dart';

class SqfliteLogbook implements Logbook {
  SqfliteLogbook._(this._db);

  final Database _db;

  static Future<SqfliteLogbook> open({String fileName = 'flat_rate.db'}) async {
    final path = p.join(await getDatabasesPath(), fileName);
    final db = await openDatabase(path, version: 1, onCreate: _create);
    return SqfliteLogbook._(db);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE writers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_key TEXT NOT NULL UNIQUE
      )''');

    // flagged and actual are REAL. Flag times are 0.3, 1.7, 4.5 — the 2022
    // app stored them as integers and could not record a real one.
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repair_order TEXT NOT NULL,
        day TEXT NOT NULL,
        pay_type TEXT NOT NULL,
        writer_id INTEGER NOT NULL REFERENCES writers(id),
        flagged REAL NOT NULL,
        actual REAL
      )''');

    await db.execute('''
      CREATE TABLE days (
        day TEXT PRIMARY KEY,
        scheduled REAL NOT NULL,
        clocked REAL
      )''');

    await db.execute('CREATE INDEX jobs_by_day ON jobs(day)');
  }

  @override
  Future<int> addWriter(String name) async {
    final trimmed = _requireName(name);
    final clash = await _db.query('writers',
        where: 'name_key = ?', whereArgs: [trimmed.toLowerCase()]);
    if (clash.isNotEmpty) throw DuplicateWriterException(trimmed);

    return _db.insert(
        'writers', {'name': trimmed, 'name_key': trimmed.toLowerCase()});
  }

  @override
  Future<void> renameWriter(int id, String name) async {
    final trimmed = _requireName(name);
    await _db.update(
      'writers',
      {'name': trimmed, 'name_key': trimmed.toLowerCase()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteWriter(int id) async {
    final held =
        await _db.query('jobs', where: 'writer_id = ?', whereArgs: [id], limit: 1);
    if (held.isNotEmpty) throw WriterInUseException(id);
    await _db.delete('writers', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Writer>> writers() async {
    final rows = await _db.query('writers', orderBy: 'name COLLATE NOCASE');
    return [
      for (final row in rows)
        Writer(id: row['id']! as int, name: row['name']! as String)
    ];
  }

  @override
  Future<int> saveJob(Job job) async {
    final values = {
      'repair_order': job.repairOrder,
      'day': _key(job.date),
      'pay_type': job.payType.name,
      'writer_id': job.writerId,
      'flagged': job.flaggedHours,
      'actual': job.actualHours,
    };

    if (job.id == null) return _db.insert('jobs', values);

    await _db.update('jobs', values, where: 'id = ?', whereArgs: [job.id]);
    return job.id!;
  }

  @override
  Future<void> deleteJob(int id) async =>
      _db.delete('jobs', where: 'id = ?', whereArgs: [id]);

  @override
  Future<List<Job>> jobsBetween(DateTime from, DateTime to) async {
    final rows = await _db.query(
      'jobs',
      where: 'day BETWEEN ? AND ?',
      whereArgs: [_key(from), _key(to)],
      orderBy: 'day, id',
    );

    return [
      for (final row in rows)
        Job(
          id: row['id']! as int,
          repairOrder: row['repair_order']! as String,
          date: DateTime.parse(row['day']! as String),
          payType: PayType.values.byName(row['pay_type']! as String),
          writerId: row['writer_id']! as int,
          flaggedHours: (row['flagged']! as num).toDouble(),
          actualHours: (row['actual'] as num?)?.toDouble(),
        )
    ];
  }

  @override
  Future<void> saveDay(WorkDay day) async {
    await _db.insert(
      'days',
      {
        'day': _key(day.date),
        'scheduled': day.scheduledHours,
        'clocked': day.clockedHours,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<WorkDay>> daysBetween(DateTime from, DateTime to) async {
    final rows = await _db.query(
      'days',
      where: 'day BETWEEN ? AND ?',
      whereArgs: [_key(from), _key(to)],
      orderBy: 'day',
    );

    return [
      for (final row in rows)
        WorkDay(
          date: DateTime.parse(row['day']! as String),
          scheduledHours: (row['scheduled']! as num).toDouble(),
          clockedHours: (row['clocked'] as num?)?.toDouble(),
        )
    ];
  }
}

/// Dates are stored as yyyy-MM-dd text so that BETWEEN compares days rather
/// than instants, and no time zone can move a job into another week.
String _key(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

String _requireName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(name, 'name', 'a writer needs a name');
  }
  return trimmed;
}
