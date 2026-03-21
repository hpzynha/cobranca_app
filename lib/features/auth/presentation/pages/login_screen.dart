import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/data/auth_service.dart';
import 'package:app_cobranca/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/auth_options_row.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_email');
    if (saved != null) {
      setState(() {
        _emailController.text = saved;
        _rememberMe = true;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      if (response.session != null) {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('saved_email', _emailController.text.trim());
        } else {
          await prefs.remove('saved_email');
        }
        if (!mounted) return;
        context.go('/home');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro inesperado')));
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final topBarBg = bgColor;
    final backBtnBg =
        isDark ? const Color(0xFF1A1A28) : const Color(0xFFF0F1F5);
    final backIconColor =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);
    final titleColor =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);
    final heroTitleColor = titleColor;
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
              color: topBarBg,
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
                    'Entrar',
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
                                    Icons.lock_open_rounded,
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
                                      'Bem-vindo de volta!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: heroTitleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      'Gerencie e automatize suas cobranças.',
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
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: Icons.mail_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Digite seu e-mail';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: 'Senha',
                        hint: 'Sua senha',
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'Senha inválida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Lembrar-me + Esqueceu a senha
                      AuthOptionsRow(
                        initialValue: _rememberMe,
                        onRememberChanged: (v) =>
                            setState(() => _rememberMe = v),
                        onForgotPressed: () =>
                            context.push('/reset-password'),
                      ),
                      const SizedBox(height: 16),

                      // Botão entrar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
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
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF9CA3AF),
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
                        onPressed: () =>
                            _authController.signInWithGoogle(context),
                      ),
                      const SizedBox(height: 20),

                      // Footer
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/register'),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: footerColor,
                              ),
                              children: const [
                                TextSpan(text: 'Não tem conta? '),
                                TextSpan(
                                  text: 'Criar conta',
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
