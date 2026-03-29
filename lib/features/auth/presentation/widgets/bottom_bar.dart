import 'dart:ui';

import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  /// Índices: 0 = Home, 1 = Alunos, 2 = Mensagens, 3 = Relatórios.
  /// Passe -1 para nenhum item ativo (ex: Config page).
  const BottomBar({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final isCompact = AppResponsive.screenWidth(context) < 375;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.bottomBarDark.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.9);
    final borderColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.4);
    final shadowColor =
        Colors.black.withValues(alpha: isDark ? 0.40 : 0.10);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, isCompact ? 10 : 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: isCompact ? 10 : 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_rounded,
                      label: AppStrings.navHome,
                      isActive: currentIndex == 0,
                      isDark: isDark,
                      onTap: () => context.go('/'),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.groups_2_outlined,
                      label: AppStrings.navStudents,
                      isActive: currentIndex == 1,
                      isDark: isDark,
                      onTap: () => context.go('/alunos'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _FabButton(
                      isCompact: isCompact,
                      onTap: () => context.go('/adicionar'),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Mensagens',
                      isActive: currentIndex == 2,
                      isDark: isDark,
                      onTap: () => context.go('/mensagens'),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.bar_chart_outlined,
                      label: AppStrings.navReports,
                      isActive: currentIndex == 3,
                      isDark: isDark,
                      onTap: () => context.go('/relatorios'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.primaryOnDark : AppColors.primary;
    final inactiveColor = isDark ? const Color(0xFF4a4a62) : AppColors.bottomBarInactive;
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({required this.isCompact, required this.onTap});

  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = isCompact ? 44.0 : 48.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          size: isCompact ? 22 : 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
