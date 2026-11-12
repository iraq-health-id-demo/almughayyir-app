import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// فتح قاعدة البيانات المحلية (SQLite) وإنشاء الجداول.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'mughayyir.db';
  static const _version = 1;

  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, _fileName),
      version: _version,
      onConfigure: (db) async {
        // لتفعيل الحذف المتسلسل (حذف حجوزات الطبيب عند حذفه).
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialty TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctor_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        age_group TEXT NOT NULL,
        gender TEXT NOT NULL,
        kind TEXT NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        date_time INTEGER NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        notes TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'active',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_appointments_doctor_date '
      'ON appointments (doctor_id, date_time)',
    );
  }
}
