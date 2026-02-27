import 'package:app_cobranca/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/auth_options_row.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/tween_animation_builder_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_cobranca/features/auth/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro inesperado')));
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');

    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80),
                    const AnimatedLogoRow(),
                    SizedBox(height: 8),
                    Text(
                      'Gerencie e automatize suas cobranças.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 40),
                    AuthTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite seu email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      label: 'Senha',
                      controller: _passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Senha Invalida';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 6),
                    AuthOptionsRow(
                      onRememberChanged: (value) {
                        setState(() {
                          _rememberMe = value;
                        });
                      },
                      onForgotPressed: () {
                        context.push('/reset-password');
                      },
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: AppColors.onPrimary,
                                )
                                : const Text(
                                  'Entrar',
                                  style: TextStyle(color: AppColors.onPrimary),
                                ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Ou'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SocialAuthButton(
                      text: 'Continuar com Google',
                      logoPath: 'assets/images/google_logo.svg',
                      onPressed:
                          () => _authController.signInWithGoogle(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
