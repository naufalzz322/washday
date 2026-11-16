import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class OwnerMoreScreen extends StatelessWidget {
  const OwnerMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        const WashdayPageHeading(
          kicker: 'Owner',
          title: 'More',
          subtitle: 'Orders, activity and settings.',
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WashdaySectionHead(
                kicker: 'Manage',
                title: 'Owner tools',
                titleSize: 18,
              ),
              const SizedBox(height: 8),
              _ToolRow(
                icon: Icons.receipt_long_outlined,
                title: 'Orders',
                subtitle: 'Accept, weigh and hand over orders',
                onTap: () => context.go('/owner/orders'),
                showTopBorder: false,
              ),
              _ToolRow(
                icon: Icons.history_rounded,
                title: 'Activity log',
                subtitle: 'Order, payment and catalog changes',
                onTap: () => context.go('/owner/activity'),
              ),
              _ToolRow(
                icon: Icons.tune_rounded,
                title: 'Shop settings',
                subtitle: 'Loyalty and order timing',
                onTap: () => context.go('/owner/settings'),
              ),
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Account', style: WashdayType.title(size: 18)),
              const SizedBox(height: 8),
              _ToolRow(
                icon: Icons.storefront_outlined,
                title: 'Shop profile',
                subtitle: 'Washday · wash & fold, one shop',
                onTap: null,
                showChevron: false,
                showTopBorder: false,
              ),
              _ToolRow(
                icon: Icons.switch_account_outlined,
                title: 'Switch account',
                subtitle: 'Sign in as a customer or clerk',
                onTap: () => context.go('/sign-in'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showTopBorder = true,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showTopBorder;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: showTopBorder
                ? const Border(top: BorderSide(color: WashdayColors.hairline))
                : null,
          ),
          child: Row(
            children: [
              WashdayLeadingTile(size: 38, radius: 12, child: Icon(icon)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: WashdayType.style(
                        size: 13.5,
                        weight: 630,
                        color: WashdayColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: WashdayType.muted(size: 11, height: 1.35),
                    ),
                  ],
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: WashdayColors.slate400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
