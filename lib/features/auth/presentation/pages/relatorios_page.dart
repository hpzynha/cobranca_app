import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/venzza_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RelatoriosPage extends ConsumerWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(monthlyReportProvider);
    final isCompact = AppResponsive.isCompact(context);
    final padding = AppResponsive.size(context, isCompact ? 14 : 16).clamp(
      12.0,
      22.0,
    );
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', 'pt_BR').format(now);

    return Scaffold(
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VenzzaAppBar(title: 'Relatórios'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 20, padding, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(monthLabel),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  switch (reportAsync) {
                    AsyncData(:final value) => _ReportCards(
                      expectedCents: value.expectedCents,
                      receivedCents: value.receivedCents,
                      pendingCents: value.pendingCents,
                    ),
                    AsyncError(:final error) => _ErrorCard(
                      message: error.toString().replaceFirst('Exception: ', ''),
                    ),
                    _ => const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 2),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _ReportCards extends StatelessWidget {
  const _ReportCards({
    required this.expectedCents,
    required this.receivedCents,
    required this.pendingCents,
  });

  final int expectedCents;
  final int receivedCents;
  final int pendingCents;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FinanceCard(
          label: 'Esperado',
          amountCents: expectedCents,
          color: AppColors.primary,
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 12),
        _FinanceCard(
          label: 'Recebido',
          amountCents: receivedCents,
          color: AppColors.success,
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        _FinanceCard(
          label: 'Pendente',
          amountCents: pendingCents,
          color: pendingCents > 0 ? AppColors.danger : AppColors.success,
          icon: pendingCents > 0
              ? Icons.warning_amber_rounded
              : Icons.check_circle_outline_rounded,
        ),
      ],
    );
  }
}

class _FinanceCard extends StatelessWidget {
  const _FinanceCard({
    required this.label,
    required this.amountCents,
    required this.color,
    required this.icon,
  });

  final String label;
  final int amountCents;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final amount = amountCents / 100.0;
    final formatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatted,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
      ),
    );
  }
}
