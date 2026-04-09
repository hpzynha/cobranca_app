class ReportSummary {
  const ReportSummary({
    required this.expectedCents,
    required this.receivedCents,
    required this.dueSoonCents,
    required this.overdueCents,
  });

  final int expectedCents;
  final int receivedCents;
  final int dueSoonCents;
  final int overdueCents;
}
