import 'package:app_cobranca/core/constants/app_strings.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/dashboard_status_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/monthly_balance_header.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/overdue_alert_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = AppResponsive.isCompact(context);
    final horizontalPadding =
        AppResponsive.size(context, isCompact ? 14 : 16).clamp(12.0, 22.0);
    final topContentPadding =
        AppResponsive.size(context, isCompact ? 10 : 14).clamp(8.0, 20.0);
    final bottomContentPadding =
        AppResponsive.size(context, 16).clamp(12.0, 24.0);
    final topSpacing = AppResponsive.size(context, isCompact ? 8 : 10);
    final sectionSpacing = AppResponsive.size(context, isCompact ? 14 : 16);
    final cardSpacing = isCompact ? AppSpacing.sm : 12.0;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topContentPadding,
            horizontalPadding,
            bottomContentPadding,
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
                      isVerySmallScreen
                          ? 122.0
                          : (isSmallScreen ? 132.0 : 142.0);

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

              SizedBox(height: sectionSpacing),
              const StudentsDashboardCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
    );
  }
}
