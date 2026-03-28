import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/widgets/app_toast.dart';
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
  bool _isPerformingAction = false;
  bool? _isActiveLocal; // null = use student.isActive

  bool _effectiveIsActive(StudentPaymentItem student) =>
      _isActiveLocal ?? student.isActive;

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
    final isActive = _effectiveIsActive(student);

    final shouldShowChargeButton =
        isActive &&
        {
          StudentPaymentStatus.overdue,
          StudentPaymentStatus.dueSoon,
          StudentPaymentStatus.pending,
        }.contains(paymentStatus);

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
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Badge de inativo
              if (!isActive) ...[
                _InactiveBanner(
                  onReactivate: _isPerformingAction
                      ? null
                      : () => _reactivate(student),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  _StudentAvatar(student: student, isActive: isActive),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: isActive ? null : AppColors.textMuted,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          student.amountLabel,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
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
                value: '',
                trailing: isActive
                    ? _PaymentStatusBadge(status: paymentStatus)
                    : _InactiveBadge(),
              ),
              const SizedBox(height: 28),
              Text(
                'Histórico',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              ..._buildHistory(student),
              const SizedBox(height: 24),

              // Botões de cobrança (só se ativo)
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
                        onPressed:
                            _isMarkingAsPaid
                                ? null
                                : () => _openWhatsApp(student),
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
              if (isActive && paymentStatus == StudentPaymentStatus.paid) ...[
                const SizedBox(height: 8),
                const _PaymentConfirmedCard(),
              ],

              // Divisor "ações"
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'ações',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),

              // Botões Inativar/Reativar + Deletar
              Row(
                children: [
                  Expanded(
                    child: isActive
                        ? _DangerButton(
                            label: 'Inativar',
                            icon: Icons.block_rounded,
                            color: AppColors.warning,
                            onTap: _isPerformingAction
                                ? null
                                : () => _showInactivateSheet(student),
                          )
                        : _DangerButton(
                            label: 'Reativar',
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.primary,
                            onTap: _isPerformingAction
                                ? null
                                : () => _reactivate(student),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DangerButton(
                      label: 'Deletar',
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      onTap: _isPerformingAction
                          ? null
                          : () => _showDeleteSheet(student),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
      AppToast.error(context, result.failure?.message ?? 'Não foi possível marcar como pago.');
      return;
    }

    setState(() {
      _isMarkingAsPaid = false;
      _paidConfirmedLocal = true;
    });

    // Optimistic update: patch the student in the cache immediately so the
    // list reflects "Pago" before the background refresh completes.
    final currentStudents = ref.read(studentsProvider).valueOrNull;
    final matched = currentStudents?.where((s) => s.id == student.id).firstOrNull;
    if (matched != null) {
      ref
          .read(studentsProvider.notifier)
          .updateStudent(matched.copyWith(paymentStatusCode: 'paid'));
    }

    // Refresh the list silently (no loading indicator) and update the report.
    ref.read(studentsProvider.notifier).silentRefresh();
    ref.invalidate(monthlyReportProvider);
  }

  void _showInactivateSheet(StudentPaymentItem student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        icon: Icons.block_rounded,
        iconColor: AppColors.warning,
        title: 'Inativar este aluno?',
        message:
            'O aluno ficará oculto na lista principal mas o histórico de pagamentos será preservado. Você pode reativá-lo a qualquer momento.',
        confirmLabel: 'Inativar aluno',
        confirmColor: AppColors.warning,
        onConfirm: () {
          Navigator.pop(context);
          _inactivate(student);
        },
      ),
    );
  }

  void _showDeleteSheet(StudentPaymentItem student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.danger,
        title: 'Deletar permanentemente?',
        message:
            '⚠ Esta ação não pode ser desfeita. Todo o histórico de pagamentos deste aluno será perdido para sempre.',
        confirmLabel: 'Sim, deletar',
        confirmColor: AppColors.danger,
        onConfirm: () {
          Navigator.pop(context);
          _delete(student);
        },
      ),
    );
  }

  Future<void> _inactivate(StudentPaymentItem student) async {
    setState(() => _isPerformingAction = true);
    final result = await ref
        .read(studentRepositoryProvider)
        .inactivateStudent(studentId: student.id);
    if (!mounted) return;
    setState(() {
      _isPerformingAction = false;
      if (result.isSuccess) _isActiveLocal = false;
    });
    if (result.isSuccess) {
      ref.invalidate(studentsProvider);
      ref.invalidate(studentPaymentItemsProvider);
    } else {
      AppToast.error(context, result.failure?.message ?? 'Erro ao inativar aluno.');
    }
  }

  Future<void> _reactivate(StudentPaymentItem student) async {
    setState(() => _isPerformingAction = true);
    final result = await ref
        .read(studentRepositoryProvider)
        .reactivateStudent(studentId: student.id);
    if (!mounted) return;
    setState(() {
      _isPerformingAction = false;
      if (result.isSuccess) _isActiveLocal = true;
    });
    if (result.isSuccess) {
      ref.invalidate(studentsProvider);
      ref.invalidate(studentPaymentItemsProvider);
    } else {
      AppToast.error(context, result.failure?.message ?? 'Erro ao reativar aluno.');
    }
  }

  Future<void> _delete(StudentPaymentItem student) async {
    setState(() => _isPerformingAction = true);
    final result = await ref
        .read(studentRepositoryProvider)
        .deleteStudent(studentId: student.id);
    if (!mounted) return;
    if (result.isSuccess) {
      ref.invalidate(studentsProvider);
      ref.invalidate(studentPaymentItemsProvider);
      ref.invalidate(monthlyReportProvider);
      context.pop();
    } else {
      setState(() => _isPerformingAction = false);
      AppToast.error(context, result.failure?.message ?? 'Erro ao deletar aluno.');
    }
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

    final month = DateFormat(
      'MMMM yyyy',
      'pt_BR',
    ).format(student.lastPaymentDate!);
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
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textStrong,
                    ),
                  ),
                  Text(
                    'Pago em $date',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted,
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
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textStrong,
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
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _InactiveBanner extends StatelessWidget {
  const _InactiveBanner({this.onReactivate});

  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Aluno inativo — não aparece nas cobranças',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
          if (onReactivate != null)
            GestureDetector(
              onTap: onReactivate,
              child: Text(
                'Reativar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InactiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Inativo',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.student, required this.isActive});

  final StudentPaymentItem student;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = student.photoUrl != null && student.photoUrl!.isNotEmpty;
    return ColorFiltered(
      colorFilter: isActive
          ? const ColorFilter.mode(Colors.transparent, BlendMode.saturation)
          : const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
      child: CircleAvatar(
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
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textStrong,
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
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: status.foreground,
        ),
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
