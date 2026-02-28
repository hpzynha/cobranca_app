import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Relatórios')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _ReportCard(title: 'Mensal', icon: Icons.calendar_month_outlined),
          _ReportCard(title: 'Pagamentos', icon: Icons.payments_outlined),
          _ReportCard(title: 'Pendências', icon: Icons.warning_amber_outlined),
          _ReportCard(title: 'Resumo', icon: Icons.insert_chart_outlined),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 3),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
