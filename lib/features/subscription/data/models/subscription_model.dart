import 'package:app_cobranca/features/subscription/domain/entities/subscription.dart';

class SubscriptionModel {
  const SubscriptionModel({
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

  factory SubscriptionModel.fromSupabaseMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      couponId: map['coupon_id'] as String?,
      abacatepaySubscriptionId: map['abacatepay_subscription_id'] as String?,
      status: map['status'] as String? ?? 'active',
      amountCents: (map['amount_cents'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Subscription toEntity() => Subscription(
    id: id,
    ownerId: ownerId,
    couponId: couponId,
    abacatepaySubscriptionId: abacatepaySubscriptionId,
    status: status,
    amountCents: amountCents,
    createdAt: createdAt,
  );
}
