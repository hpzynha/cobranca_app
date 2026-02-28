import 'package:app_cobranca/features/auth/domain/entities/student.dart';

class StudentModel {
  const StudentModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.monthlyFeeCents,
    required this.dueDay,
    required this.photoUrl,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final int monthlyFeeCents;
  final int dueDay;
  final String? photoUrl;
  final DateTime createdAt;

  factory StudentModel.fromSupabase(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      name: map['name'] as String,
      monthlyFeeCents: map['monthly_fee_cents'] as int,
      dueDay: map['due_day'] as int,
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Student toEntity() {
    return Student(
      id: id,
      ownerId: ownerId,
      name: name,
      monthlyFeeCents: monthlyFeeCents,
      dueDay: dueDay,
      photoUrl: photoUrl,
      createdAt: createdAt,
    );
  }
}
