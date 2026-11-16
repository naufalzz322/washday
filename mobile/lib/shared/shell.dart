import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/roles.dart';
import '../data/seed.dart';
import '../data/session_controller.dart';
import '../shared/account_menu.dart';
import 'ambient_background.dart';
import 'bottom_nav.dart';
import 'order_dock.dart';
import 'top_bar.dart';

class WashdayShellConfig {
  const WashdayShellConfig({
    required this.role,
    required this.navItems,
    required this.selectedIndex,
    required this.showOrderDock,
  });

  final WashdayRole role;
  final List<WashdayNavItem> navItems;
  final int? selectedIndex;
  final bool showOrderDock;

  static WashdayShellConfig fromLocation(String location) {
    if (location.startsWith('/clerk')) {
      return const WashdayShellConfig(
        role: WashdayRole.clerk,
        navItems: [
          WashdayNavItem(
            label: 'Home',
            icon: Icons.home_outlined,
            route: '/clerk/home',
          ),
          WashdayNavItem(
            label: 'Queue',
            icon: Icons.receipt_long_outlined,
            route: '/clerk/queue',
          ),
          WashdayNavItem(
            label: 'New order',
            icon: Icons.person_add_alt_1_outlined,
            route: '/clerk/new-order',
          ),
        ],
        selectedIndex: 0,
        showOrderDock: false,
      )._withSelected(location);
    }

    if (location.startsWith('/owner')) {
      return const WashdayShellConfig(
        role: WashdayRole.owner,
        navItems: [
          WashdayNavItem(
            label: 'Home',
            icon: Icons.home_outlined,
            route: '/owner/home',
          ),
          WashdayNavItem(
            label: 'Services',
            icon: Icons.checkroom_outlined,
            route: '/owner/services',
          ),
          WashdayNavItem(
            label: 'Vouchers',
            icon: Icons.confirmation_number_outlined,
            route: '/owner/vouchers',
          ),
          WashdayNavItem(
            label: 'More',
            icon: Icons.more_horiz_rounded,
            route: '/owner/more',
          ),
        ],
        selectedIndex: 0,
        showOrderDock: false,
      )._withSelected(location);
    }

    return const WashdayShellConfig(
      role: WashdayRole.customer,
      navItems: [
        WashdayNavItem(
          label: 'Home',
          icon: Icons.home_outlined,
          route: '/customer/home',
        ),
        WashdayNavItem(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          route: '/customer/orders',
        ),
        WashdayNavItem(
          label: 'Vouchers',
          icon: Icons.confirmation_number_outlined,
          route: '/customer/vouchers',
        ),
      ],
      selectedIndex: 0,
      showOrderDock: false,
    )._withSelected(location);
  }

  WashdayShellConfig _withSelected(String location) {
    final selected = switch (role) {
      WashdayRole.customer => switch (location) {
        '/customer/home' => 0,
        final path when path.startsWith('/customer/orders') => 1,
        '/customer/vouchers' => 2,
        _ => null,
      },
      WashdayRole.clerk => switch (location) {
        '/clerk/home' => 0,
        final path when path.startsWith('/clerk/queue') => 1,
        '/clerk/new-order' || '/clerk/weigh' => 2,
        _ => null,
      },
      WashdayRole.owner => switch (location) {
        '/owner/home' => 0,
        final path
            when path.startsWith('/owner/services') ||
                path.startsWith('/owner/category') ||
                path.startsWith('/owner/add-category') =>
          1,
        '/owner/vouchers' => 2,
        final path
            when path.startsWith('/owner/more') ||
                path.startsWith('/owner/orders') ||
                path.startsWith('/owner/activity') ||
                path.startsWith('/owner/settings') =>
          3,
        _ => null,
      },
    };

    final showDock =
        role == WashdayRole.customer &&
        (location == '/customer/home' || location == '/customer/orders');

    return WashdayShellConfig(
      role: role,
      navItems: navItems,
      selectedIndex: selected,
      showOrderDock: showDock,
    );
  }
}

class WashdayShell extends ConsumerWidget {
  const WashdayShell({super.key, required this.config, required this.child});

  final WashdayShellConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    final gutter = WashdayViewport.gutter(context);
    final safeBottom = mq.padding.bottom;
    final account = ref.watch(currentAccountProvider);
    final hasUnread =
        config.role == WashdayRole.customer &&
        notificationsFor(account.customerId).any((item) => item.unread);
    final navBottom = math.max(12.0, safeBottom);
    final navWidth = math.min(
      math.max(0.0, mq.size.width - gutter * 2),
      WashdayViewport.navMaxWidth,
    );
    final dockBottom = navBottom + 64 + 8;

    final homeRoute = switch (config.role) {
      WashdayRole.customer => '/customer/home',
      WashdayRole.clerk => '/clerk/home',
      WashdayRole.owner => '/owner/home',
    };

    final settingsRoute = switch (config.role) {
      WashdayRole.customer => '/customer/settings',
      WashdayRole.clerk => '/clerk/settings',
      WashdayRole.owner => '/owner/account',
    };

    Future<void> openAccountMenu() async {
      final action = await showWashdayAccountMenu(
        context,
        role: config.role,
        account: ref.read(currentAccountProvider),
      );
      if (!context.mounted || action == null) return;
      if (action == WashdayAccountAction.settings) {
        context.push(settingsRoute);
        return;
      }
      final confirmed = await confirmWashdayLogout(context, role: config.role);
      if (!confirmed || !context.mounted) return;
      ref.read(sessionProvider.notifier).signOut();
      context.go('/sign-in');
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WashdayAmbientBackground()),
          Column(
            children: [
              WashdayTopBar(
                role: config.role,
                accountName: account.name,
                hasPhoto: account.hasPhoto,
                accountInitial: account.initial,
                onBrandTap: () => context.go(homeRoute),
                onProfileTap: openAccountMenu,
                onNotificationsTap: config.role == WashdayRole.customer
                    ? () => context.push('/customer/notifications')
                    : null,
                hasUnreadNotifications: hasUnread,
              ),
              Expanded(child: child),
            ],
          ),
          if (config.showOrderDock)
            Positioned(
              left: 0,
              right: 0,
              bottom: dockBottom,
              child: Center(
                child: SizedBox(
                  width: navWidth,
                  child: WashdayOrderDock(
                    onTap: () => context.push('/customer/new-order'),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: navBottom,
            child: Center(
              child: SizedBox(
                width: navWidth,
                child: WashdayBottomNav(
                  items: config.navItems,
                  selectedIndex: config.selectedIndex,
                  onSelected: (index) =>
                      context.go(config.navItems[index].route),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
