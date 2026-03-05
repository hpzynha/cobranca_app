class MonthlyReport {
  final int expectedCents;
  final int receivedCents;
  final int pendingCents;

  MonthlyReport({
    required this.expectedCents,
    required this.receivedCents,
    required this.pendingCents,
  });

  factory MonthlyReport.fromMap(Map<String, dynamic> map) {
    return MonthlyReport(
      expectedCents: _toInt(map['expected_cents']),
      receivedCents: _toInt(map['received_cents']),
      pendingCents: _toInt(map['pending_cents']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
