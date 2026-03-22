import 'dart:async';

import 'package:app_cobranca/core/theme/app_theme.dart';
import 'package:app_cobranca/core/theme/theme_provider.dart';
import 'package:app_cobranca/features/notifications/presentation/providers/notification_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme_mode');
  final initialTheme =
      savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
          (ref) => ThemeModeNotifier(initialTheme),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        appRouter.go('/reset-password');
      }
      if (data.event == AuthChangeEvent.signedIn) {
        ref.read(fcmServiceProvider).registerToken();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final scaleFactor =
            mediaQuery.textScaler.scale(1.0).clamp(0.9, 1.1).toDouble();
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(scaleFactor)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
