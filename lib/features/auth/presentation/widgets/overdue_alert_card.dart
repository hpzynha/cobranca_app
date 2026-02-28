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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Você tem $overdueCount cobranças vencidas",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: danger,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                "Cobrar agora",
                style: TextStyle(fontWeight: FontWeight.w600, color: danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
