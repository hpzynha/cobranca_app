import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/dashboard_status_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/home_header.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/overdue_alert_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = AppResponsive.isCompact(context);
    final horizontalPadding = AppResponsive.size(
      context,
      isCompact ? 14 : 16,
    ).clamp(12.0, 22.0);
    final bottomContentPadding = AppResponsive.size(
      context,
      16,
    ).clamp(12.0, 24.0);
    final sectionSpacing = AppResponsive.size(context, isCompact ? 14 : 16);
    final cardSpacing = isCompact ? AppSpacing.sm : 12.0;
    final studentsAsync = ref.watch(studentPaymentItemsProvider);
    final balance = ref.watch(monthlyBalanceProvider).valueOrNull ?? 0.0;
    final userName = ref.watch(currentUserNameProvider);

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          HomeHeader(balance: balance, userName: userName),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                sectionSpacing,
                horizontalPadding,
                bottomContentPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  switch (studentsAsync) {
                    AsyncData(:final value) => _HomeStatusSection(
                      students: value,
                      cardSpacing: cardSpacing,
                    ),
                    AsyncError() => Text(
                      'Não foi possível carregar os indicadores de alunos.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _ => const Center(child: CircularProgressIndicator()),
                  },

                  SizedBox(height: sectionSpacing),

                  if (studentsAsync.hasValue)
                    OverdueAlertCard(
                      overdueCount:
                          studentsAsync.value!
                              .where(
                                (student) =>
                                    student.status == StudentPaymentStatus.overdue,
                              )
                              .length,
                      onTap: () {
                        // navegar para lista de atrasados
                      },
                    ),

                  SizedBox(height: sectionSpacing),
                  switch (studentsAsync) {
                    AsyncData(:final value) => StudentsDashboardCard(
                      students: value,
                      onStudentTap: (student) {
                        context.push('/alunos/${student.id}', extra: student);
                      },
                    ),
                    AsyncError() => const StudentsDashboardCard(students: []),
                    _ => const StudentsDashboardCard(students: []),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),  // 0 = Alunos
    );
  }
}

class _HomeStatusSection extends StatelessWidget {
  const _HomeStatusSection({required this.students, required this.cardSpacing});

  final List<StudentPaymentItem> students;
  final double cardSpacing;

  @override
  Widget build(BuildContext context) {
    final overdueCount =
        students
            .where((student) => student.status == StudentPaymentStatus.overdue)
            .length;
    final dueTodayCount =
        students
            .where((student) => student.status == StudentPaymentStatus.dueSoon)
            .length;
    final paidCount =
        students
            .where((student) => student.status == StudentPaymentStatus.paid)
            .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isVerySmallScreen = width < 350;
        final isSmallScreen = width < 390;
        final cardHeight =
            isVerySmallScreen ? 122.0 : (isSmallScreen ? 132.0 : 142.0);

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: cardHeight,
                child: DashboardStatusCard(
                  count: overdueCount,
                  label: AppStrings.statusOverdue,
                  type: StatusType.overdue,
                ),
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: SizedBox(
                height: cardHeight,
                child: DashboardStatusCard(
                  count: dueTodayCount,
                  label: AppStrings.statusDueToday,
                  type: StatusType.dueToday,
                ),
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: SizedBox(
                height: cardHeight,
                child: DashboardStatusCard(
                  count: paidCount,
                  label: AppStrings.statusPaid,
                  type: StatusType.paid,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
