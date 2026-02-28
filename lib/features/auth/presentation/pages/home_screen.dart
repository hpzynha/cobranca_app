import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/dashboard_status_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/monthly_balance_header.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/overdue_alert_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const MonthlyBalanceHeader(amount: 4050.00),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 380;
                final cardHeight = isSmallScreen ? 148.0 : 172.0;

                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: const DashboardStatusCard(
                          count: 3,
                          label: "Atrasados",
                          type: StatusType.overdue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: const DashboardStatusCard(
                          count: 4,
                          label: "Vencem hoje",
                          type: StatusType.dueToday,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: const DashboardStatusCard(
                          count: 5,
                          label: "Pagos",
                          type: StatusType.paid,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            OverdueAlertCard(
              overdueCount: 3,
              onTap: () {
                // navegar para lista de atrasados
              },
            ),

            // Aqui depois entra lista de alunos
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
    );
  }
}
