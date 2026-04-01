class Subscription {
  const Subscription({
    required this.id,
    required this.ownerId,
    required this.status,
    required this.amountCents,
    required this.createdAt,
    this.couponId,
    this.abacatepaySubscriptionId,
  });

  final String id;
  final String ownerId;
  final String? couponId;
  final String? abacatepaySubscriptionId;
  final String status;
  final int amountCents;
  final DateTime createdAt;
}
