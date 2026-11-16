import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/fixtures.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';
import '../dashboard/dashboard_widgets.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Owner',
          title: 'Home',
          subtitle: 'Sales, catalog and operational signals at a glance.',
          dense: true,
        ),
        DashboardHero(
          kicker: 'Today',
          title: 'Shop pulse',
          description: 'A compact view of sales, orders and follow-ups.',
          primaryLabel: 'Orders',
          onPrimary: () => context.go('/owner/orders'),
          secondaryLabel: 'Activity log',
          onSecondary: () => context.go('/owner/activity'),
        ),
        DashboardSectionCard(
          kicker: 'Today',
          title: 'Today at a glance',
          trailing: const WashdayCountPill('Updated just now'),
          child: DashboardKpis(metrics: ownerMetrics),
        ),
        const DashboardSectionCard(
          kicker: 'Sales',
          title: 'Last 7 days',
          trailing: WashdayCountPill('This week'),
          child: WeekSalesChart(),
        ),
        const DashboardSectionCard(
          kicker: 'Service mix',
          title: 'Where orders go',
          trailing: WashdayCountPill('This week'),
          child: ServiceMixBars(),
        ),
        DashboardSectionCard(
          kicker: 'Follow-up',
          title: 'Needs a look',
          trailing: const WashdayCountPill('3 alerts'),
          child: const Column(
            children: [
              DashboardAlert(
                icon: Icons.receipt_long_outlined,
                title: '3 unpaid orders',
                detail: 'Check payment before handover.',
                showTopBorder: false,
              ),
              DashboardAlert(
                icon: Icons.schedule_rounded,
                title: '2 ready for over 2 days',
                detail: 'Send a pickup reminder.',
              ),
              DashboardAlert(
                icon: Icons.check_circle_outline_rounded,
                title: 'Catalog is live',
                detail:
                    'Visible categories and services are shown to customers.',
                neutral: true,
              ),
            ],
          ),
        ),
        DashboardSectionCard(
          kicker: 'Recent',
          title: 'Recent orders',
          trailing: WashdayTextLink(
            'View all',
            onTap: () => context.go('/owner/orders'),
          ),
          child: RecentOrdersList(onTap: () => context.go('/owner/orders')),
        ),
      ],
    );
  }
}
