import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_responsive.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );

  static const TextStyle dashboardSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle dashboardAmount = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.08,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.textPrimary,
  );

  static const TextStyle dashboardCardNumber = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.textStrong,
  );

  static const TextStyle dashboardCardLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textMuted,
  );

  static const TextStyle dashboardAlert = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.danger,
  );

  static TextStyle responsive(
    BuildContext context,
    TextStyle baseStyle, {
    double? baseSize,
    double min = 0.92,
    double max = 1.12,
  }) {
    final seed = baseSize ?? baseStyle.fontSize ?? 14;
    return baseStyle.copyWith(
      fontSize: AppResponsive.fontSize(context, seed, min: min, max: max),
    );
  }
}
