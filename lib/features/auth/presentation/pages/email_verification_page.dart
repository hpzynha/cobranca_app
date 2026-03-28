import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/widgets/app_toast.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/features/auth/presentation/providers/email_verification_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleSize = AppResponsive.fontSize(context, 22, min: 0.92, max: 1.08);
    final emailSize = AppResponsive.fontSize(context, 15, min: 0.95, max: 1.08);

    ref.listen(emailVerificationNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (state) {
          if (state.errorMessage != null) {
            AppToast.error(context, state.errorMessage!);
          }

          if (state.infoMessage != null) {
            AppToast.info(context, state.infoMessage!);
          }

          if (state.isVerified) {
            context.go('/login');
          }
        },
      );
    });

    final state = ref.watch(emailVerificationNotifierProvider);
    final isLoading = state.isLoading;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: const Text('Verificação de e-mail'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Nós enviamos um e-mail de verificação para o seu endereço de e-mail.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: emailSize,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () => ref
                              .read(emailVerificationNotifierProvider.notifier)
                              .resendEmail(email),
                  child: const Text('Reenviar e-mail'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: TextButton(
                  onPressed: isLoading ? null : () => context.go('/login'),
                  child: const Text('Voltar ao login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
