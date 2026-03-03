import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDetailsPage extends ConsumerWidget {
  const StudentDetailsPage({
    super.key,
    required this.studentId,
    this.initialStudent,
  });

  final String studentId;
  final StudentPaymentItem? initialStudent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentPaymentItemsProvider);
    StudentPaymentItem? studentFromList;
    final cachedStudents = studentsAsync.valueOrNull;
    if (cachedStudents != null) {
      for (final item in cachedStudents) {
        if (item.id == studentId) {
          studentFromList = item;
          break;
        }
      }
    }
    final student = studentFromList ?? initialStudent;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aluno')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final paymentStatus = student.status;
    final shouldShowChargeButton = {
      StudentPaymentStatus.overdue,
      StudentPaymentStatus.dueSoon,
      StudentPaymentStatus.pending,
    }.contains(paymentStatus);

    final isActive = paymentStatus == StudentPaymentStatus.paid;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StudentAvatar(student: student),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          student.amountLabel,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoTile(
                label: 'Vencimento',
                value: _formatDueDate(student),
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Status',
                value: isActive ? 'Ativo' : 'Inativo',
                trailing: _PaymentStatusBadge(status: paymentStatus),
              ),
              const SizedBox(height: 28),
              Text('Histórico', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              ..._buildHistory(student),
              const SizedBox(height: 24),
              if (shouldShowChargeButton)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsPaid(context, ref, student),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Marcar como pago'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openWhatsApp(student),
                        icon: const Icon(Icons.chat_bubble_rounded),
                        label: const Text('Enviar mensagem no WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsPaid(
    BuildContext context,
    WidgetRef ref,
    StudentPaymentItem student,
  ) async {
    if (student.dueDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar o vencimento do aluno.')),
      );
      return;
    }

    final result = await ref
        .read(markStudentAsPaidUseCaseProvider)
        .call(
          studentId: student.id,
          dueDay: student.dueDay!,
          currentNextDueDate: student.nextDueDate,
        );

    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failure?.message ?? 'Não foi possível marcar como pago.',
          ),
        ),
      );
      return;
    }

    ref.invalidate(studentsProvider);
    ref.invalidate(studentPaymentItemsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pagamento marcado com sucesso.')),
    );
  }

  List<Widget> _buildHistory(StudentPaymentItem student) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    if (student.lastPaymentDate == null) {
      return const [
        Text(
          'Nenhum pagamento registrado',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ];
    }

    final month = DateFormat('MMMM yyyy', 'pt_BR').format(student.lastPaymentDate!);
    final date = DateFormat('dd/MM/yyyy').format(student.lastPaymentDate!);

    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.circle, color: AppColors.success, size: 12),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(month, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                  Text('Pago em $date', style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
                ],
              ),
            ),
            Text(currency.format(_amountFromLabel(student.amountLabel)), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
      ),
    ];
  }

  double _amountFromLabel(String amountLabel) {
    final normalized = amountLabel.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  String _formatDueDate(StudentPaymentItem student) {
    if (student.nextDueDate != null) {
      return DateFormat('dd/MM/yyyy').format(student.nextDueDate!);
    }
    if (student.dueDay != null) {
      return 'Dia ${student.dueDay}';
    }
    return '--';
  }

  Future<void> _openWhatsApp(StudentPaymentItem student) async {
    final phone = student.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final message =
        'Olá, ${student.name}! Tudo bem?\n'
        'Seu pagamento de ${student.amountLabel} está com status "${student.status.label}".\n'
        'Pode me confirmar por aqui, por favor?';
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.student});

  final StudentPaymentItem student;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = student.photoUrl != null && student.photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: 52,
      backgroundColor: const Color(0xFFE9EDF1),
      backgroundImage: hasPhoto ? NetworkImage(student.photoUrl!) : null,
      child: hasPhoto
          ? null
          : Text(
              student.initials,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: AppColors.textMuted)),
          const Spacer(),
          if (trailing != null) trailing! else Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final StudentPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontWeight: FontWeight.w700, color: status.foreground),
      ),
    );
  }
}
