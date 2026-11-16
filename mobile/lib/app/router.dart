import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/sign_in_screen.dart';
import 'roles.dart';
import 'theme.dart';
import '../features/clerk/clerk_home_screen.dart';
import '../features/clerk/clerk_queue_screen.dart';
import '../features/clerk/counter_order_screen.dart';
import '../features/clerk/staff_order_detail_screen.dart';
import '../features/clerk/weigh_order_screen.dart';
import '../features/customer/category_services_screen.dart';
import '../features/customer/checkout_screen.dart';
import '../features/customer/customer_home_screen.dart';
import '../features/customer/customer_orders_screen.dart';
import '../features/customer/customer_profile_screen.dart';
import '../features/customer/customer_vouchers_screen.dart';
import '../features/customer/loyalty_screen.dart';
import '../features/customer/new_order_screen.dart';
import '../features/customer/notifications_screen.dart';
import '../features/customer/order_detail_screen.dart';
import '../features/customer/order_placed_screen.dart';
import '../features/customer/receipt_screen.dart';
import '../features/owner/activity_log_screen.dart';
import '../features/owner/add_category_screen.dart';
import '../features/owner/owner_catalog_screen.dart';
import '../features/owner/owner_category_services_screen.dart';
import '../features/owner/owner_home_screen.dart';
import '../features/owner/owner_more_screen.dart';
import '../features/owner/owner_orders_screen.dart';
import '../features/owner/owner_vouchers_screen.dart';
import '../features/owner/service_form_screen.dart';
import '../features/owner/shop_settings_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/welcome/welcome_screen.dart';
import '../shared/ambient_background.dart';
import '../shared/shell.dart';
import '../shared/ui.dart';

GoRouter buildWashdayRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => WashdayShell(
          config: WashdayShellConfig.fromLocation(state.uri.path),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/customer/home',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/customer/orders',
            builder: (context, state) => const CustomerOrdersScreen(),
          ),
          GoRoute(
            path: '/customer/orders/:id',
            builder: (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/customer/orders/:id/receipt',
            builder: (context, state) =>
                ReceiptScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/customer/vouchers',
            builder: (context, state) => const CustomerVouchersScreen(),
          ),
          GoRoute(
            path: '/customer/profile',
            builder: (context, state) => const CustomerProfileScreen(),
          ),
          GoRoute(
            path: '/customer/loyalty',
            builder: (context, state) => const LoyaltyScreen(),
          ),
          GoRoute(
            path: '/customer/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/customer/settings',
            builder: (context, state) =>
                const WashdaySettingsScreen(role: WashdayRole.customer),
          ),
          GoRoute(
            path: '/customer/new-order',
            builder: (context, state) => const NewOrderScreen(),
          ),
          GoRoute(
            path: '/customer/category/:id',
            builder: (context, state) =>
                CategoryServicesScreen(categoryId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/customer/checkout/:serviceId',
            builder: (context, state) =>
                CheckoutScreen(serviceId: state.pathParameters['serviceId']!),
          ),
          GoRoute(
            path: '/customer/order-placed/:id',
            builder: (context, state) =>
                OrderPlacedScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/clerk/home',
            builder: (context, state) => const ClerkHomeScreen(),
          ),
          GoRoute(
            path: '/clerk/queue',
            builder: (context, state) => const ClerkQueueScreen(),
          ),
          GoRoute(
            path: '/clerk/queue/:id',
            builder: (context, state) => StaffOrderDetailScreen(
              orderId: state.pathParameters['id']!,
              role: WashdayRole.clerk,
            ),
          ),
          GoRoute(
            path: '/clerk/new-order',
            builder: (context, state) => const CounterOrderScreen(),
          ),
          GoRoute(
            path: '/clerk/weigh',
            builder: (context, state) =>
                WeighOrderScreen(orderId: state.uri.queryParameters['order']),
          ),
          GoRoute(
            path: '/clerk/settings',
            builder: (context, state) =>
                const WashdaySettingsScreen(role: WashdayRole.clerk),
          ),
          GoRoute(
            path: '/owner/home',
            builder: (context, state) => const OwnerHomeScreen(),
          ),
          GoRoute(
            path: '/owner/services',
            builder: (context, state) => const OwnerCatalogScreen(),
          ),
          GoRoute(
            path: '/owner/add-category',
            builder: (context, state) => const AddCategoryScreen(),
          ),
          GoRoute(
            path: '/owner/category/:id',
            builder: (context, state) => OwnerCategoryServicesScreen(
              categoryId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/owner/category/:id/add-service',
            builder: (context, state) =>
                ServiceFormScreen(categoryId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/owner/category/:id/edit-service/:serviceId',
            builder: (context, state) => ServiceFormScreen(
              categoryId: state.pathParameters['id']!,
              serviceId: state.pathParameters['serviceId'],
            ),
          ),
          GoRoute(
            path: '/owner/vouchers',
            builder: (context, state) => const OwnerVouchersScreen(),
          ),
          GoRoute(
            path: '/owner/more',
            builder: (context, state) => const OwnerMoreScreen(),
          ),
          GoRoute(
            path: '/owner/orders',
            builder: (context, state) => const OwnerOrdersScreen(),
          ),
          GoRoute(
            path: '/owner/orders/:id',
            builder: (context, state) => StaffOrderDetailScreen(
              orderId: state.pathParameters['id']!,
              role: WashdayRole.owner,
            ),
          ),
          GoRoute(
            path: '/owner/orders/:id/weigh',
            builder: (context, state) => WeighOrderScreen(
              orderId: state.pathParameters['id']!,
              role: WashdayRole.owner,
            ),
          ),
          GoRoute(
            path: '/owner/activity',
            builder: (context, state) => const ActivityLogScreen(),
          ),
          GoRoute(
            path: '/owner/settings',
            builder: (context, state) => const ShopSettingsScreen(),
          ),
          GoRoute(
            path: '/owner/account',
            builder: (context, state) =>
                const WashdaySettingsScreen(role: WashdayRole.owner),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _RouteNotFoundScreen(),
  );
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WashdayAmbientBackground()),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: WashdayCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const WashdayKicker('Washday'),
                        const SizedBox(height: 6),
                        Text(
                          'Screen not found',
                          style: WashdayType.style(
                            size: 28,
                            weight: 650,
                            height: 1.1,
                            letterSpacing: -1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This screen isn’t available. Head back to the start.',
                          style: WashdayType.muted(size: 13, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        WashdayButton(
                          label: 'Back to welcome',
                          onPressed: () => context.go('/'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
