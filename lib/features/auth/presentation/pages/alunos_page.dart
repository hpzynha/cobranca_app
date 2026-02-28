import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/students_filter_chips.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/students_search_field.dart';
import 'package:flutter/material.dart';

class AlunosPage extends StatefulWidget {
  const AlunosPage({super.key});

  @override
  State<AlunosPage> createState() => _AlunosPageState();
}

class _AlunosPageState extends State<AlunosPage> {
  final TextEditingController _searchController = TextEditingController();
  StudentsFilter _selectedFilter = StudentsFilter.all;
  String _searchQuery = '';

  List<StudentPaymentItem> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();

    return kMockStudentPayments.where((student) {
      final matchesFilter = switch (_selectedFilter) {
        StudentsFilter.all => true,
        StudentsFilter.overdue => student.status == StudentPaymentStatus.overdue,
        StudentsFilter.dueSoon => student.status == StudentPaymentStatus.dueSoon,
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
              StudentsSearchField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
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
                  students: _filteredStudents,
                  physics: const BouncingScrollPhysics(),
                  emptyMessage:
                      'Nenhum aluno encontrado para esta busca/filtro.',
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
