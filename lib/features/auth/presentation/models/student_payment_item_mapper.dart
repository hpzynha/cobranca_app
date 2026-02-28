import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:intl/intl.dart';

extension StudentPaymentItemMapper on List<Student> {
  List<StudentPaymentItem> toPaymentItems([DateTime? now]) {
    final referenceDate = _dateOnly(now ?? DateTime.now());
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dueDateFormat = DateFormat('dd/MM/yyyy');

    return map((student) {
      final status = _statusForStudent(student, referenceDate);
      final dueDate = student.nextDueDate;
      return StudentPaymentItem(
        initials: _buildInitials(student.name),
        name: student.name,
        dueLabel:
            dueDate == null
                ? 'Sem vencimento definido'
                : 'Venc. ${dueDateFormat.format(dueDate)}',
        amountLabel: currency.format(student.monthlyFeeCents / 100),
        status: status,
      );
    }).toList();
  }
}

StudentPaymentStatus _statusForStudent(Student student, DateTime now) {
  final nextDueDate =
      student.nextDueDate == null ? null : _dateOnly(student.nextDueDate!);
  final lastPaymentDate =
      student.lastPaymentDate == null
          ? null
          : _dateOnly(student.lastPaymentDate!);

  if (nextDueDate == null) {
    return StudentPaymentStatus.open;
  }

  if (lastPaymentDate != null && !lastPaymentDate.isBefore(nextDueDate)) {
    return StudentPaymentStatus.paid;
  }

  if (now.isAfter(nextDueDate)) {
    return StudentPaymentStatus.overdue;
  }

  if (now.isAtSameMomentAs(nextDueDate)) {
    return StudentPaymentStatus.dueToday;
  }

  return StudentPaymentStatus.open;
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

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
