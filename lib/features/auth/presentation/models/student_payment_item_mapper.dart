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
        isActive: student.isActive,
      );
    }).toList();
  }
}

StudentPaymentStatus _statusForStudent(Student student, DateTime now) {
  final nextDueDate =
      student.nextDueDate == null ? null : _dateOnly(student.nextDueDate!);
  final lastPayment =
      student.lastPaymentDate == null ? null : _dateOnly(student.lastPaymentDate!);

  // 1. paid: has a payment and the next due date has not arrived yet.
  // _paidInCurrentCycle covers the standard case; the OR covers early payers
  // whose lastPaymentDate falls before the cycleStart (e.g. paid on the 9th
  // when due_day = 10, so next_due_date advanced to next month's 10th).
  if (_paidInCurrentCycle(student, now) ||
      (lastPayment != null && nextDueDate != null && now.isBefore(nextDueDate))) {
    return StudentPaymentStatus.paid;
  }

  if (nextDueDate == null) {
    return _statusFromBackend(student.paymentStatusCode) ??
        StudentPaymentStatus.pending;
  }

  // 2. due_soon: 3 days or fewer until due date (inclusive of the due date itself)
  final daysToDue = nextDueDate.difference(now).inDays;
  if (daysToDue <= 3 && !now.isAfter(nextDueDate)) {
    return StudentPaymentStatus.dueSoon;
  }

  // 3. overdue: past the due date
  if (now.isAfter(nextDueDate)) {
    return StudentPaymentStatus.overdue;
  }

  return StudentPaymentStatus.pending;
}

/// Retorna true se o [lastPaymentDate] do aluno está dentro do ciclo atual,
/// ou seja, é maior ou igual ao início do ciclo (nextDueDate - 1 mês).
/// Só considera ciclo atual quando nextDueDate ainda não venceu.
bool _paidInCurrentCycle(Student student, DateTime now) {
  final lastPayment = student.lastPaymentDate;
  final nextDue = student.nextDueDate;
  if (lastPayment == null || nextDue == null) return false;

  final nextDueOnly = _dateOnly(nextDue);
  // Se o vencimento já passou, deixa a lógica de overdue/pending assumir
  if (!nextDueOnly.isAfter(now)) return false;

  // Início do ciclo = mesmo dia do mês, 1 mês antes do próximo vencimento
  final cycleStart = DateTime(
    nextDueOnly.month > 1 ? nextDueOnly.year : nextDueOnly.year - 1,
    nextDueOnly.month > 1 ? nextDueOnly.month - 1 : 12,
    nextDueOnly.day,
  );
  return !_dateOnly(lastPayment).isBefore(cycleStart);
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
