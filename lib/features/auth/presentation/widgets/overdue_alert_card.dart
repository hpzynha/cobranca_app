import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_radius.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class OverdueAlertCard extends StatelessWidget {
  final int overdueCount;
  final VoidCallback onTap;
  final bool isPro;

  const OverdueAlertCard({
    super.key,
    required this.overdueCount,
    required this.onTap,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    if (overdueCount == 0) {
      return const SizedBox.shrink();
    }

    const danger = AppColors.danger;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final horizontalPadding = isCompact ? 12.0 : AppSpacing.md;
        final messageSize = AppResponsive.fontSize(
          context,
          isCompact ? 14 : 15,
          min: 0.95,
          max: 1.08,
        );
        final buttonTextSize = AppResponsive.fontSize(
          context,
          isCompact ? 14 : 15,
          min: 0.95,
          max: 1.08,
        );

        return Container(
          padding: EdgeInsets.all(horizontalPadding),
          decoration: BoxDecoration(
            color: danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: danger.withValues(alpha: 0.25)),
          ),
          child:
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_rounded, color: danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.overdueChargesMessage(overdueCount),
                              style: AppTextStyles.dashboardAlert.copyWith(
                                fontSize: messageSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _ActionChip(
                          onTap: onTap,
                          danger: danger,
                          fontSize: buttonTextSize,
                          label: isPro ? 'Ver mensagens' : AppStrings.collectNow,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Icon(Icons.warning_rounded, color: danger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.overdueChargesMessage(overdueCount),
                          style: AppTextStyles.dashboardAlert.copyWith(
                            fontSize: messageSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ActionChip(
                        onTap: onTap,
                        danger: danger,
                        fontSize: buttonTextSize,
                        label: isPro ? 'Ver mensagens' : AppStrings.collectNow,
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.onTap,
    required this.danger,
    required this.fontSize,
    required this.label,
  });

  final VoidCallback onTap;
  final Color danger;
  final double fontSize;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.dashboardAlert.copyWith(fontSize: fontSize),
        ),
      ),
    );
  }
}
