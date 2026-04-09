class ReportSummary {
  const ReportSummary({
    required this.expectedCents,
    required this.receivedCents,
    required this.dueSoonCents,
    required this.overdueCents,
    required this.lateReceivedCents,
  });

  final int expectedCents;
  final int receivedCents;
  final int dueSoonCents;
  final int overdueCents;
  final int lateReceivedCents;
}
