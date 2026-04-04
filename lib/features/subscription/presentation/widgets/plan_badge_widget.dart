import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/features/subscription/presentation/providers/user_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PlanBadgeWidget extends ConsumerWidget {
  const PlanBadgeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(userPlanProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return planAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (plan) {
        if (plan.isPro) {
          return _ProBadge(expiresAt: plan.planExpiresAt, isDark: isDark);
        }
        return _FreeBadge(isDark: isDark);
      },
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge({required this.expiresAt, required this.isDark});

  final DateTime? expiresAt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final renewalText = expiresAt != null
        ? 'Renova em ${DateFormat('dd/MM/yyyy').format(expiresAt!)}'
        : 'Acesso vitalício';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Plano Pro',
                style: TextStyle(
                  fontSize: AppResponsive.fontSize(context, 14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              Text(
                renewalText,
                style: TextStyle(
                  fontSize: AppResponsive.fontSize(context, 12),
                  color: AppColors.success.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FreeBadge extends StatelessWidget {
  const _FreeBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF252540) : AppColors.primarySurface;
    final textColor = isDark ? AppColors.primaryMuted : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plano Gratuito',
                  style: TextStyle(
                    fontSize: AppResponsive.fontSize(context, 14),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  'Até 3 alunos cadastrados',
                  style: TextStyle(
                    fontSize: AppResponsive.fontSize(context, 12),
                    color: textColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => context.push('/paywall'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Fazer upgrade',
              style: TextStyle(
                fontSize: AppResponsive.fontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
