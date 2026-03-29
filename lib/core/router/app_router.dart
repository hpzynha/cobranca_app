import 'dart:async';

import 'package:app_cobranca/features/auth/presentation/pages/add_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/alunos_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/email_verification_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/config_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/home_screen.dart';
import 'package:app_cobranca/features/auth/presentation/pages/perfil_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/student_details_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/mensagens_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/relatorios_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';

import '../../features/auth/presentation/pages/auth_landing_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';

final _refreshStream = GoRouterRefreshStream(
  Supabase.instance.client.auth.onAuthStateChange,
);

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _refreshStream,
  redirect: (context, state) {
    final isSplashRoute = state.matchedLocation == '/splash';
    if (isSplashRoute) return null;

    // Redireciona para reset-password quando o deep link de recuperação chega
    // só uma vez (consumido após o primeiro redirect)
    if (_refreshStream.shouldRedirectToPasswordRecovery &&
        state.matchedLocation != '/reset-password') {
      _refreshStream.consumePasswordRecovery();
      return '/reset-password';
    }

    final user = Supabase.instance.client.auth.currentUser;
    final isEmailConfirmed = user?.emailConfirmedAt != null;

    final isResetPasswordRoute = state.matchedLocation == '/reset-password';
    final isAuthRoute =
        state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        isResetPasswordRoute;

    final isVerificationRoute = state.matchedLocation == '/email-verification';
    if (isVerificationRoute && isEmailConfirmed) {
      return '/login';
    }

    if (user != null && !isEmailConfirmed && !isVerificationRoute && !isResetPasswordRoute) {
      return '/email-verification';
    }

    if (user == null && !isAuthRoute && !isVerificationRoute) {
      return '/';
    }

    if (user != null && isEmailConfirmed && isAuthRoute && !isResetPasswordRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/splash', pageBuilder: (context, state) => _fadePage(state, const SplashScreen())),
    GoRoute(path: '/', pageBuilder: (context, state) => _fadePage(state, const AuthLandingScreen())),
    GoRoute(path: '/login', pageBuilder: (context, state) => _fadePage(state, const LoginScreen())),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _slidePage(state, const RegisterScreen()),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (context, state) => _slidePage(state, const ResetPasswordScreen()),
    ),
    GoRoute(
      path: '/email-verification',
      pageBuilder: (context, state) {
        final email = state.extra as String?;
        return _slidePage(state, EmailVerificationPage(email: email ?? ''));
      },
    ),

    // Rotas da bottom bar — fade para sensação de troca de aba
    GoRoute(path: '/home', pageBuilder: (context, state) => _fadePage(state, const HomeScreen())),
    GoRoute(path: '/alunos', pageBuilder: (context, state) => _fadePage(state, const AlunosPage())),
    GoRoute(
      path: '/alunos/:id',
      pageBuilder: (context, state) => _slidePage(
        state,
        StudentDetailsPage(
          studentId: state.pathParameters['id']!,
          initialStudent: state.extra as StudentPaymentItem?,
        ),
      ),
    ),
    GoRoute(path: '/adicionar', pageBuilder: (context, state) => _fadePage(state, const AddPage())),
    GoRoute(path: '/mensagens', pageBuilder: (context, state) => _fadePage(state, const MensagensPage())),
    GoRoute(path: '/relatorios', pageBuilder: (context, state) => _fadePage(state, const RelatoriosPage())),
    GoRoute(path: '/config', pageBuilder: (context, state) => _slidePage(state, const ConfigPage())),
    GoRoute(path: '/perfil', pageBuilder: (context, state) => _slidePage(state, const PerfilPage())),
  ],
);

// Transição fade — usada nas rotas da bottom bar (sensação de troca de aba)
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
      child: child,
    ),
  );
}

// Transição slide da direita — usada em páginas de detalhe (push)
CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
      final fade = CurveTween(curve: const Interval(0.0, 0.5)).animate(animation);
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((AuthState state) {
      _lastEvent = state.event;
      _consumed = false;
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;
  AuthChangeEvent? _lastEvent;
  bool _consumed = false;

  bool get shouldRedirectToPasswordRecovery =>
      _lastEvent == AuthChangeEvent.passwordRecovery && !_consumed;

  void consumePasswordRecovery() {
    _consumed = true;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
