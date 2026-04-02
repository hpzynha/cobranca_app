import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/core/theme/app_text_styles.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/dashboard_status_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/home_header.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/overdue_alert_card.dart';
import 'package:app_cobranca/features/subscription/presentation/providers/user_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

    final titleSize = AppResponsive.fontSize(context, isCompact ? 16 : 18);
    final students = (studentsAsync.valueOrNull ?? []).where((s) => s.isActive).toList();
    final overdueStudents = students.where((s) => s.status == StudentPaymentStatus.overdue).toList();
    final overdueCount = overdueStudents.length;
    final isPro = ref.watch(userPlanProvider).valueOrNull?.isPro ?? false;

    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(balance: balance, userName: userName),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              sectionSpacing,
              horizontalPadding,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: switch (studentsAsync) {
                AsyncData() => _HomeStatusSection(
                  students: students,
                  cardSpacing: cardSpacing,
                ),
                AsyncError() => Text(
                  'Não foi possível carregar os indicadores de alunos.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
          if (overdueCount > 0)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                sectionSpacing,
                horizontalPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: OverdueAlertCard(
                  overdueCount: overdueCount,
                  isPro: isPro,
                  onTap: isPro
                      ? () => context.push('/mensagens')
                      : () {
                          if (overdueStudents.length == 1) {
                            _openWhatsApp(overdueStudents.first, ref);
                          } else {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => _OverdueStudentsSheet(
                                students: overdueStudents,
                              ),
                            );
                          }
                        },
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              sectionSpacing,
              horizontalPadding,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Alunos',
                style: AppTextStyles.heading.copyWith(fontSize: titleSize),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              bottomContentPadding + 80,
            ),
            sliver: SliverToBoxAdapter(
              child: StudentsList(
                students: students,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onStudentTap: (s) => context.push('/alunos/${s.id}', extra: s),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
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

Future<void> _openWhatsApp(StudentPaymentItem student, WidgetRef ref) async {
  final phone = student.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
  final pixKey = await ref.read(pixKeyProvider.future);
  final pixLine = pixKey.isNotEmpty ? '\nChave PIX para pagamento: $pixKey' : '';
  final message =
      'Olá, ${student.name}! Tudo bem?\n'
      'Seu pagamento de ${student.amountLabel} está com status "${student.status.label}".$pixLine\n'
      'Pode me confirmar por aqui, por favor?';
  final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _OverdueStudentsSheet extends ConsumerWidget {
  const _OverdueStudentsSheet({required this.students});

  final List<StudentPaymentItem> students;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cobranças vencidas', style: AppTextStyles.heading),
            const SizedBox(height: 4),
            Text(
              'Selecione um aluno para enviar mensagem no WhatsApp',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...students.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.name),
                subtitle: Text(s.amountLabel),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openWhatsApp(s, ref);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
