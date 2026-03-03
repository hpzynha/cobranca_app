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
        setState(() {
          _isRecoveryMode = true;
        });
      }
    });
  }

  void _startResetCooldown() {
    _cooldownTimer?.cancel();
    setState(() {
      _remainingCooldown = _resetCooldownInSeconds;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingCooldown <= 1) {
        timer.cancel();
        setState(() {
          _remainingCooldown = 0;
        });
        return;
      }

      setState(() {
        _remainingCooldown -= 1;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se o e-mail estiver cadastrado, você receberá um link de redefinição.'),
        ),
      );
    } on AuthException {
      if (!mounted) return;
      _startResetCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se o e-mail estiver cadastrado, você receberá um link de redefinição.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar o link agora. Tente novamente.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso. Faça login novamente.')),
      );
      context.go('/login');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar senha. Tente novamente.')),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isRecoveryMode ? 'Nova senha' : 'Recuperar senha'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: _isRecoveryMode ? _buildUpdatePasswordForm() : _buildRequestResetForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestResetForm() {
    return Form(
      key: _requestFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Digite seu e-mail para receber o link de redefinição.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Digite seu email';
              }
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(email)) {
                return 'Digite um email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Por segurança, você poderá solicitar um novo link em alguns segundos.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isResetButtonDisabled ? null : _sendResetLink,
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.onPrimary)
                  : Text(
                      _remainingCooldown > 0
                          ? 'Aguarde ${_remainingCooldown}s'
                          : 'Enviar link',
                      style: const TextStyle(color: AppColors.onPrimary),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatePasswordForm() {
    return Form(
      key: _updateFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crie sua nova senha para continuar.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'Nova senha',
            controller: _passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Confirmar nova senha',
            controller: _confirmPasswordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value != _passwordController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.onPrimary)
                  : const Text(
                      'Atualizar senha',
                      style: TextStyle(color: AppColors.onPrimary),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
