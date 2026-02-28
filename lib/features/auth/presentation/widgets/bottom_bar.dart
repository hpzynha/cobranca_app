import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    required this.currentIndex,
    super.key,
  });

  final int currentIndex;

  static const _primaryColor = Color(0xFFE75A2E);
  static const _inactiveColor = Color(0xFF7C8292);
  static const _centerButtonSize = 54.0;
  static const _centerButtonTopOffset = -14.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          _buildNavContainer(context),
          Positioned(
            top: _centerButtonTopOffset,
            child: _buildCenterButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavContainer(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                label: 'Início',
              ),
              _buildItem(
                context: context,
                index: 1,
                icon: Icons.groups_2_outlined,
                label: 'Alunos',
              ),
              const Spacer(),
              _buildItem(
                context: context,
                index: 3,
                icon: Icons.bar_chart_outlined,
                label: 'Relatórios',
              ),
              _buildItem(
                context: context,
                index: 4,
                icon: Icons.settings_outlined,
                label: 'Config',
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
  }) {
    final isActive = currentIndex == index;
    final color = isActive ? _primaryColor : _inactiveColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _onTap(context, index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildCenterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context, 2),
      child: Container(
        width: _centerButtonSize,
        height: _centerButtonSize,
        decoration: const BoxDecoration(
          color: _primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x4DE75A2E),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 26, color: Colors.white),
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
