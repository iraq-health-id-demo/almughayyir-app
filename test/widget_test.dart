import 'package:flutter_test/flutter_test.dart';
import 'package:mughayyir/core/parsers.dart';
import 'package:mughayyir/models/appointment.dart';
import 'package:mughayyir/models/doctor.dart';
import 'package:mughayyir/models/enums.dart';

void main() {
  group('parseAmount', () {
    test('parses latin digits', () {
      expect(parseAmount('25000'), 25000);
      expect(parseAmount('12.5'), 12.5);
    });

    test('parses arabic-indic digits and separators', () {
      expect(parseAmount('٢٥٠٠٠'), 25000);
      expect(parseAmount('١٢٫٥'), 12.5);
      expect(parseAmount('1,500,000'), 1500000);
    });

    test('rejects invalid input', () {
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('-5'), isNull);
      expect(parseAmount(''), isNull);
    });
  });

  group('models', () {
    test('Doctor map round trip', () {
      const doctor = Doctor(id: 3, name: 'د. أحمد', specialty: 'جراحة عامة');
      expect(Doctor.fromMap(doctor.toMap()), doctor);
    });

    test('Appointment map round trip', () {
      final appointment = Appointment(
        id: 7,
        doctorId: 3,
        patientName: 'علي حسن',
        ageGroup: AgeGroup.child,
        gender: Gender.female,
        kind: AppointmentKind.surgery,
        title: 'استئصال اللوزتين',
        dateTime: DateTime(2026, 12, 1, 10, 30),
        amount: 350000,
        notes: 'صيام قبل العملية',
        status: AppointmentStatus.cancelled,
        createdAt: DateTime(2026, 11, 12, 9),
      );

      final copy = Appointment.fromMap(appointment.toMap());
      expect(copy.id, 7);
      expect(copy.doctorId, 3);
      expect(copy.patientName, 'علي حسن');
      expect(copy.ageGroup, AgeGroup.child);
      expect(copy.gender, Gender.female);
      expect(copy.kind, AppointmentKind.surgery);
      expect(copy.title, 'استئصال اللوزتين');
      expect(copy.dateTime, DateTime(2026, 12, 1, 10, 30));
      expect(copy.amount, 350000);
      expect(copy.status, AppointmentStatus.cancelled);
      expect(copy.isCancelled, isTrue);
    });

    test('unknown enum values fall back to defaults', () {
      final map = <String, Object?>{
        'id': 1,
        'doctor_id': 1,
        'patient_name': 'x',
        'age_group': '???',
        'gender': '???',
        'kind': '???',
        'date_time': 0,
        'status': '???',
      };
      final a = Appointment.fromMap(map);
      expect(a.ageGroup, AgeGroup.adult);
      expect(a.gender, Gender.male);
      expect(a.kind, AppointmentKind.review);
      expect(a.status, AppointmentStatus.active);
    });
  });
}
