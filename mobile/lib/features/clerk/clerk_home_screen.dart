import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/fixtures.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';
import '../dashboard/dashboard_widgets.dart';

class ClerkHomeScreen extends StatelessWidget {
  const ClerkHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Clerk',
          title: 'Home',
          subtitle: 'Today’s queue and shop snapshot.',
          dense: true,
        ),
        DashboardHero(
          kicker: 'Shift',
          title: 'Counter shift',
          description: 'Orders, pickups and payments in one place.',
          primaryLabel: 'Open queue',
          onPrimary: () => context.go('/clerk/queue'),
          secondaryLabel: 'Counter order',
          onSecondary: () => context.go('/clerk/new-order'),
        ),
        DashboardSectionCard(
          kicker: 'Today',
          title: 'Today at a glance',
          trailing: const WashdayCountPill('Updated just now'),
          child: DashboardKpis(metrics: clerkMetrics),
        ),
        DashboardSectionCard(
          kicker: 'Operations',
          title: 'Queue load',
          trailing: const WashdayCountPill('6 open'),
          child: QueueLoadBars(items: clerkQueueLoad),
        ),
        DashboardSectionCard(
          kicker: 'Recent',
          title: 'Recent orders',
          trailing: WashdayTextLink(
            'View all',
            onTap: () => context.go('/clerk/queue'),
          ),
          child: RecentOrdersList(onTap: () => context.go('/clerk/queue')),
        ),
      ],
    );
  }
}
