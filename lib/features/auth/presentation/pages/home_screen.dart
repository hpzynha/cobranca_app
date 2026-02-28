import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
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
    final isCompact = AppResponsive.isCompact(context);
    final horizontalPadding = isCompact ? 14.0 : AppSpacing.md;
    final topSpacing = isCompact ? AppSpacing.md : AppSpacing.lg;
    final sectionSpacing = isCompact ? 18.0 : AppSpacing.lg;
    final cardSpacing = isCompact ? AppSpacing.sm : 12.0;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topSpacing),
            const MonthlyBalanceHeader(amount: 4050.00),
            SizedBox(height: sectionSpacing),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isVerySmallScreen = width < 350;
                final isSmallScreen = width < 390;
                final cardHeight =
                    isVerySmallScreen ? 130.0 : (isSmallScreen ? 144.0 : 160.0);

                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: const DashboardStatusCard(
                          count: 3,
                          label: AppStrings.statusOverdue,
                          type: StatusType.overdue,
                        ),
                      ),
                    ),
                    SizedBox(width: cardSpacing),
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: const DashboardStatusCard(
                          count: 4,
                          label: AppStrings.statusDueToday,
                          type: StatusType.dueToday,
                        ),
                      ),
                    ),
                    SizedBox(width: cardSpacing),
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: const DashboardStatusCard(
                          count: 5,
                          label: AppStrings.statusPaid,
                          type: StatusType.paid,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: sectionSpacing),

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
