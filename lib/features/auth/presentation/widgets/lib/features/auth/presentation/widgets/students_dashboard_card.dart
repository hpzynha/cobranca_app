import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_radius.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum StudentPaymentStatus {
  overdue('Atrasado', Color(0xFFFDECEC), AppColors.danger),
  paid('Pago', Color(0xFFE8F8EF), AppColors.success),
  dueSoon('Vence em breve', Color(0xFFFFF4E7), Color(0xFFF08C00)),
  pending('Pendente', Color(0xFFEFF2F6), AppColors.textMuted);

  const StudentPaymentStatus(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

class StudentPaymentItem {
  const StudentPaymentItem({
    required this.id,
    required this.initials,
    required this.name,
    required this.whatsapp,
    required this.dueLabel,
    required this.amountLabel,
    required this.monthlyFeeCents,
    required this.status,
    this.photoUrl,
    this.dueDay,
    this.nextDueDate,
    this.lastPaymentDate,
  });

  final String id;
  final String initials;
  final String name;
  final String whatsapp;
  final String dueLabel;
  final String amountLabel;
  final int monthlyFeeCents;
  final StudentPaymentStatus status;
  final String? photoUrl;
  final int? dueDay;
  final DateTime? nextDueDate;
  final DateTime? lastPaymentDate;
}

class StudentsDashboardCard extends StatelessWidget {
  const StudentsDashboardCard({
    super.key,
    this.students = const [],
    this.onStudentTap,
  });

  final List<StudentPaymentItem> students;
  final ValueChanged<StudentPaymentItem>? onStudentTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = AppResponsive.isCompact(context);
    final titleSize = AppResponsive.fontSize(context, isCompact ? 16 : 18);

    return StudentsList(
      students: students,
      showTitle: true,
      titleSize: titleSize,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onStudentTap: onStudentTap,
    );
  }
}

class StudentsList extends StatelessWidget {
  const StudentsList({
    super.key,
    required this.students,
    this.showTitle = false,
    this.titleSize,
    this.height,
    this.shrinkWrap = false,
    this.physics,
    this.emptyMessage = 'Você ainda não possui aluno cadastrado',
    this.onStudentTap,
  });

  final List<StudentPaymentItem> students;
  final bool showTitle;
  final double? titleSize;
  final double? height;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String emptyMessage;
  final ValueChanged<StudentPaymentItem>? onStudentTap;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (students.isEmpty) {
      content = Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      );
    } else {
      content = ListView.separated(
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemBuilder: (context, index) {
          final student = students[index];
          return _StudentRowCard(
            student: student,
            onTap: onStudentTap == null ? null : () => onStudentTap!(student),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemCount: students.length,
      );
    }

    if (height != null) {
      content = SizedBox(height: height, child: content);
    }

    if (!showTitle) {
      return content;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alunos',
          style: AppTextStyles.heading.copyWith(fontSize: titleSize ?? 22),
        ),
        const SizedBox(height: AppSpacing.md),
        content,
      ],
    );
  }
}

class _StudentRowCard extends StatelessWidget {
  const _StudentRowCard({required this.student, this.onTap});

  final StudentPaymentItem student;
  final VoidCallback? onTap;

  Color get _avatarColor {
    return switch (student.status) {
      StudentPaymentStatus.overdue => AppColors.danger,
      StudentPaymentStatus.paid => AppColors.success,
      StudentPaymentStatus.dueSoon => AppColors.warning,
      StudentPaymentStatus.pending => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    final isCompact = maxWidth < 370;
    final nameSize = AppResponsive.fontSize(context, isCompact ? 13 : 14);
    final amountSize = AppResponsive.fontSize(context, isCompact ? 13 : 14);
    final dueSize = AppResponsive.fontSize(context, 11);
    final initialsSize = AppResponsive.fontSize(context, 10.5);
    final avatarRadius = isCompact ? 24.0 : 26.0;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: _avatarColor,
                child: Text(
                  student.initials,
                  style: AppTextStyles.dashboardCardNumber.copyWith(
                    fontSize: initialsSize,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: isCompact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading.copyWith(fontSize: nameSize),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.dueLabel,
                      style: AppTextStyles.body.copyWith(
                        fontSize: dueSize,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isCompact ? 8 : 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    student.amountLabel,
                    style: AppTextStyles.heading.copyWith(fontSize: amountSize),
                  ),
                  const SizedBox(height: 8),
                  _StatusPill(status: student.status),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final StudentPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.dashboardAlert.copyWith(
          color: status.foreground,
          fontSize: 11,
        ),
      ),
    );
  }
}
