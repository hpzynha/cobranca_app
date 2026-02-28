import 'package:app_cobranca/features/auth/domain/entities/student.dart';

class StudentModel {
  const StudentModel({
    required this.id,
    required this.name,
    required this.monthlyFeeCents,
    required this.dueDay,
    this.photoUrl,
  });

  final String id;
  final String name;
  final int monthlyFeeCents;
  final int dueDay;
  final String? photoUrl;

  factory StudentModel.fromSupabaseMap(Map<String, dynamic> map) {
    return StudentModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      monthlyFeeCents: (map['monthly_fee_cents'] as num?)?.toInt() ?? 0,
      dueDay: (map['due_day'] as num?)?.toInt() ?? 1,
      photoUrl: map['photo_url'] as String?,
    );
  }

  Student toEntity() {
    return Student(
      id: id,
      name: name,
      monthlyFeeCents: monthlyFeeCents,
      dueDay: dueDay,
      photoUrl: photoUrl,
    );
  }
}
