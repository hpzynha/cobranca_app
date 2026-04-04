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
import 'package:app_cobranca/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:app_cobranca/features/subscription/presentation/pages/paywall_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';

import '../../features/auth/presentation/pages/auth_landing_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';

// ── Refresh stream para mudanças de auth ────────────────────────────────────
final _refreshStream = GoRouterRefreshStream(
  Supabase.instance.client.auth.onAuthStateChange,
);

// ── Notifier de status de onboarding (cache síncrono para o redirect) ───────
/// Exposto publicamente para que a OnboardingPage possa chamar [refresh()]
/// após concluir o onboarding e liberar a navegação para /home.
final onboardingStatusNotifier = OnboardingStatusNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: Listenable.merge([_refreshStream, onboardingStatusNotifier]),
  redirect: (context, state) {
    final location = state.matchedLocation;
    if (location == '/splash') return null;

    // Redireciona para reset-password quando o deep link de recuperação chega
    if (_refreshStream.shouldRedirectToPasswordRecovery &&
        location != '/reset-password') {
      _refreshStream.consumePasswordRecovery();
      return '/reset-password';
    }

    final user = Supabase.instance.client.auth.currentUser;
    final isEmailConfirmed = user?.emailConfirmedAt != null;

    final isResetPasswordRoute = location == '/reset-password';
    final isAuthRoute = location == '/' ||
        location == '/login' ||
        location == '/register' ||
        isResetPasswordRoute;
    final isVerificationRoute = location == '/email-verification';
    final isOnboardingRoute = location == '/onboarding';

    if (isVerificationRoute && isEmailConfirmed) return '/login';

    if (user != null &&
        !isEmailConfirmed &&
        !isVerificationRoute &&
        !isResetPasswordRoute) {
      return '/email-verification';
    }

    if (user == null && !isAuthRoute && !isVerificationRoute) return '/';

    // Usuário autenticado + email confirmado
    if (user != null && isEmailConfirmed) {
      final onboardingDone = onboardingStatusNotifier.onboardingCompleted;

      // Rota de auth → decide para onde ir com base no onboarding
      if (isAuthRoute && !isResetPasswordRoute) {
        return (onboardingDone == false) ? '/onboarding' : '/home';
      }

      // Rotas internas → onboarding ainda não concluído
      if (onboardingDone == false && !isOnboardingRoute) {
        return '/onboarding';
      }

      // Já concluiu onboarding mas voltou para /onboarding (não deve acontecer)
      if (onboardingDone == true && isOnboardingRoute) {
        return '/home';
      }
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

    // Onboarding — exibido uma única vez após o primeiro login
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _fadePage(state, const OnboardingPage()),
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
    GoRoute(path: '/paywall', pageBuilder: (context, state) => _slidePage(state, const PaywallPage())),
  ],
);

// ── Transições ───────────────────────────────────────────────────────────────

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

// ── GoRouterRefreshStream ────────────────────────────────────────────────────

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

// ── OnboardingStatusNotifier ─────────────────────────────────────────────────

/// Cache síncrono do status de onboarding.
/// Escuta mudanças de auth e re-busca o perfil quando necessário.
/// O valor [onboardingCompleted] é [null] enquanto ainda está carregando.
class OnboardingStatusNotifier extends ChangeNotifier {
  OnboardingStatusNotifier() {
    // Busca imediata se já há um usuário autenticado
    if (Supabase.instance.client.auth.currentUser != null) {
      _fetch();
    }
    _subscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn ||
          authState.event == AuthChangeEvent.tokenRefreshed) {
        _fetch();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        _onboardingCompleted = null;
        notifyListeners();
      }
    });
  }

  late final StreamSubscription<AuthState> _subscription;
  bool? _onboardingCompleted;

  /// [null] = ainda carregando; [false] = não concluído; [true] = concluído.
  bool? get onboardingCompleted => _onboardingCompleted;

  /// Força re-busca — chamado pela OnboardingPage após salvar o perfil.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _onboardingCompleted = null;
      notifyListeners();
      return;
    }
    try {
      final result = await Supabase.instance.client
          .from('profiles')
          .select('onboarding_completed')
          .eq('id', userId)
          .maybeSingle();
      _onboardingCompleted = result?['onboarding_completed'] == true;
    } catch (_) {
      // Fail-safe: em caso de erro, não bloqueia o usuário
      _onboardingCompleted = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
