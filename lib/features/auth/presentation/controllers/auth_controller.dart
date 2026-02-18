import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) return;
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao logar com Google')));
    }
  }
}
