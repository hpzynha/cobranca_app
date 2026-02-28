import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_text_styles.dart';
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
        Text(
          AppStrings.monthlyForecastBalance,
          style: AppTextStyles.responsive(
            context,
            AppTextStyles.dashboardSubtitle,
            baseSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatCurrency(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.responsive(
            context,
            AppTextStyles.dashboardAmount,
            baseSize: 36,
            min: 0.85,
          ),
        ),
      ],
    );
  }
}
