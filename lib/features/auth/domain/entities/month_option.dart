class MonthOption {
  const MonthOption({
    required this.year,
    required this.month,
    required this.label,
  });

  final int year;
  final int month;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is MonthOption && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}
