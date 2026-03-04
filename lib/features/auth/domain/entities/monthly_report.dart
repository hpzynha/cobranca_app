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
      expectedCents: map['expected_cents'] ?? 0,
      receivedCents: map['received_cents'] ?? 0,
      pendingCents: map['pending_cents'] ?? 0,
    );
  }
}
