import 'dart:ui';

import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 1;

  static const _primaryColor = Color(0xFFE75A2E);
  static const _inactiveColor = Color(0xFF7C8292);

  final List<_BottomNavItem> _items = const [
    _BottomNavItem(icon: Icons.home_outlined, label: 'Início'),
    _BottomNavItem(icon: Icons.groups_2_outlined, label: 'Alunos'),
    _BottomNavItem(icon: Icons.add, label: 'Novo', isCenter: true),
    _BottomNavItem(icon: Icons.bar_chart_outlined, label: 'Relatórios'),
    _BottomNavItem(icon: Icons.settings_outlined, label: 'Config'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 92,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_items.length, (index) {
                  final item = _items[index];

                  if (item.isCenter) {
                    return Transform.translate(
                      offset: const Offset(0, -14),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => _onTap(index),
                          child: Ink(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: _primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x4DE75A2E),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(item.icon, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    );
                  }

                  final isActive = _selectedIndex == index;
                  final color = isActive ? _primaryColor : _inactiveColor;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onTap(index),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, color: color, size: 30),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 32 * 0.375,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final bool isCenter;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isCenter = false,
  });
}
