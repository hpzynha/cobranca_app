import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/core/widgets/app_toast.dart';
import 'package:app_cobranca/features/subscription/domain/entities/coupon.dart';
import 'package:app_cobranca/features/subscription/presentation/providers/user_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  final _couponController = TextEditingController();
  Coupon? _appliedCoupon;
  bool _isValidatingCoupon = false;
  bool _isActivating = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _validateCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
      _appliedCoupon = null;
    });

    final result = await ref.read(validateCouponUseCaseProvider).call(code);

    if (!mounted) return;
    setState(() => _isValidatingCoupon = false);

    if (!result.isSuccess) {
      AppToast.error(context, result.failure?.message ?? 'Cupom inválido.');
      return;
    }

    setState(() => _appliedCoupon = result.data);
    AppToast.success(context, result.data!.message);
  }

  Future<void> _activateAdminCoupon() async {
    final coupon = _appliedCoupon;
    if (coupon == null || !coupon.isAdmin) return;

    setState(() => _isActivating = true);

    final result = await ref.read(activateAdminCouponUseCaseProvider).call(coupon.code);

    if (!mounted) return;
    setState(() => _isActivating = false);

    if (!result.isSuccess) {
      AppToast.error(context, result.failure?.message ?? 'Erro ao ativar.');
      return;
    }

    AppToast.success(context, 'Plano Pro ativado com sucesso!');
    if (mounted) context.pop();
  }

  Future<void> _openCheckout() async {
    setState(() => _isActivating = true);

    final result = await ref
        .read(subscriptionRemoteDataSourceProvider)
        .createBilling();

    if (!mounted) return;
    setState(() => _isActivating = false);

    if (!result.isSuccess) {
      AppToast.error(context, result.failure?.message ?? 'Erro ao gerar cobrança.');
      return;
    }

    final uri = Uri.parse(result.data!);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) AppToast.error(context, 'Não foi possível abrir o link de pagamento.');
    }
  }

  String _formatPrice(int cents) {
    final reais = cents / 100;
    return 'R\$${reais.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6);
    final cardBg = isDark ? const Color(0xFF1A1A28) : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : const Color(0xFF6B7280);
    final fieldBg = isDark ? const Color(0xFF12121E) : const Color(0xFFF3F4F6);
    final fieldBorder = isDark ? const Color(0xFF2a2a45) : const Color(0xFFD9DCE3);

    final coupon = _appliedCoupon;
    final basePriceCents = 3990;
    final displayPriceCents = coupon != null ? coupon.finalPriceCents : basePriceCents;
    final hasDiscount = coupon != null && coupon.discountPercent > 0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: muted),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.size(context, 20).clamp(16.0, 28.0),
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ─────────────────────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Desbloqueie o Pro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppResponsive.fontSize(context, 26),
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tudo que você precisa para gerenciar seus alunos sem limites.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppResponsive.fontSize(context, 14),
                  color: muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // ── Benefits card ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BenefitRow(
                      icon: Icons.people_alt_outlined,
                      text: 'Até 50 alunos',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _BenefitRow(
                      icon: Icons.chat_rounded,
                      text: 'Envio automático de cobranças via WhatsApp',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _BenefitRow(
                      icon: Icons.bar_chart_rounded,
                      text: 'Relatórios completos de recebimentos',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Coupon field ────────────────────────────────────────
              Text(
                'Tem um cupom?',
                style: TextStyle(
                  fontSize: AppResponsive.fontSize(context, 15),
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(
                        fontSize: AppResponsive.fontSize(context, 15),
                        color: textPrimary,
                        letterSpacing: 1.2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ex: LAUNCH20',
                        hintStyle: TextStyle(
                          color: muted,
                          fontSize: AppResponsive.fontSize(context, 15),
                          letterSpacing: 0,
                        ),
                        filled: true,
                        fillColor: fieldBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColors.primary, width: 1.8),
                        ),
                        suffixIcon: coupon != null
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                            : null,
                      ),
                      onSubmitted: (_) => _validateCoupon(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _isValidatingCoupon ? null : _validateCoupon,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: _isValidatingCoupon
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Aplicar',
                              style: TextStyle(
                                fontSize: AppResponsive.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              // ── Coupon feedback ─────────────────────────────────────
              if (coupon != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_rounded, color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          coupon.message,
                          style: TextStyle(
                            fontSize: AppResponsive.fontSize(context, 13),
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Price display ───────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        _formatPrice(basePriceCents),
                        style: TextStyle(
                          fontSize: AppResponsive.fontSize(context, 16),
                          color: muted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: coupon?.isAdmin == true
                                ? 'Grátis'
                                : _formatPrice(displayPriceCents),
                            style: TextStyle(
                              fontSize: AppResponsive.fontSize(context, 32),
                              fontWeight: FontWeight.w800,
                              color: coupon?.isAdmin == true ? AppColors.success : textPrimary,
                            ),
                          ),
                          if (coupon?.isAdmin != true)
                            TextSpan(
                              text: '/mês',
                              style: TextStyle(
                                fontSize: AppResponsive.fontSize(context, 16),
                                color: muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── CTA buttons ─────────────────────────────────────────
              if (coupon?.isAdmin == true) ...[
                SizedBox(
                  height: AppResponsive.size(context, 52).clamp(48.0, 56.0),
                  child: FilledButton.icon(
                    onPressed: _isActivating ? null : _activateAdminCoupon,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      disabledBackgroundColor: AppColors.success.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    icon: _isActivating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: Text(
                      'Ativar agora — sem pagamento',
                      style: TextStyle(
                        fontSize: AppResponsive.fontSize(context, 15),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  height: AppResponsive.size(context, 52).clamp(48.0, 56.0),
                  child: FilledButton(
                    onPressed: _isActivating ? null : _openCheckout,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: _isActivating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Assinar Pro — ${_formatPrice(displayPriceCents)}/mês',
                            style: TextStyle(
                              fontSize: AppResponsive.fontSize(context, 15),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Continuar no plano gratuito',
                  style: TextStyle(
                    fontSize: AppResponsive.fontSize(context, 14),
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppResponsive.fontSize(context, 14),
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
