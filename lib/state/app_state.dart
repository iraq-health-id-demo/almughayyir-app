import 'package:flutter/foundation.dart';

import '../data/repository.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/enums.dart';

/// حالة التطبيق: الأطباء والحجوزات.
///
/// حجم البيانات في عيادة خاصة صغير، لذلك تُحمَّل القائمتان كاملتين في الذاكرة
/// ويُعاد تحميلهما بعد كل عملية كتابة لضمان تطابق الشاشة مع قاعدة البيانات.
class AppState extends ChangeNotifier {
  AppState(this._repository);

  final Repository _repository;

  List<Doctor> _doctors = const [];
  List<Appointment> _appointments = const [];
  bool _loading = true;
  String? _error;

  List<Doctor> get doctors => _doctors;
  List<Appointment> get appointments => _appointments;
  bool get loading => _loading;
  String? get error => _error;

  // ------------------------------------------------------------------ تحميل

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _reload();
    } catch (e, st) {
      debugPrint('load failed: $e\n$st');
      _error = 'تعذّر تحميل البيانات.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _reload() async {
    final doctors = await _repository.getDoctors();
    final appointments = await _repository.getAppointments();
    _doctors = doctors;
    _appointments = appointments;
    _error = null;
    notifyListeners();
  }

  /// ينفّذ عملية كتابة ثم يعيد التحميل. يعيد `false` عند الفشل.
  Future<bool> _write(Future<void> Function() action) async {
    try {
      await action();
      await _reload();
      return true;
    } catch (e, st) {
      debugPrint('write failed: $e\n$st');
      return false;
    }
  }

  // ------------------------------------------------------------------ استعلام

  Doctor? doctorById(int id) {
    for (final doctor in _doctors) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }

  List<Appointment> appointmentsFor(
    int doctorId, {
    AgeGroup? ageGroup,
    Gender? gender,
  }) {
    return _appointments.where((a) {
      if (a.doctorId != doctorId) return false;
      if (ageGroup != null && a.ageGroup != ageGroup) return false;
      if (gender != null && a.gender != gender) return false;
      return true;
    }).toList();
  }

  /// عدد الحجوزات غير الملغاة.
  int activeCount(int doctorId, {AgeGroup? ageGroup, Gender? gender}) {
    return appointmentsFor(doctorId, ageGroup: ageGroup, gender: gender)
        .where((a) => !a.isCancelled)
        .length;
  }

  /// هل يوجد حجز نشط آخر لنفس الطبيب في نفس الدقيقة؟
  bool hasConflict(int doctorId, DateTime dateTime, {int? excludeId}) {
    return _appointments.any(
      (a) =>
          a.doctorId == doctorId &&
          !a.isCancelled &&
          a.id != excludeId &&
          a.dateTime.isAtSameMomentAs(dateTime),
    );
  }

  // ------------------------------------------------------------------ الأطباء

  Future<bool> addDoctor({required String name, required String specialty}) {
    return _write(() async {
      await _repository.insertDoctor(Doctor(name: name, specialty: specialty));
    });
  }

  Future<bool> updateDoctor(Doctor doctor) {
    return _write(() => _repository.updateDoctor(doctor));
  }

  Future<bool> deleteDoctor(int id) {
    return _write(() => _repository.deleteDoctor(id));
  }

  // ------------------------------------------------------------------ الحجوزات

  Future<bool> addAppointment(Appointment appointment) {
    return _write(() async {
      await _repository.insertAppointment(appointment);
    });
  }

  Future<bool> updateAppointment(Appointment appointment) {
    return _write(() => _repository.updateAppointment(appointment));
  }

  /// تغيير موعد الحجز (تقديم أو تأجيل).
  Future<bool> rescheduleAppointment(Appointment appointment, DateTime to) {
    return updateAppointment(appointment.copyWith(dateTime: to));
  }

  Future<bool> setAppointmentStatus(
    Appointment appointment,
    AppointmentStatus status,
  ) {
    return updateAppointment(appointment.copyWith(status: status));
  }

  Future<bool> deleteAppointment(int id) {
    return _write(() => _repository.deleteAppointment(id));
  }
}
