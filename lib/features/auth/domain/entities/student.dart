class Student {
  const Student({
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
}
