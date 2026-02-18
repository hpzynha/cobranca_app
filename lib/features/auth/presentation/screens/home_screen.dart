import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final router = GoRouter.of(context);
              await FirebaseAuth.instance.signOut();

              router.go('/');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bem-vinda ${user?.email ?? ""}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
