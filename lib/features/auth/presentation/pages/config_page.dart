import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Perfil'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notificações'),
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
      bottomNavigationBar: const BottomBar(currentIndex: 4),
    );
  }
}
