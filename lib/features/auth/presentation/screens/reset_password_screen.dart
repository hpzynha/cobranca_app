import 'package:app_cobranca/features/auth/data/auth_service.dart';
import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().resetPassword(_emailController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email enviado com sucesso!")),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao enviar email")));
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Recuperar senha",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 🔹 ILUSTRAÇÃO
                SizedBox(
                  height: 220,
                  child: Image.asset(
                    'assets/images/forgot-password.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Esqueceu sua senha?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Não se preocupe. Informe o e-mail associado à sua conta.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 32),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Digite seu email",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 8),

                AuthTextField(
                  label: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email é obrigatório";
                    }
                    if (!value.contains("@")) {
                      return "Email inválido";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleReset,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: AppColors.onPrimary,
                            )
                            : const Text(
                              "Enviar email",
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
