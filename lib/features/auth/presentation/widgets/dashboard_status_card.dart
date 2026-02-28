import 'package:flutter/material.dart';

enum StatusType { overdue, dueToday, paid }

class DashboardStatusCard extends StatelessWidget {
  final int count;
  final String label;
  final StatusType type;

  const DashboardStatusCard({
    super.key,
    required this.count,
    required this.label,
    required this.type,
  });

  Color get color {
    switch (type) {
      case StatusType.overdue:
        return const Color(0xFFE5484D);
      case StatusType.dueToday:
        return const Color(0xFFF5A524);
      case StatusType.paid:
        return const Color(0xFF2FBF71);
    }
  }

  IconData get icon {
    switch (type) {
      case StatusType.overdue:
        return Icons.trending_down_rounded;
      case StatusType.dueToday:
        return Icons.access_time_rounded;
      case StatusType.paid:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isCompact = maxWidth < 120;
        final cardPadding = isCompact ? 10.0 : 14.0;
        final iconSize = isCompact ? 20.0 : 24.0;
        final numberSize = isCompact ? 22.0 : 30.0;
        final labelSize = isCompact ? 12.0 : 14.0;
        final iconGap = isCompact ? 18.0 : 22.0;
        final labelGap = isCompact ? 8.0 : 10.0;

        return Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: iconSize),
              SizedBox(height: iconGap),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: numberSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: labelGap),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
