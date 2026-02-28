import 'package:flutter/widgets.dart';

class AppResponsive {
  AppResponsive._();

  static const double _baseWidth = 390.0;
  static const double _minScale = 0.86;
  static const double _maxScale = 1.08;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) => screenWidth(context) < 360;

  static bool isSmall(BuildContext context) => screenWidth(context) < 390;

  static double scale(
    BuildContext context, {
    double min = _minScale,
    double max = _maxScale,
  }) {
    final rawScale = screenWidth(context) / _baseWidth;
    return rawScale.clamp(min, max);
  }

  static double size(
    BuildContext context,
    double base, {
    double min = _minScale,
    double max = _maxScale,
  }) {
    return base * scale(context, min: min, max: max);
  }

  static double fontSize(
    BuildContext context,
    double base, {
    double min = 0.9,
    double max = _maxScale,
  }) {
    return size(context, base, min: min, max: max);
  }
}
