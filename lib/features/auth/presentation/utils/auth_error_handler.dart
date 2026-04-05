class AuthErrorHandler {
  static String translate(Object error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered') ||
        msg.contains('already registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Muitas tentativas. Aguarde um momento e tente novamente.';
    }
    if (msg.contains('network') ||
        msg.contains('socketexception') ||
        msg.contains('connection')) {
      return 'Sem conexão com a internet. Verifique sua rede.';
    }
    if (msg.contains('user not found') || msg.contains('no user found')) {
      return 'Nenhuma conta encontrada com este e-mail.';
    }
    if (msg.contains('email') && msg.contains('invalid')) {
      return 'E-mail inválido.';
    }
    if (msg.contains('token') || msg.contains('expired')) {
      return 'Link expirado. Solicite um novo.';
    }

    return 'Ocorreu um erro. Tente novamente.';
  }
}
