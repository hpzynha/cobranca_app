import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<BottomBarItem> _navItems = [
    BottomBarItem(icon: Icons.home_outlined, label: 'Início'),
    BottomBarItem(icon: Icons.groups_2_outlined, label: 'Alunos'),
    BottomBarItem(icon: Icons.add, label: 'Novo', isCenter: true),
    BottomBarItem(icon: Icons.bar_chart_outlined, label: 'Relatórios'),
    BottomBarItem(icon: Icons.settings_outlined, label: 'Config'),
  ];

  static const List<String> _routes = [
    '/home',
    '/students',
    '/new',
    '/reports',
    '/settings',
  ];

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
        actions: [
          if (_currentIndex == 4)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _TabBody(text: 'Tela Início'),
          _TabBody(text: 'Tela Alunos'),
          _TabBody(text: 'Tela Novo'),
          _TabBody(text: 'Tela Relatórios'),
          _TabBody(text: 'Tela Config'),
        ],
      ),
      bottomNavigationBar: BottomBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == index) return;
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Início';
      case 1:
        return 'Alunos';
      case 2:
        return 'Novo';
      case 3:
        return 'Relatórios';
      case 4:
        return 'Config';
      default:
        return 'Dashboard';
    }
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Center(
      child: Text(
        user == null ? text : '$text\n${user.email ?? ''}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
<<<<<<< HEAD
      body: Center(
        child: Text(
          'Bem-vinda ${user?.email ?? ""}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
=======
>>>>>>> b487ee2420b8d6368112ff9f9e9e14e84d4411c6
    );
  }
}
