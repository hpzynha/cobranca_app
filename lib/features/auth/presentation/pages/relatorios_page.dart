import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RelatoriosPage extends ConsumerWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(monthlyReportProvider);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Relatórios')),
      body: reportAsync.when(
        data: (report) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Esperado: ${currency.format(report.expectedCents / 100)}'),
                Text('Recebido: ${currency.format(report.receivedCents / 100)}'),
                Text('Pendente: ${currency.format(report.pendingCents / 100)}'),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 3),
    );
  }
}
