import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Barra superior com logo "Venzza" (→ /home) + título da página à direita.
class VenzzaAppBar extends StatelessWidget {
  const VenzzaAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 12),
      child: Row(
        children: [
          // Logo → navega para home
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'V',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: AppResponsive.fontSize(context, 12),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Venzza',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppResponsive.fontSize(context, 13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Título da página
          Text(
            title,
            style: TextStyle(
              fontSize: AppResponsive.fontSize(context, 15),
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}
