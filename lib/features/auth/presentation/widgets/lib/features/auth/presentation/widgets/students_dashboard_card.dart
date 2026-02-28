import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_radius.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum StudentPaymentStatus {
  overdue('Atrasado', Color(0xFFFDECEC), AppColors.danger),
  paid('Pago', Color(0xFFE8F8EF), AppColors.success),
  dueSoon('Vence em breve', Color(0xFFFFF4E7), Color(0xFFF08C00));

  const StudentPaymentStatus(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

class StudentPaymentItem {
  const StudentPaymentItem({
    required this.initials,
    required this.name,
    required this.dueLabel,
    required this.amountLabel,
    required this.status,
  });

  final String initials;
  final String name;
  final String dueLabel;
  final String amountLabel;
  final StudentPaymentStatus status;
}

const kMockStudentPayments = <StudentPaymentItem>[
  StudentPaymentItem(
    initials: 'MS',
    name: 'Maria Silva',
    dueLabel: 'Venc. dia 10',
    amountLabel: 'R\$ 300,00',
    status: StudentPaymentStatus.overdue,
  ),
  StudentPaymentItem(
    initials: 'JP',
    name: 'João Pedro',
    dueLabel: 'Venc. dia 15',
    amountLabel: 'R\$ 250,00',
    status: StudentPaymentStatus.paid,
  ),
  StudentPaymentItem(
    initials: 'AP',
    name: 'Ana Paula',
    dueLabel: 'Venc. dia 28',
    amountLabel: 'R\$ 400,00',
    status: StudentPaymentStatus.dueSoon,
  ),
  StudentPaymentItem(
    initials: 'CL',
    name: 'Carlos Lima',
    dueLabel: 'Venc. dia 30',
    amountLabel: 'R\$ 350,00',
    status: StudentPaymentStatus.dueSoon,
  ),
];

class StudentsDashboardCard extends StatelessWidget {
  const StudentsDashboardCard({
    super.key,
    this.students = kMockStudentPayments,
  });

  final List<StudentPaymentItem> students;

  @override
  Widget build(BuildContext context) {
    final isCompact = AppResponsive.isCompact(context);
    final titleSize = AppResponsive.fontSize(context, isCompact ? 20 : 22);
    final listHeight = isCompact ? 320.0 : 340.0;

    return StudentsList(
      students: students,
      showTitle: true,
      titleSize: titleSize,
      height: listHeight,
      physics: const BouncingScrollPhysics(),
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
  });

  final List<StudentPaymentItem> students;
  final bool showTitle;
  final double? titleSize;
  final double? height;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (students.isEmpty) {
      content = Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            fontSize: 15,
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
          return _StudentRowCard(student: student);
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
  const _StudentRowCard({required this.student});

  final StudentPaymentItem student;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    final isCompact = maxWidth < 370;
    final nameSize = AppResponsive.fontSize(context, isCompact ? 15 : 16);
    final amountSize = AppResponsive.fontSize(context, isCompact ? 15 : 16);
    final dueSize = AppResponsive.fontSize(context, 12);
    final initialsSize = AppResponsive.fontSize(context, 11.5);
    final avatarRadius = isCompact ? 24.0 : 26.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: const Color(0xFFF0F2F5),
            child: Text(
              student.initials,
              style: AppTextStyles.dashboardCardNumber.copyWith(
                fontSize: initialsSize,
                color: AppColors.textPrimary,
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
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
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
          fontSize: 12,
        ),
      ),
    );
  }
}
