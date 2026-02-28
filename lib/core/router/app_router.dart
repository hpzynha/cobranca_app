import 'dart:async';

import 'package:app_cobranca/features/auth/presentation/pages/add_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/alunos_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/email_verification_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/config_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/home_screen.dart';
import 'package:app_cobranca/features/auth/presentation/pages/relatorios_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/auth_landing_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isEmailConfirmed = user?.emailConfirmedAt != null;

    final isAuthRoute =
        state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/reset-password';

    final isVerificationRoute = state.matchedLocation == '/email-verification';
    if (isVerificationRoute && isEmailConfirmed) {
      return '/login';
    }

    if (user != null && !isEmailConfirmed && !isVerificationRoute) {
      return '/email-verification';
    }

    if (user == null && !isAuthRoute && !isVerificationRoute) {
      return '/';
    }

    if (user != null && isEmailConfirmed && isAuthRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthLandingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        final email = state.extra as String?;
        return EmailVerificationPage(email: email ?? '');
      },
    ),
<<<<<<< HEAD
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/alunos', builder: (context, state) => const AlunosPage()),
    GoRoute(path: '/adicionar', builder: (context, state) => const AddPage()),
    GoRoute(
      path: '/relatorios',
      builder: (context, state) => const RelatoriosPage(),
    ),
    GoRoute(path: '/config', builder: (context, state) => const ConfigPage()),
=======
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(initialIndex: 0),
    ),
    GoRoute(
      path: '/students',
      builder: (context, state) => const HomeScreen(initialIndex: 1),
    ),
    GoRoute(
      path: '/new',
      builder: (context, state) => const HomeScreen(initialIndex: 2),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const HomeScreen(initialIndex: 3),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const HomeScreen(initialIndex: 4),
    ),
>>>>>>> b487ee2420b8d6368112ff9f9e9e14e84d4411c6
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
