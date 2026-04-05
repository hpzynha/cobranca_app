import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/widgets/app_toast.dart';
import 'package:app_cobranca/features/auth/domain/entities/signup_result.dart';
import 'package:app_cobranca/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_cobranca/features/auth/presentation/providers/sign_up_notifier.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = AuthController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      AppToast.error(context, 'As senhas não coincidem.');
      return;
    }

    await ref.read(signUpNotifierProvider.notifier).signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    final result = ref.read(signUpNotifierProvider);
    if (!mounted) return;

    result.whenOrNull(
      data: (data) {
        if (data == null) return;
        if (data.status == SignUpStatus.requiresEmailVerification) {
          context.go('/email-verification', extra: data.email);
          return;
        }
        context.go('/login');
      },
      error: (error, _) {
        AppToast.error(context, error.toString());
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpNotifierProvider);
    final isLoading = state.isLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final backBtnBg =
        isDark ? const Color(0xFF1A1A28) : const Color(0xFFF0F1F5);
    final backIconColor =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);
    final titleColor = backIconColor;
    final heroBorderColor =
        isDark ? const Color(0xFF1A1A28) : const Color(0xFFF0F1F5);
    final dividerColor =
        isDark ? const Color(0xFF252535) : const Color(0xFFE8EAF0);
    final footerColor =
        isDark ? const Color(0xFF5a5a72) : const Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────
            Container(
              height: 52,
              color: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: backBtnBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: backIconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_add_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Crie sua conta',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: titleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      'Comece a automatizar suas cobranças.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: heroBorderColor,
                            ),
                          ],
                        ),
                      ),

                      // Campos
                      AuthTextField(
                        label: 'Nome completo',
                        hint: 'Ex: Maria Silva',
                        controller: _nameController,
                        suffixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: Icons.mail_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite seu e-mail';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: 'Senha',
                        hint: 'Mín. 8 caracteres',
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'Senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: 'Confirmar senha',
                        hint: 'Repita a senha',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 18),

                      // Botão cadastrar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: dividerColor,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ou',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: dividerColor,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Google
                      SocialAuthButton(
                        text: 'Continuar com Google',
                        logoPath: 'assets/images/google_logo.svg',
                        onPressed: () async {
                          try {
                            await _authController.signInWithGoogle();
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(context, 'Erro ao entrar com Google: $e');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Footer
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: footerColor,
                              ),
                              children: const [
                                TextSpan(text: 'Já tem conta? '),
                                TextSpan(
                                  text: 'Entrar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
