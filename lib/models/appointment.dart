import 'enums.dart';

/// نموذج الحجز (مراجعة أو عملية).
class Appointment {
  const Appointment({
    this.id,
    required this.doctorId,
    required this.patientName,
    required this.ageGroup,
    required this.gender,
    required this.kind,
    this.title = '',
    required this.dateTime,
    this.amount = 0,
    this.notes = '',
    this.status = AppointmentStatus.active,
    required this.createdAt,
  });

  final int? id;
  final int doctorId;
  final String patientName;
  final AgeGroup ageGroup;
  final Gender gender;
  final AppointmentKind kind;

  /// نوع المراجعة أو العملية (نص حر، مثل: «استئصال الزائدة»).
  final String title;
  final DateTime dateTime;

  /// المبلغ المترتب على الحجز.
  final double amount;
  final String notes;
  final AppointmentStatus status;
  final DateTime createdAt;

  bool get isCancelled => status == AppointmentStatus.cancelled;

  Appointment copyWith({
    int? id,
    int? doctorId,
    String? patientName,
    AgeGroup? ageGroup,
    Gender? gender,
    AppointmentKind? kind,
    String? title,
    DateTime? dateTime,
    double? amount,
    String? notes,
    AppointmentStatus? status,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      ageGroup: ageGroup ?? this.ageGroup,
      gender: gender ?? this.gender,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'doctor_id': doctorId,
        'patient_name': patientName,
        'age_group': ageGroup.name,
        'gender': gender.name,
        'kind': kind.name,
        'title': title,
        'date_time': dateTime.millisecondsSinceEpoch,
        'amount': amount,
        'notes': notes,
        'status': status.name,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Appointment.fromMap(Map<String, Object?> map) {
    return Appointment(
      id: map['id'] as int?,
      doctorId: map['doctor_id'] as int,
      patientName: map['patient_name'] as String,
      ageGroup: AgeGroup.values.asNameMap()[map['age_group']] ?? AgeGroup.adult,
      gender: Gender.values.asNameMap()[map['gender']] ?? Gender.male,
      kind: AppointmentKind.values.asNameMap()[map['kind']] ??
          AppointmentKind.review,
      title: (map['title'] as String?) ?? '',
      dateTime:
          DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      notes: (map['notes'] as String?) ?? '',
      status: AppointmentStatus.values.asNameMap()[map['status']] ??
          AppointmentStatus.active,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int?) ?? 0,
      ),
    );
  }
}
