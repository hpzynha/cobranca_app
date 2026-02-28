import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:flutter/material.dart';

enum StudentsFilter { all, overdue, dueSoon, paid }

extension StudentsFilterLabel on StudentsFilter {
  String get label {
    switch (this) {
      case StudentsFilter.all:
        return 'Todos';
      case StudentsFilter.overdue:
        return 'Atrasados';
      case StudentsFilter.dueSoon:
        return 'Vencem hoje';
      case StudentsFilter.paid:
        return 'Pagos';
    }
  }
}

class StudentsFilterChips extends StatelessWidget {
  const StudentsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final StudentsFilter selectedFilter;
  final ValueChanged<StudentsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = StudentsFilter.values;
    final textSize = AppResponsive.fontSize(context, 14).clamp(13.0, 16.0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.textPrimary : const Color(0xFFF0F1F3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
