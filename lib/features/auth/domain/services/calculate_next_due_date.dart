DateTime calculateNextDueDate(int dueDay, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final baseMonth =
      dueDay >= today.day
          ? DateTime(today.year, today.month)
          : DateTime(today.year, today.month + 1);

  final day = _clampDay(baseMonth.year, baseMonth.month, dueDay);
  return DateTime(baseMonth.year, baseMonth.month, day);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _clampDay(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return day.clamp(1, lastDay);
}
