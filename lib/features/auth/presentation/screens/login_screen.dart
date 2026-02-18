import 'package:app_cobranca/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/tween_animation_builder_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // navegar ou mostrar erro
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  const AnimatedLogoRow(),
                  SizedBox(height: 8),
                  Text(
                    'Gerencie e automatize suas cobranças.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 40),
                  AuthTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.name,
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

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                'Entrar',
                                style: TextStyle(color: Colors.white),
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
                  ),
                  const SizedBox(height: 16),
                  SocialAuthButton(
                    text: 'Continuar com Apple',
                    logoPath: 'assets/images/apple_logo.svg',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
