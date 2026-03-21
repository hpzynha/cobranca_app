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
        id: student.id,
        initials: _buildInitials(student.name),
        name: student.name,
        whatsapp: student.whatsapp,
        dueLabel:
            dueDate == null
                ? 'Sem vencimento definido'
                : 'Venc. ${dueDateFormat.format(dueDate)}',
        amountLabel: currency.format(student.monthlyFeeCents / 100),
        monthlyFeeCents: student.monthlyFeeCents,
        status: status,
        photoUrl: student.photoUrl,
        dueDay: student.dueDay,
        nextDueDate: student.nextDueDate,
        lastPaymentDate: student.lastPaymentDate,
      );
    }).toList();
  }
}

StudentPaymentStatus _statusForStudent(Student student, DateTime now) {
  final backendStatus = _statusFromBackend(student.paymentStatusCode);
  if (backendStatus != null) {
    return backendStatus;
  }

  final nextDueDate =
      student.nextDueDate == null ? null : _dateOnly(student.nextDueDate!);
  final lastPaymentDate =
      student.lastPaymentDate == null
          ? null
          : _dateOnly(student.lastPaymentDate!);

  if (nextDueDate == null) {
    return StudentPaymentStatus.pending;
  }

  if (lastPaymentDate != null) {
    if (!lastPaymentDate.isBefore(nextDueDate)) {
      return StudentPaymentStatus.paid;
    }

    final previousDueDate = _previousDueDate(nextDueDate, student.dueDay);
    final paidCurrentCycle =
        !lastPaymentDate.isBefore(previousDueDate) &&
        lastPaymentDate.isBefore(nextDueDate);
    if (paidCurrentCycle) {
      return StudentPaymentStatus.paid;
    }
  }

  if (now.isAfter(nextDueDate)) {
    return StudentPaymentStatus.overdue;
  }

  final daysToDue = nextDueDate.difference(now).inDays;
  if (daysToDue <= 2) {
    return StudentPaymentStatus.dueSoon;
  }

  return StudentPaymentStatus.pending;
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

DateTime _previousDueDate(DateTime nextDueDate, int dueDay) {
  final previousMonth = DateTime(nextDueDate.year, nextDueDate.month - 1);
  final clampedDay = _clampDay(previousMonth.year, previousMonth.month, dueDay);
  return DateTime(previousMonth.year, previousMonth.month, clampedDay);
}

int _clampDay(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return day.clamp(1, lastDay);
}

StudentPaymentStatus? _statusFromBackend(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'paid':
      return StudentPaymentStatus.paid;
    case 'overdue':
      return StudentPaymentStatus.overdue;
    case 'due_soon':
      return StudentPaymentStatus.dueSoon;
    case 'pending':
      return StudentPaymentStatus.pending;
    default:
      return null;
  }
}
