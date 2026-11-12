import '../models/appointment.dart';
import '../models/doctor.dart';
import 'app_database.dart';

/// طبقة الوصول إلى البيانات.
class Repository {
  Repository(this._appDb);

  final AppDatabase _appDb;

  // ---------------------------------------------------------------- الأطباء

  Future<List<Doctor>> getDoctors() async {
    final db = await _appDb.database;
    final rows = await db.query('doctors', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Doctor.fromMap).toList();
  }

  Future<int> insertDoctor(Doctor doctor) async {
    final db = await _appDb.database;
    return db.insert('doctors', doctor.toMap());
  }

  Future<void> updateDoctor(Doctor doctor) async {
    final db = await _appDb.database;
    await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  /// يحذف الطبيب وجميع حجوزاته (حذف متسلسل).
  Future<void> deleteDoctor(int id) async {
    final db = await _appDb.database;
    await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------- الحجوزات

  Future<List<Appointment>> getAppointments() async {
    final db = await _appDb.database;
    final rows = await db.query('appointments', orderBy: 'date_time ASC');
    return rows.map(Appointment.fromMap).toList();
  }

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await _appDb.database;
    return db.insert('appointments', appointment.toMap());
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final db = await _appDb.database;
    await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<void> deleteAppointment(int id) async {
    final db = await _appDb.database;
    await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }
}
