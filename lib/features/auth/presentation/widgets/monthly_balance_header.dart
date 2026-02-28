import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyBalanceHeader extends StatelessWidget {
  final double amount;

  const MonthlyBalanceHeader({super.key, required this.amount});

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saldo previsto do mês",
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        Text(
          _formatCurrency(amount),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
