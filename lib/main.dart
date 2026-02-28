import 'package:app_cobranca/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://frwxnviutavcycklveex.supabase.co',
    anonKey: 'sb_publishable_44kgQ12j75KTca88dMRmOg_DYzCyisN',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
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
