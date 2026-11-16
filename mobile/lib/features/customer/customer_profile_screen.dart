import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/orders_controller.dart';
import '../../data/seed.dart';
import '../../data/session_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    final orders = ref.watch(ordersProvider).forCustomer(account.customerId);
    final collected = orders.where((order) => order.isCollected).length;
    final loyalty = loyaltyFor(account.customerId);
    final remaining = (10 - loyalty.stamps).clamp(0, 10);
    final firstName = account.detail.split(' · ').first;

    return WashdayPage(
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        WashdayBackLink(
          label: 'Settings',
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/settings');
            }
          },
        ),
        const WashdayPageHeading(
          kicker: 'Account',
          title: 'Profile',
          subtitle: 'Your details and loyalty progress.',
        ),
        WashdayDeepCard(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: WashdayColors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  account.initial,
                  style: WashdayType.style(
                    size: 22,
                    weight: 680,
                    color: WashdayColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WashdayKicker('Customer', color: Color(0xB3FFFFFF)),
                    const SizedBox(height: 6),
                    Text(
                      account.name,
                      style: WashdayType.title(size: 22, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      firstName,
                      style: WashdayType.muted(
                        size: 12,
                        color: const Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        WashdayMetricStrip(
          metrics: [
            WashdayMetric(value: '${loyalty.stamps}', label: 'Stamps'),
            WashdayMetric(value: '${orders.length}', label: 'Orders'),
            WashdayMetric(value: '$collected', label: 'Collected'),
          ],
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 6),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Account details', style: WashdayType.title(size: 17)),
              const SizedBox(height: 6),
              WashdayDetailRow('Email', account.email),
              const WashdayDetailRow('Phone', 'Optional · not added'),
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          shadow: false,
          onTap: () => context.push('/customer/loyalty'),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: WashdayColors.teal100,
                  borderRadius: BorderRadius.circular(WashdayRadii.tile),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: WashdayColors.teal700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Loyalty card',
                            style: WashdayType.strong(size: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${loyalty.stamps} / 10',
                          style: WashdayType.style(
                            size: 12,
                            weight: 650,
                            color: WashdayColors.inkSecondary,
                            tabularFigures: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(WashdayRadii.pill),
                      child: LinearProgressIndicator(
                        value: loyalty.stamps / 10,
                        minHeight: 5,
                        color: WashdayColors.teal600,
                        backgroundColor: WashdayColors.hairline,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$remaining more pickups to a reward',
                      style: WashdayType.muted(size: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: WashdayColors.slate400,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
