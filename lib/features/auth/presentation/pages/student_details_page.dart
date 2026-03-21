import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDetailsPage extends ConsumerStatefulWidget {
  const StudentDetailsPage({
    super.key,
    required this.studentId,
    this.initialStudent,
  });

  final String studentId;
  final StudentPaymentItem? initialStudent;

  @override
  ConsumerState<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends ConsumerState<StudentDetailsPage> {
  bool _paidConfirmedLocal = false;
  bool _isMarkingAsPaid = false;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentPaymentItemsProvider);
    StudentPaymentItem? studentFromList;
    final cachedStudents = studentsAsync.valueOrNull;
    if (cachedStudents != null) {
      for (final item in cachedStudents) {
        if (item.id == widget.studentId) {
          studentFromList = item;
          break;
        }
      }
    }
    final student = studentFromList ?? widget.initialStudent;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aluno')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final paymentStatus =
        _paidConfirmedLocal ? StudentPaymentStatus.paid : student.status;
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
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                label: const Text(
                  'Voltar',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
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
                        onPressed:
                            _isMarkingAsPaid
                                ? null
                                : () => _markAsPaid(context, student),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          _isMarkingAsPaid
                              ? 'Marcando pagamento...'
                              : 'Marcar como pago',
                        ),
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
                        onPressed: _isMarkingAsPaid ? null : () => _openWhatsApp(student),
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
              if (paymentStatus == StudentPaymentStatus.paid) ...[
                const SizedBox(height: 8),
                const _PaymentConfirmedCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsPaid(
    BuildContext context,
    StudentPaymentItem student,
  ) async {
    setState(() => _isMarkingAsPaid = true);

    final result = await ref
        .read(markStudentAsPaidUseCaseProvider)
        .call(studentId: student.id);

    if (!context.mounted) return;

    if (!result.isSuccess) {
      setState(() => _isMarkingAsPaid = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failure?.message ?? 'Não foi possível marcar como pago.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isMarkingAsPaid = false;
      _paidConfirmedLocal = true;
    });

    ref.invalidate(studentsProvider);
    ref.invalidate(studentPaymentItemsProvider);

  }

  List<Widget> _buildHistory(StudentPaymentItem student) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    if (student.lastPaymentDate == null) {
      return [
        Text(
          'Nenhum pagamento registrado',
          style: TextStyle(
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
          ),
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
          color: isDark ? const Color(0xFF1A1A28) : Colors.white,
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
                  Text(
                    month,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textStrong,
                    ),
                  ),
                  Text(
                    'Pago em $date',
                    style: TextStyle(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              currency.format(student.monthlyFeeCents / 100),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textStrong,
              ),
            ),
          ],
        ),
      ),
    ];
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
      backgroundColor: AppColors.primary,
      backgroundImage: hasPhoto ? NetworkImage(student.photoUrl!) : null,
      child: hasPhoto
          ? null
          : Text(
              student.initials,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Colors.white,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A28) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            trailing!
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textStrong,
              ),
            ),
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

class _PaymentConfirmedCard extends StatelessWidget {
  const _PaymentConfirmedCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.success.withValues(alpha: 0.15)
            : const Color(0xFFE6F4EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
          SizedBox(width: 12),
          Text(
            'Pagamento confirmado',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
