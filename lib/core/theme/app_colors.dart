import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Roxo principal (brand Mensalify) ──────────────────────────────
  static const Color primary        = Color(0xFF534AB7); // #534AB7 ★ principal
  static const Color primaryHover   = Color(0xFF3C3489); // hover / pressed
  static const Color primaryMid     = Color(0xFF7F77DD); // ícones secundários
  static const Color primaryMuted   = Color(0xFFAFA9EC); // labels, placeholders
  static const Color primarySurface = Color(0xFFEEEDFE); // backgrounds suaves
  static const Color primaryLight   = Color(0xFFCECBF6); // bordas leves

  static const Color onPrimary      = Color(0xFFFFFFFF);

  // ── Coral (ação / urgência) ───────────────────────────────────────
  static const Color action         = Color(0xFFD85A30); // botão "Cobrar agora"
  static const Color actionHover    = Color(0xFF993C1D);
  static const Color actionSurface  = Color(0xFFFAEEDA);

  // ── Semânticas ────────────────────────────────────────────────────
  static const Color success        = Color(0xFF1D9E75); // Pago / confirmado
  static const Color successSurface = Color(0xFFE1F5EE);

  static const Color danger         = Color(0xFFE24B4A); // Atrasado / erro
  static const Color dangerSurface  = Color(0xFFFCEBEB);

  static const Color warning        = Color(0xFFD85A30); // mesmo coral
  static const Color warningSurface = Color(0xFFFAEEDA);

  // ── Neutros ───────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF5F4F0);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color border         = Color(0xFFE0DFD8);
  static const Color inputFill      = Color(0xFFFFFFFF);

  static const Color textPrimary    = Color(0xFF1A1A1A);
  static const Color textSecondary  = Color(0xFF5F5E5A);
  static const Color textMuted      = Color(0xFF888780);
  static const Color textHint       = Color(0xFFB4B2A9);

  // ── Sombra do botão primário ──────────────────────────────────────
  static const Color primaryShadow  = Color(0x40534AB7);

  // ── Bottom bar ────────────────────────────────────────────────────
  static const Color bottomBarInactive = Color(0xFF888780);

  // ── Aliases de compatibilidade (não remover — usados em widgets) ──
  static const Color secondary      = Color(0xFFF5F4F0);
  static const Color onSecondary    = Color(0xFF1A1A1A);
  static const Color accent         = Color(0xFFEEEDFE);
  static const Color onAccent       = Color(0xFF3C3489);
  static const Color textStrong     = Color(0xFF1A1A1A);
  static const Color googleBorder   = Color(0xFFE0DFD8);

  // ── Dark palette ─────────────────────────────────────────────────
  static const Color backgroundDark   = Color(0xFF0F0F14);
  static const Color surfaceDark      = Color(0xFF1A1A28);
  static const Color primaryOnDark    = Color(0xFF7F77DD);
  static const Color textPrimaryDark  = Color(0xFFE4E4F0);
  static const Color textMutedDark    = Color(0xFF8A8FA8);
  static const Color borderDark       = Color(0xFF252535);
  static const Color bottomBarDark    = Color(0xFF1E1E2E);
}
