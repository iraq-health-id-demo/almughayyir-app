import 'package:flutter/material.dart';

/// الفئة العمرية للمريض.
enum AgeGroup { adult, child }

extension AgeGroupX on AgeGroup {
  String get label => this == AgeGroup.adult ? 'كبار' : 'صغار';

  IconData get icon =>
      this == AgeGroup.adult ? Icons.person_rounded : Icons.child_care_rounded;
}

/// جنس المريض.
enum Gender { male, female }

extension GenderX on Gender {
  String get label => this == Gender.male ? 'ذكور' : 'إناث';

  /// تسمية مفردة تُستخدم في النماذج.
  String get singularLabel => this == Gender.male ? 'ذكر' : 'أنثى';

  IconData get icon =>
      this == Gender.male ? Icons.male_rounded : Icons.female_rounded;
}

/// نوع الموعد: مراجعة أو عملية.
enum AppointmentKind { review, surgery }

extension AppointmentKindX on AppointmentKind {
  String get label => this == AppointmentKind.review ? 'مراجعة' : 'عملية';

  String get pluralLabel =>
      this == AppointmentKind.review ? 'مراجعات' : 'عمليات';

  IconData get icon => this == AppointmentKind.review
      ? Icons.event_note_rounded
      : Icons.healing_rounded;
}

/// حالة الحجز.
enum AppointmentStatus { active, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label => this == AppointmentStatus.active ? 'نشط' : 'ملغي';
}
