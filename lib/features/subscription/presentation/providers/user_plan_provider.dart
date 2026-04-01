import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_cobranca/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:app_cobranca/features/subscription/domain/usecases/activate_admin_coupon_usecase.dart';
import 'package:app_cobranca/features/subscription/domain/usecases/validate_coupon_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Data source & use-cases ────────────────────────────────────────────────

final subscriptionRemoteDataSourceProvider = Provider<SubscriptionRemoteDataSource>((ref) {
  return SubscriptionRemoteDataSource(ref.watch(supabaseClientProvider));
});

final validateCouponUseCaseProvider = Provider<ValidateCouponUseCase>((ref) {
  return ValidateCouponUseCase(ref.watch(subscriptionRemoteDataSourceProvider));
});

final activateAdminCouponUseCaseProvider = Provider<ActivateAdminCouponUseCase>((ref) {
  return ActivateAdminCouponUseCase(ref.watch(subscriptionRemoteDataSourceProvider));
});

// ── Plan data ──────────────────────────────────────────────────────────────

typedef UserPlan = ({
  String plan,
  bool isPro,
  bool isFree,
  DateTime? planExpiresAt,
});

/// Stream-based provider so the UI reacts automatically when the plan changes
/// (e.g. right after activating a coupon or receiving a webhook update).
final userPlanProvider = StreamProvider<UserPlan>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return Stream.value((plan: 'free', isPro: false, isFree: true, planExpiresAt: null));
  }

  return Supabase.instance.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((rows) {
        if (rows.isEmpty) {
          return (plan: 'free', isPro: false, isFree: true, planExpiresAt: null);
        }
        final row = rows.first;
        final plan = (row['plan'] as String?) ?? 'free';
        final expiresAtRaw = row['plan_expires_at'] as String?;
        final expiresAt = expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null;

        // Pro is active if plan == 'pro' AND either no expiry (permanent) or not yet expired
        final isPro =
            plan == 'pro' && (expiresAt == null || expiresAt.isAfter(DateTime.now()));

        return (
          plan: plan,
          isPro: isPro,
          isFree: !isPro,
          planExpiresAt: expiresAt,
        );
      });
});
