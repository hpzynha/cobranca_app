import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/students_filter_chips.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/students_search_field.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/venzza_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlunosPage extends ConsumerStatefulWidget {
  const AlunosPage({super.key});

  @override
  ConsumerState<AlunosPage> createState() => _AlunosPageState();
}

class _AlunosPageState extends ConsumerState<AlunosPage> {
  final TextEditingController _searchController = TextEditingController();
  StudentsFilter _selectedFilter = StudentsFilter.all;
  String _searchQuery = '';

  List<StudentPaymentItem> _filteredStudents(
    List<StudentPaymentItem> students,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    return students.where((student) {
      final matchesFilter = switch (_selectedFilter) {
        StudentsFilter.all => true,
        StudentsFilter.overdue =>
          student.status == StudentPaymentStatus.overdue,
        StudentsFilter.dueToday =>
          student.status == StudentPaymentStatus.dueSoon,
        StudentsFilter.paid => student.status == StudentPaymentStatus.paid,
      };

      final matchesQuery =
          query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.initials.toLowerCase().contains(query);

      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = AppResponsive.isCompact(context);
    final horizontalPadding = AppResponsive.size(
      context,
      isCompact ? 14 : 16,
    ).clamp(12.0, 22.0);
    final studentsAsync = ref.watch(studentPaymentItemsProvider);

    return Scaffold(
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VenzzaAppBar(title: 'Alunos'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                8,
              ),
              child: switch (studentsAsync) {
                AsyncData(:final value) when value.isEmpty => const Center(
                  child: Text('Você ainda não possui aluno cadastrado'),
                ),
                AsyncData(:final value) => Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    StudentsSearchField(
                      controller: _searchController,
                      onChanged: (query) {
                        setState(() => _searchQuery = query);
                      },
                    ),
                    const SizedBox(height: 12),
                    StudentsFilterChips(
                      selectedFilter: _selectedFilter,
                      onSelected: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: StudentsList(
                        students: _filteredStudents(value),
                        physics: const AlwaysScrollableScrollPhysics(),
                        emptyMessage:
                            'Nenhum aluno encontrado para esta busca/filtro.',
                        onStudentTap: (student) {
                          context.push('/alunos/${student.id}', extra: student);
                        },
                      ),
                    ),
                  ],
                ),
                AsyncError() => Center(
                  child: Text(
                    'Não foi possível carregar os alunos.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
    );
  }
}
