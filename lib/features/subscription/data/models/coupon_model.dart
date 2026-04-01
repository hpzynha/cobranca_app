import 'package:app_cobranca/features/subscription/domain/entities/coupon.dart';

class CouponModel {
  const CouponModel({
    required this.discountPercent,
    required this.isAdmin,
    required this.finalPriceCents,
    required this.message,
  });

  final int discountPercent;
  final bool isAdmin;
  final int finalPriceCents;
  final String message;

  factory CouponModel.fromEdgeFunctionResponse(Map<String, dynamic> json) {
    return CouponModel(
      discountPercent: (json['discount_percent'] as num?)?.toInt() ?? 0,
      isAdmin: (json['is_admin'] as bool?) ?? false,
      finalPriceCents: (json['final_price_cents'] as num?)?.toInt() ?? 0,
      message: (json['message'] as String?) ?? '',
    );
  }

  Coupon toEntity(String code) => Coupon(
    id: '',
    code: code,
    discountPercent: discountPercent,
    isAdmin: isAdmin,
    finalPriceCents: finalPriceCents,
    message: message,
  );
}
