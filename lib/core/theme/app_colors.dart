import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5B4CF5);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFF0F1F5);
  static const Color onSecondary = Color(0xFF1A1A1A);

  static const Color accent = Color(0xFFF0F1F5);
  static const Color onAccent = Color(0xFF1A1A1A);

  static const Color background = secondary;
  static const Color surface = secondary;
  static const Color textPrimary = onSecondary;
  static const Color textSecondary = onSecondary;
  static const Color border = Color(0xFFD9DCE3);
  static const Color inputFill = surface;

  static const Color googleBorder = Color(0xFFDDDDDD);

  // Semantic status colors
  static const Color danger = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF5A524);
  static const Color success = Color(0xFF2FBF71);

  // Extra neutrals used in dashboard widgets
  static const Color textStrong = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color bottomBarInactive = Color(0xFF7C8292);

  static const Color primaryShadow = Color(0x4D3D2FD9);

  // ── Dark palette ────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0F14);
  static const Color surfaceDark = Color(0xFF1A1A28);
  static const Color primaryOnDark = Color(0xFF7C6FF7);
  static const Color textPrimaryDark = Color(0xFFE4E4F0);
  static const Color textMutedDark = Color(0xFF8A8FA8);
  static const Color borderDark = Color(0xFF252535);
  static const Color bottomBarDark = Color(0xFF1E1E2E);
}
