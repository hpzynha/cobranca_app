import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:intl/intl.dart';

extension StudentPaymentItemMapper on List<Student> {
  List<StudentPaymentItem> toPaymentItems([DateTime? now]) {
    final today = (now ?? DateTime.now()).day;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return map((student) {
      final status = _statusForDueDay(student.dueDay, today);
      return StudentPaymentItem(
        initials: _buildInitials(student.name),
        name: student.name,
        dueLabel: 'Venc. dia ${student.dueDay}',
        amountLabel: currency.format(student.monthlyFeeCents / 100),
        status: status,
      );
    }).toList();
  }
}

StudentPaymentStatus _statusForDueDay(int dueDay, int today) {
  if (dueDay < today) {
    return StudentPaymentStatus.overdue;
  }
  if (dueDay <= today + 5) {
    return StudentPaymentStatus.dueSoon;
  }
  return StudentPaymentStatus.paid;
}

String _buildInitials(String name) {
  final parts =
      name
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

  if (parts.isEmpty) {
    return '--';
  }

  if (parts.length == 1) {
    final first = parts.first;
    if (first.length == 1) {
      return first.toUpperCase();
    }
    return first.substring(0, 2).toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
