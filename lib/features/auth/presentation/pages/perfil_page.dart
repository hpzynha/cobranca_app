import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/widgets/app_toast.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});

  @override
  ConsumerState<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends ConsumerState<PerfilPage> {
  bool _isSavingName = false;
  bool _isSendingReset = false;

  String get _fullName {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String?;
    return name?.trim().isNotEmpty == true ? name!.trim() : '';
  }

  String get _email =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  String get _initials {
    final name = _fullName;
    if (name.isEmpty) return _email.isNotEmpty ? _email[0].toUpperCase() : '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _fullName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome completo',
            hintText: 'Ex: João Silva',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final newName = controller.text.trim();
    if (newName.isEmpty || newName == _fullName) return;

    setState(() => _isSavingName = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );
      ref.invalidate(currentUserNameProvider);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) AppToast.error(context, 'Não foi possível atualizar o nome.');
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.isEmpty) return;
    setState(() => _isSendingReset = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(_email);
      if (mounted) AppToast.success(context, 'Email de redefinição enviado para $_email');
    } catch (e) {
      if (mounted) AppToast.error(context, 'Não foi possível enviar o email.');
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentsAsync = ref.watch(studentPaymentItemsProvider);
    final balanceAsync = ref.watch(monthlyBalanceProvider);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final horizontalPadding = AppResponsive.size(context, 20).clamp(16.0, 28.0);

    final cardColor = isDark ? const Color(0xFF1A1A28) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF2a2a45) : const Color(0xFFE9EAED);
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textStrong;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final pageBg = isDark ? AppColors.backgroundDark : AppColors.background;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ──────────────────────────────────
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                label: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Hero ─────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      child: _isSavingName
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _initials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppResponsive.fontSize(context, 24),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _fullName.isNotEmpty ? _fullName : 'Sem nome',
                          style: TextStyle(
                            fontSize: AppResponsive.fontSize(context, 18),
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _editName,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: TextStyle(fontSize: AppResponsive.fontSize(context, 12), color: textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Stats cards ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Alunos',
                      value: studentsAsync.when(
                        data: (list) => '${list.length}',
                        loading: () => '—',
                        error: (_, __) => '—',
                      ),
                      icon: Icons.groups_2_outlined,
                      cardColor: cardColor,
                      borderColor: cardBorderColor,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Receita mensal',
                      value: balanceAsync.when(
                        data: (v) => currency.format(v),
                        loading: () => '—',
                        error: (_, __) => '—',
                      ),
                      icon: Icons.attach_money_rounded,
                      cardColor: cardColor,
                      borderColor: cardBorderColor,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Seção Conta ──────────────────────────────────
              Text(
                'Conta',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorderColor),
                ),
                child: Column(
                  children: [
                    _AccountTile(
                      icon: Icons.lock_outline,
                      label: 'Alterar senha',
                      loading: _isSendingReset,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      onTap: _resetPassword,
                      isFirst: true,
                      isLast: false,
                      borderColor: cardBorderColor,
                    ),
                    _AccountTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notificações',
                      loading: false,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      onTap: () => AppToast.info(context, 'Em breve disponível.'),
                      isFirst: false,
                      isLast: true,
                      borderColor: cardBorderColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: AppResponsive.fontSize(context, 18),
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: textMuted)),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onTap,
    required this.textPrimary,
    required this.textMuted,
    required this.isFirst,
    required this.isLast,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textMuted;
  final bool isFirst;
  final bool isLast;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(18) : Radius.zero,
            bottom: isLast ? const Radius.circular(18) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: textMuted),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: AppResponsive.fontSize(context, 13),
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: textMuted,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: borderColor, indent: 50),
      ],
    );
  }
}
