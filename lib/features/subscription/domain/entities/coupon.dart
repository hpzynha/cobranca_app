class Coupon {
  const Coupon({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.isAdmin,
    required this.finalPriceCents,
    required this.message,
  });

  final String id;
  final String code;
  final int discountPercent;
  final bool isAdmin;
  final int finalPriceCents;
  final String message;
}
