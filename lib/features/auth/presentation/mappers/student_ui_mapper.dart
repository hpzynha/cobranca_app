import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';

StudentPaymentItem toStudentPaymentItem(Student student) {
  final now = DateTime.now();
  final status =
      student.dueDay < now.day
          ? StudentPaymentStatus.overdue
          : StudentPaymentStatus.dueSoon;

  return StudentPaymentItem(
    initials: _initialsFromName(student.name),
    name: student.name,
    dueLabel: 'Venc. dia ${student.dueDay}',
    amountLabel: _formatCentsToBrl(student.monthlyFeeCents),
    status: status,
  );
}

String _initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

  if (parts.isEmpty) {
    return '--';
  }

  if (parts.length == 1) {
    return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _formatCentsToBrl(int cents) {
  final value = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $value';
}
