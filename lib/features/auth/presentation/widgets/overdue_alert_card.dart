import 'package:flutter/material.dart';

class OverdueAlertCard extends StatelessWidget {
  final int overdueCount;
  final VoidCallback onTap;

  const OverdueAlertCard({
    super.key,
    required this.overdueCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (overdueCount == 0) {
      return const SizedBox.shrink();
    }

    const Color danger = Color(0xFFE5484D);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final horizontalPadding = isCompact ? 12.0 : 16.0;
        final messageSize = isCompact ? 14.0 : 15.0;
        final buttonTextSize = isCompact ? 14.0 : 15.0;

        return Container(
          padding: EdgeInsets.all(horizontalPadding),
          decoration: BoxDecoration(
            color: danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: danger.withValues(alpha: 0.25)),
          ),
          child:
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_rounded, color: danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Você tem $overdueCount cobranças vencidas",
                              style: TextStyle(
                                fontSize: messageSize,
                                fontWeight: FontWeight.w600,
                                color: danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _ActionChip(
                          onTap: onTap,
                          danger: danger,
                          fontSize: buttonTextSize,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Icon(Icons.warning_rounded, color: danger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Você tem $overdueCount cobranças vencidas",
                          style: TextStyle(
                            fontSize: messageSize,
                            fontWeight: FontWeight.w600,
                            color: danger,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ActionChip(
                        onTap: onTap,
                        danger: danger,
                        fontSize: buttonTextSize,
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.onTap,
    required this.danger,
    required this.fontSize,
  });

  final VoidCallback onTap;
  final Color danger;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          "Cobrar agora",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: danger,
          ),
        ),
      ),
    );
  }
}
