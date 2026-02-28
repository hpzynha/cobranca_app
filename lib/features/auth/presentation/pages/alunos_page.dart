import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/presentation/mappers/student_ui_mapper.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final isCompact = AppResponsive.isCompact(context);
    final horizontalPadding =
        AppResponsive.size(context, isCompact ? 14 : 16).clamp(12.0, 22.0);
    final topPadding = AppResponsive.size(context, isCompact ? 12 : 16);

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alunos', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: studentsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (students) {
                    if (students.isEmpty) {
                      return const Center(
                        child: Text('Nenhum aluno cadastrado até o momento.'),
                      );
                    }

                    final items = students.map(toStudentPaymentItem).toList();
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == items.length - 1 ? 0 : 14,
                          ),
                          child: _StudentListItem(student: items[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 1),
    );
  }
}

class AlunosPage extends StudentsPage {
  const AlunosPage({super.key});
}

class _StudentListItem extends StatelessWidget {
  const _StudentListItem({required this.student});

  final StudentPaymentItem student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            radius: 26,
            backgroundColor: const Color(0xFFF0F2F5),
            child: Text(student.initials),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(student.dueLabel),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(student.amountLabel),
        ],
      ),
    );
  }
}
