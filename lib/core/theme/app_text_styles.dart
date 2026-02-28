import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_responsive.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontWeight: FontWeight.w500,
    color: AppColors.onPrimary,
  );

  static const TextStyle dashboardSubtitle = TextStyle(
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle dashboardAmount = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle dashboardCardNumber = TextStyle(
    fontWeight: FontWeight.w700,
    color: AppColors.textStrong,
  );

  static const TextStyle dashboardCardLabel = TextStyle(
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle dashboardAlert = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.danger,
  );

  static TextStyle responsive(
    BuildContext context,
    TextStyle baseStyle, {
    double? baseSize,
    double min = 0.9,
    double max = 1.08,
  }) {
    final seed = baseSize ?? baseStyle.fontSize ?? 14;
    return baseStyle.copyWith(
      fontSize: AppResponsive.fontSize(context, seed, min: min, max: max),
    );
  }
}
