import 'dart:async';

import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/data/auth_service.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const int _resetCooldownInSeconds = 12;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _requestFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  final _authService = AuthService();

  StreamSubscription<AuthState>? _authSubscription;
  Timer? _cooldownTimer;

  bool _isLoading = false;
  bool _isRecoveryMode = false;
  int _remainingCooldown = 0;

  bool get _isResetButtonDisabled => _isLoading || _remainingCooldown > 0;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      if (data.event == AuthChangeEvent.passwordRecovery) {
        setState(() => _isRecoveryMode = true);
      }
    });
  }

  void _startResetCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _remainingCooldown = _resetCooldownInSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_remainingCooldown <= 1) {
        timer.cancel();
        setState(() => _remainingCooldown = 0);
        return;
      }
      setState(() => _remainingCooldown -= 1);
    });
  }

  Future<void> _sendResetLink() async {
    if (_isResetButtonDisabled) return;
    if (!_requestFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (!mounted) return;
      _startResetCooldown();
      _showSnackBar('Se o e-mail estiver cadastrado, você receberá o link em instantes.');
    } on AuthException {
      if (!mounted) return;
      _startResetCooldown();
      _showSnackBar('Se o e-mail estiver cadastrado, você receberá o link em instantes.');
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Não foi possível enviar o link agora. Tente novamente.', isError: true);
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _updatePassword() async {
    if (!_updateFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );
      await _authService.logout();
      if (!mounted) return;
      _showSnackBar('Senha atualizada com sucesso! Faça login novamente.');
      context.go('/login');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Erro ao atualizar senha. Tente novamente.', isError: true);
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: _isRecoveryMode ? _buildUpdatePasswordForm() : _buildRequestResetForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestResetForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;
    final iconBg = isDark ? const Color(0xFF1E1A3A) : AppColors.primarySurface;

    return Form(
      key: _requestFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 20),

          // Título
          Text(
            'Esqueceu sua senha?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: titleColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sem problema. Digite seu e-mail e te enviamos um link para criar uma nova senha.',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),

          // Campo email
          AuthTextField(
            label: 'E-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Digite seu e-mail';
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(email)) return 'Digite um e-mail válido';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Botão enviar
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isResetButtonDisabled ? null : _sendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primaryMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _remainingCooldown > 0
                          ? 'Reenviar em ${_remainingCooldown}s'
                          : 'Enviar link de redefinição',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Voltar pro login
          Center(
            child: TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/login');
                }
              },
              child: const Text(
                'Voltar para o login',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatePasswordForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;
    final iconBg = isDark ? const Color(0xFF1E1A3A) : AppColors.primarySurface;

    return Form(
      key: _updateFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 20),

          // Título
          Text(
            'Criar nova senha',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: titleColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha uma senha forte com pelo menos 6 caracteres.',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),

          // Nova senha
          AuthTextField(
            label: 'Nova senha',
            controller: _passwordController,
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirmar senha
          AuthTextField(
            label: 'Confirmar nova senha',
            controller: _confirmPasswordController,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value != _passwordController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Botão atualizar
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primaryMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Atualizar senha',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
