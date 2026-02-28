import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/presentation/providers/email_verification_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({
    required this.email,
    super.key,
  });

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(emailVerificationNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          if (state.infoMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.infoMessage!)));
          }

          if (state.isVerified) {
            context.go('/login');
          }
        },
      );
    });

    final state = ref.watch(emailVerificationNotifierProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verificação de e-mail')),
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
              const Text(
                'We sent you a verification email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                          .read(emailVerificationNotifierProvider.notifier)
                          .checkEmailVerification(),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.onPrimary,
                        )
                      : const Text(
                          'I have verified',
                          style: TextStyle(color: AppColors.onPrimary),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                          .read(emailVerificationNotifierProvider.notifier)
                          .resendEmail(email),
                  child: const Text('Resend email'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: TextButton(
                  onPressed: isLoading ? null : () => context.go('/login'),
                  child: const Text('Back to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
