import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

class AlunosPage extends StatelessWidget {
  const AlunosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Alunos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text('Aluno exemplo'),
              subtitle: Text('Aqui vai a lista de alunos cadastrados'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 1),
    );
  }
}
