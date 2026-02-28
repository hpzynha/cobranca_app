import 'dart:ui';

import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({required this.currentIndex, super.key});

  final int currentIndex;

  static const _centerButtonSize = 54.0;
  static const _centerButtonTopOffset = -14.0;

  @override
  Widget build(BuildContext context) {
    final isCompact = AppResponsive.screenWidth(context) < 375;

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, isCompact ? 12 : 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          _buildNavContainer(context, isCompact),
          Positioned(
            top: isCompact ? -12 : _centerButtonTopOffset,
            child: _buildCenterButton(context, isCompact),
          ),
        ],
      ),
    );
  }

  Widget _buildNavContainer(BuildContext context, bool isCompact) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: isCompact ? 72 : 78,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              _buildItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                label: AppStrings.navHome,
                isCompact: isCompact,
              ),
              _buildItem(
                context: context,
                index: 1,
                icon: Icons.groups_2_outlined,
                label: AppStrings.navStudents,
                isCompact: isCompact,
              ),
              const Spacer(),
              _buildItem(
                context: context,
                index: 3,
                icon: Icons.bar_chart_outlined,
                label: AppStrings.navReports,
                isCompact: isCompact,
              ),
              _buildItem(
                context: context,
                index: 4,
                icon: Icons.settings_outlined,
                label: AppStrings.navSettings,
                isCompact: isCompact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isCompact,
  }) {
    final isActive = currentIndex == index;
    final color = isActive ? AppColors.primary : AppColors.bottomBarInactive;
    final labelSize = AppResponsive.fontSize(
      context,
      isCompact ? 11 : 12,
      min: 0.96,
      max: 1.08,
    );

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _onTap(context, index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isCompact ? 8 : 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: isCompact ? 22 : 26, color: color),
              SizedBox(height: isCompact ? 2 : 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context, bool isCompact) {
    final buttonSize = isCompact ? 50.0 : _centerButtonSize;

    return GestureDetector(
      onTap: () => _onTap(context, 2),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryShadow,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Icon(Icons.add, size: isCompact ? 24 : 26, color: Colors.white),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    final route = switch (index) {
      0 => '/home',
      1 => '/alunos',
      2 => '/adicionar',
      3 => '/relatorios',
      4 => '/config',
      _ => '/home',
    };
    context.go(route);
  }
}
