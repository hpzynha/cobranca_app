import 'dart:ui';

import 'package:flutter/material.dart';

class BottomBarItem {
  final IconData icon;
  final String label;
  final bool isCenter;

  const BottomBarItem({
    required this.icon,
    required this.label,
    this.isCenter = false,
  });
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _primaryColor = Color(0xFFE75A2E);
  static const _inactiveColor = Color(0xFF7C8292);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final centerSize = (maxWidth * 0.16).clamp(52.0, 64.0);
          final iconSize = (maxWidth * 0.07).clamp(22.0, 28.0);
          final labelSize = (maxWidth * 0.034).clamp(11.0, 15.0);
          final barHeight = (maxWidth * 0.2).clamp(86.0, 102.0);

          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: barHeight,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    if (item.isCenter) {
                      return _CenterAction(
                        item: item,
                        size: centerSize,
                        onTap: () => onTap(index),
                      );
                    }

                    final isActive = currentIndex == index;
                    final color = isActive ? _primaryColor : _inactiveColor;

                    return Expanded(
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, color: color, size: iconSize),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({
    required this.item,
    required this.size,
    required this.onTap,
  });

  final BottomBarItem item;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -(size * 0.25)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Ink(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Color(0xFFE75A2E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x55E75A2E),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: size * 0.55),
          ),
        ),
      ),
    );
  }
}
