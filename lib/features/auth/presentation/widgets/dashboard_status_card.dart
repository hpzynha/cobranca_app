import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_radius.dart';
import 'package:app_cobranca/core/theme/app_text_styles.dart';
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
        return AppColors.danger;
      case StatusType.dueToday:
        return AppColors.warning;
      case StatusType.paid:
        return AppColors.success;
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
        final isCompact = maxWidth < 118;
        final cardPadding = (maxWidth * 0.11).clamp(9.0, 14.0);
        final iconSize = (maxWidth * 0.2).clamp(16.0, 24.0);
        final numberSize = (maxWidth * 0.24).clamp(20.0, 30.0);
        final labelSize = (maxWidth * 0.11).clamp(10.0, 14.0);
        final iconGap = isCompact ? 14.0 : 18.0;
        final labelGap = isCompact ? 4.0 : 6.0;

        return Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(isCompact ? AppRadius.lg : 20),
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
                style: AppTextStyles.dashboardCardNumber.copyWith(
                  fontSize: numberSize,
                ),
              ),
              SizedBox(height: labelGap),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.dashboardCardLabel.copyWith(
                  fontSize: labelSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
