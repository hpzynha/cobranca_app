import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_responsive.dart';

class AppTextStyles {
  AppTextStyles._();

  // Colors removed from non-semantic styles so they inherit from the theme
  // (enabling dark mode text color propagation via DefaultTextStyle).
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.45,
  );

  // Intentional white — used on colored (primary) backgrounds.
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );

  static const TextStyle dashboardSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle dashboardAmount = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.08,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle dashboardCardNumber = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle dashboardCardLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Intentional danger red — always semantic.
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
