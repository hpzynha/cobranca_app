import 'package:app_cobranca/core/theme/theme_provider.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/subscription/presentation/widgets/plan_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfigPage extends ConsumerWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        children: [
          const PlanBadgeWidget(),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Perfil'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notificações'),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modo escuro'),
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggle(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: -1),
    );
  }
}
