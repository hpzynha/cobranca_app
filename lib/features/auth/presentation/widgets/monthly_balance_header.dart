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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final labelSize = (screenWidth * 0.046).clamp(14.0, 18.0);
    final amountSize = (screenWidth * 0.09).clamp(28.0, 36.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Saldo previsto do mês",
          style: TextStyle(fontSize: labelSize, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(height: 6),
        Text(
          _formatCurrency(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: amountSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
