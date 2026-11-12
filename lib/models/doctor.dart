/// نموذج الطبيب.
class Doctor {
  const Doctor({this.id, required this.name, required this.specialty});

  final int? id;
  final String name;
  final String specialty;

  Doctor copyWith({int? id, String? name, String? specialty}) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'specialty': specialty,
      };

  factory Doctor.fromMap(Map<String, Object?> map) {
    return Doctor(
      id: map['id'] as int?,
      name: map['name'] as String,
      specialty: map['specialty'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Doctor &&
      other.id == id &&
      other.name == name &&
      other.specialty == specialty;

  @override
  int get hashCode => Object.hash(id, name, specialty);
}
