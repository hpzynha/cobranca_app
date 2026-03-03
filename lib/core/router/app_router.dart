import 'dart:async';

import 'package:app_cobranca/features/auth/presentation/pages/add_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/alunos_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/email_verification_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/config_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/home_screen.dart';
import 'package:app_cobranca/features/auth/presentation/pages/student_details_page.dart';
import 'package:app_cobranca/features/auth/presentation/pages/relatorios_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';

import '../../features/auth/presentation/pages/auth_landing_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
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
    GoRoute(path: '/', builder: (context, state) => const AuthLandingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        final email = state.extra as String?;
        return EmailVerificationPage(email: email ?? '');
      },
    ),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/alunos', builder: (context, state) => const AlunosPage()),
    GoRoute(
      path: '/alunos/:id',
      builder: (context, state) => StudentDetailsPage(
        studentId: state.pathParameters['id']!,
        initialStudent: state.extra as StudentPaymentItem?,
      ),
    ),
    GoRoute(path: '/adicionar', builder: (context, state) => const AddPage()),
    GoRoute(
      path: '/relatorios',
      builder: (context, state) => const RelatoriosPage(),
    ),
    GoRoute(path: '/config', builder: (context, state) => const ConfigPage()),
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
