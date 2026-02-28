class Student {
  const Student({
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
}
