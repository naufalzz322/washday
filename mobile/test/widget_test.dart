import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:washday/app/app.dart';
import 'package:washday/app/router.dart';
import 'package:washday/app/theme.dart';
import 'package:washday/data/catalog_controller.dart';
import 'package:washday/data/clock.dart';
import 'package:washday/shared/ui.dart';

/// Fixed shop-clock instant so seed dates and date filters stay deterministic.
final _fixedNow = DateTime(2026, 10, 14, 10, 24);

Widget _app() {
  return ProviderScope(
    overrides: [washdayClockProvider.overrideWithValue(() => _fixedNow)],
    child: const WashdayApp(),
  );
}

Widget _routerApp(GoRouter router) {
  return ProviderScope(
    overrides: [washdayClockProvider.overrideWithValue(() => _fixedNow)],
    child: MaterialApp.router(theme: buildWashdayTheme(), routerConfig: router),
  );
}

void _usePhone(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Fills the seeded credentials from the account sheet without signing in.
Future<void> _chooseAccount(WidgetTester tester, String name) async {
  await tester.ensureVisible(find.text('Select account'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Select account'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

/// Walks Welcome → Sign in → saved account → submit.
Future<void> _signIn(WidgetTester tester, String name) async {
  await tester.tap(find.text('Get started'));
  await tester.pumpAndSettle();
  await _chooseAccount(tester, name);
  await tester.tap(find.byKey(const Key('sign-in-submit')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final fontLoader = FontLoader('InterTight')
      ..addFont(rootBundle.load('assets/fonts/InterTight-Variable.ttf'));
    await fontLoader.load();
  });

  test('owner catalog edits stay in session and restore cleanly', () {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    final controller = container.read(catalogProvider.notifier);
    controller.addCategory(
      name: 'Uniforms',
      description: 'Work shirts and aprons for local teams.',
      imageAsset: 'assets/images/hero-shirt.jpg',
    );

    var catalog = container.read(catalogProvider);
    final category = catalog.categories.last;
    expect(category.name, 'Uniforms');
    expect(category.services, isEmpty);
    expect(catalog.isCustom, isTrue);

    controller.addService(
      categoryId: category.id,
      name: 'Team wash',
      description: 'Weekly wash and fold for uniforms.',
      price: 2.75,
      unit: 'kg',
      duration: '12 h',
      active: true,
    );

    catalog = container.read(catalogProvider);
    final service = catalog.findService('${category.id}-team-wash');
    expect(service, isNotNull);
    expect(service!.priceLabel, '2.75');
    expect(catalog.changes, hasLength(2));

    controller.updateService(
      categoryId: category.id,
      service: service.copyWith(price: 3.10, active: false),
    );

    catalog = container.read(catalogProvider);
    final updated = catalog.findService(service.id)!;
    expect(updated.priceLabel, '3.10');
    expect(updated.active, isFalse);
    expect(catalog.changes.first.changeLabel, 'Price');

    controller.reset();

    catalog = container.read(catalogProvider);
    expect(catalog.isCustom, isFalse);
    expect(catalog.changes, isEmpty);
    expect(catalog.findCategory(category.id), isNull);
  });

  testWidgets('welcome anchors the primary action and omits the sample order', (
    tester,
  ) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('LDR-0042'), findsNothing);
    expect(find.text('Express · 2.00 / kg'), findsNothing);

    final getStarted = find.text('Get started');
    final caption = find.text('Track every order from drop-off to pickup.');
    expect(getStarted, findsOneWidget);
    expect(caption, findsOneWidget);

    final buttonBottom = tester.getBottomLeft(getStarted).dy;
    final captionBottom = tester.getBottomLeft(caption).dy;
    expect(buttonBottom, greaterThan(844 - 150));
    expect(captionBottom, greaterThan(844 - 70));
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer home fits a 360 px phone', (tester) async {
    _usePhone(tester, width: 360, height: 800);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _signIn(tester, 'Customer A');

    expect(find.text('Active order'), findsOneWidget);
    expect(find.text('New order'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-in has no back link and the account picker only fills', (
    tester,
  ) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Use your details to sign in.'), findsOneWidget);
    expect(find.text('Select account'), findsOneWidget);
    expect(find.byType(WashdayBackLink), findsNothing);

    await _chooseAccount(tester, 'Customer A');

    expect(find.text('Active order'), findsNothing);
    expect(find.byKey(const Key('sign-in-submit')), findsOneWidget);
    expect(find.text('customer.a@washday.test'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();

    expect(find.text('GOOD MORNING, ALEX'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-in validates every field before routing', (tester) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Active order'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('sign-in-email')),
      'nobody@washday.test',
    );
    await tester.enterText(
      find.byKey(const Key('sign-in-password')),
      'anything',
    );
    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('We couldn’t find an account with that email.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('sign-in-email')),
      'customer.a@washday.test',
    );
    await tester.enterText(
      find.byKey(const Key('sign-in-password')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Check your password and try again.'), findsOneWidget);
    expect(find.text('Active order'), findsNothing);

    await _chooseAccount(tester, 'Customer A');
    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();

    expect(find.text('GOOD MORNING, ALEX'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account menu opens settings, help and log out', (tester) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _signIn(tester, 'Customer A');

    await tester.tap(find.text('Customer A').first);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);

    await tester.tapAt(const Offset(20, 140));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsNothing);
    expect(find.text('Log out'), findsNothing);

    await tester.tap(find.text('Customer A').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Your account, preferences and support.'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('Help & support'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Help & support'));
    await tester.pumpAndSettle();

    expect(
      find.text('Quick answers for common shop questions.'),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(20, 100));
    await tester.pumpAndSettle();

    expect(find.text('Quick answers for common shop questions.'), findsNothing);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Use your details to sign in.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer orders filter, refresh and show skeleton loading', (
    tester,
  ) async {
    _usePhone(tester);

    final router = buildWashdayRouter();
    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    router.go('/customer/orders');
    await tester.pump();
    await tester.pump();

    final loading = tester.widget<Semantics>(
      find.byKey(const Key('orders-loading')),
    );
    expect(loading.properties.label, 'Loading orders');
    expect(loading.properties.liveRegion, isTrue);
    expect(find.byType(WashdaySkeletonBlock), findsWidgets);
    expect(find.text('LDR-0042 · Express wash'), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('orders-loading')), findsNothing);
    expect(find.byType(WashdaySkeletonBlock), findsNothing);
    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0039 · Press only'), findsOneWidget);
    expect(find.text('LDR-0031 · Wash & fold'), findsOneWidget);
    expect(find.text('LDR-0045 · Press only'), findsOneWidget);
    expect(find.text('10 orders'), findsOneWidget);

    await tester.tap(find.widgetWithText(WashdayFilterChip, 'Active'));
    await tester.pumpAndSettle();

    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0039 · Press only'), findsNothing);
    expect(find.text('LDR-0031 · Wash & fold'), findsNothing);
    expect(find.text('6 of 10'), findsOneWidget);

    await tester.tap(find.widgetWithText(WashdayFilterChip, 'Declined'));
    await tester.pumpAndSettle();

    expect(find.text('LDR-0050 · Dry clean'), findsOneWidget);
    expect(find.text('LDR-0042 · Express wash'), findsNothing);
    expect(find.text('1 of 10'), findsOneWidget);

    await tester.tap(find.widgetWithText(WashdayFilterChip, 'Collected'));
    await tester.pumpAndSettle();

    expect(find.text('LDR-0042 · Express wash'), findsNothing);
    expect(find.text('LDR-0039 · Press only'), findsOneWidget);
    expect(find.text('LDR-0031 · Wash & fold'), findsOneWidget);
    expect(find.text('2 of 10'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(WashdayFilterChip, 'All'));
    await tester.tap(find.widgetWithText(WashdayFilterChip, 'All'));
    await tester.pumpAndSettle();

    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0039 · Press only'), findsOneWidget);
    expect(find.text('LDR-0031 · Wash & fold'), findsOneWidget);
    expect(find.text('LDR-0045 · Press only'), findsOneWidget);
    expect(find.text('10 orders'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('orders-filter-button')));
    await tester.tap(find.byKey(const Key('orders-filter-button')));
    await tester.pumpAndSettle();

    expect(find.text('Filter orders'), findsOneWidget);
    await tester.tap(find.text('Last 7 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('orders-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('9 of 10'), findsOneWidget);
    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0039 · Press only'), findsOneWidget);
    expect(find.text('LDR-0045 · Press only'), findsOneWidget);
    expect(find.text('LDR-0031 · Wash & fold'), findsNothing);

    await tester.ensureVisible(
      find.widgetWithText(WashdayFilterChip, 'Active'),
    );
    await tester.tap(find.widgetWithText(WashdayFilterChip, 'Active'));
    await tester.pumpAndSettle();

    expect(find.text('6 of 10'), findsOneWidget);
    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0039 · Press only'), findsNothing);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('10 orders'), findsOneWidget);
    expect(find.text('Last 7 days'), findsNothing);
    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0039 · Press only'), findsOneWidget);
    expect(find.text('LDR-0031 · Wash & fold'), findsOneWidget);
    expect(find.text('LDR-0045 · Press only'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('orders-filter-button')));
    await tester.tap(find.byKey(const Key('orders-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last 30 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('orders-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('10 of 10'), findsOneWidget);
    expect(find.text('Last 30 days'), findsOneWidget);
    expect(find.text('LDR-0031 · Wash & fold'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('orders-filter-button')));
    await tester.tap(find.byKey(const Key('orders-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('orders-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('4 of 10'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0051 · Express wash'), findsOneWidget);
    expect(find.text('LDR-0039 · Press only'), findsNothing);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('orders-filter-button')));
    await tester.tap(find.byKey(const Key('orders-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom range'));
    await tester.pumpAndSettle();

    expect(find.text('Choose dates'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Tap Start, then choose a date.'), findsOneWidget);
    expect(find.text('Not set'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('custom-range-previous')));
    await tester.pumpAndSettle();

    expect(find.text('September 2026'), findsOneWidget);
    await tester.tap(find.byKey(const Key('custom-range-start-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('range-day-2026-09-01')));
    await tester.pumpAndSettle();

    expect(find.text('1 Sep'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);
    expect(
      find.text('Start set. Tap End, then choose a date.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<WashdayButton>(find.byKey(const Key('custom-range-apply')))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('custom-range-end-field')));
    await tester.pumpAndSettle();

    expect(find.text('Choose an end date on or after 1 Sep.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('custom-range-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('range-day-2026-10-14')));
    await tester.pumpAndSettle();

    expect(find.text('14 Oct'), findsOneWidget);
    expect(
      find.text('44 days selected. Tap Start or End to change a date.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('custom-range-start-field')));
    await tester.pumpAndSettle();

    expect(find.text('September 2026'), findsOneWidget);
    await tester.tap(find.byKey(const Key('range-day-2026-09-30')));
    await tester.pumpAndSettle();

    expect(find.text('30 Sep'), findsOneWidget);
    expect(find.text('14 Oct'), findsOneWidget);
    expect(
      find.text('15 days selected. Tap Start or End to change a date.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('range-day-2026-09-01')));
    await tester.pumpAndSettle();

    expect(
      find.text('44 days selected. Tap Start or End to change a date.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('custom-range-apply')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('orders-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('10 of 10'), findsOneWidget);
    expect(find.text('1 Sep – 14 Oct'), findsOneWidget);
    expect(find.text('LDR-0031 · Wash & fold'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    // Earlier ensureVisible calls leave the page scrolled; pin to the top so
    // the downward drag overscrolls and triggers the refresh indicator.
    final pageScroll = find.byType(SingleChildScrollView).first;
    Scrollable.of(
      tester.element(find.text('Order history')),
    ).position.jumpTo(0);
    await tester.pumpAndSettle();

    await tester.drag(pageScroll, const Offset(0, 380));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WashdaySkeletonBlock), findsWidgets);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byType(WashdaySkeletonBlock), findsNothing);
    expect(find.text('LDR-0042 · Express wash'), findsOneWidget);
    expect(find.text('10 orders'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status chips scroll with the arrow buttons on a narrow phone', (
    tester,
  ) async {
    _usePhone(tester, width: 360);

    final router = buildWashdayRouter();
    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    router.go('/customer/orders');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    final scrollable = find.byKey(const Key('orders-status-scroll'));
    expect(scrollable, findsOneWidget);

    double offset() =>
        tester.widget<SingleChildScrollView>(scrollable).controller!.offset;

    expect(offset(), 0);
    expect(
      tester
          .widget<GestureDetector>(
            find.descendant(
              of: find.byKey(const Key('orders-status-left')),
              matching: find.byType(GestureDetector),
            ),
          )
          .onTap,
      isNull,
      reason: 'Left arrow should start disabled at the first chip',
    );

    await tester.tap(find.byKey(const Key('orders-status-right')));
    await tester.pumpAndSettle();

    expect(offset(), greaterThan(0));
    expect(find.text('All').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('orders-status-left')));
    await tester.pumpAndSettle();

    expect(offset(), 0);
    expect(find.text('All'), findsOneWidget);

    // A manual drag also scrolls the row.
    await tester.drag(scrollable, const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(offset(), greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary role screens support pull-to-refresh', (tester) async {
    _usePhone(tester);

    final router = buildWashdayRouter();
    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    const routes = [
      '/customer/home',
      '/customer/orders',
      '/customer/vouchers',
      '/customer/notifications',
      '/customer/loyalty',
      '/customer/profile',
      '/customer/category/shirts',
      '/clerk/home',
      '/clerk/queue',
      '/owner/home',
      '/owner/services',
      '/owner/vouchers',
      '/owner/orders',
      '/owner/activity',
      '/owner/category/shirts',
    ];

    for (final route in routes) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(
        find.byType(RefreshIndicator),
        findsOneWidget,
        reason: 'Missing pull-to-refresh on $route',
      );
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('every route lays out on a 360 px phone', (tester) async {
    _usePhone(tester, width: 360, height: 800);

    final router = buildWashdayRouter();
    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    const routes = [
      '/',
      '/sign-in',
      '/customer/home',
      '/customer/orders',
      '/customer/orders/LDR-0042',
      '/customer/orders/LDR-0039',
      '/customer/orders/LDR-0039/receipt',
      '/customer/orders/LDR-0042/receipt',
      '/customer/vouchers',
      '/customer/profile',
      '/customer/loyalty',
      '/customer/notifications',
      '/customer/settings',
      '/customer/new-order',
      '/customer/category/shirts',
      '/customer/checkout/shirts-wash-fold',
      '/customer/order-placed/LDR-0051',
      '/customer/order-placed/LDR-0053',
      '/clerk/home',
      '/clerk/queue',
      '/clerk/queue/LDR-0051',
      '/clerk/new-order',
      '/clerk/weigh?order=LDR-0048',
      '/clerk/settings',
      '/owner/home',
      '/owner/services',
      '/owner/add-category',
      '/owner/category/shirts',
      '/owner/category/shirts/add-service',
      '/owner/category/shirts/edit-service/shirts-wash-fold',
      '/owner/vouchers',
      '/owner/more',
      '/owner/orders',
      '/owner/orders/LDR-0051',
      '/owner/orders/LDR-0048/weigh',
      '/owner/activity',
      '/owner/settings',
      '/owner/account',
    ];

    for (final route in routes) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Layout overflow on $route',
      );
    }
  });

  testWidgets('receipt shows the itemized in-app payment record', (
    tester,
  ) async {
    _usePhone(tester);

    final router = buildWashdayRouter();
    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    router.go('/customer/orders/LDR-0039');
    await tester.pumpAndSettle();

    expect(find.text('Receipt summary'), findsOneWidget);
    expect(find.text('View receipt'), findsOneWidget);
    expect(find.text('14.00'), findsNWidgets(2));

    await tester.ensureVisible(find.text('View receipt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Payment receipt'), findsOneWidget);
    expect(find.text('Press only'), findsOneWidget);
    expect(find.text('4 items × 3.50'), findsOneWidget);
    expect(find.text('Paid in full · Cash'), findsOneWidget);
    expect(find.textContaining('Print'), findsNothing);
    expect(tester.takeException(), isNull);

    router.go('/customer/orders/LDR-0031/receipt');
    await tester.pumpAndSettle();

    expect(find.text('WELCOME10 discount'), findsOneWidget);
    expect(find.text('−1.24'), findsOneWidget);
    expect(find.text('11.16'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vouchers focus on the code and confirm a copy', (tester) async {
    _usePhone(tester);

    final clipboardCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') clipboardCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final router = buildWashdayRouter();
    await tester.pumpWidget(_routerApp(router));
    await tester.pumpAndSettle();

    router.go('/customer/vouchers');
    await tester.pumpAndSettle();

    expect(find.text('Your vouchers'), findsOneWidget);
    expect(find.text('WELCOME10'), findsOneWidget);
    expect(find.text('Browse services'), findsNothing);

    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    expect(find.text('Copied'), findsOneWidget);
    expect(find.text('Voucher code copied.'), findsNothing);
    expect(clipboardCalls, hasLength(1));
    expect(
      (clipboardCalls.single.arguments as Map<Object?, Object?>)['text'],
      'WELCOME10',
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('welcome leads into the customer and owner areas', (
    tester,
  ) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Wash & fold · one shop'), findsOneWidget);
    await _signIn(tester, 'Owner');

    expect(find.text('Shop pulse'), findsOneWidget);
    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();

    expect(find.text('Service catalog'), findsOneWidget);
    expect(find.text('Shirts'), findsOneWidget);
    expect(find.text('Add category'), findsOneWidget);
  });

  testWidgets('a customer places an order and cancels it while pending', (
    tester,
  ) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _signIn(tester, 'Customer A');

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New order'));
    await tester.pumpAndSettle();

    expect(find.text('New order'), findsOneWidget);
    await tester.tap(find.text('Shirts'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wash & fold'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('continue-to-checkout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continue-to-checkout')));
    await tester.pumpAndSettle();

    expect(find.text('Review order'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();

    expect(find.text('Order placed.'), findsOneWidget);
    expect(find.text('LDR-0053'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    await tester.ensureVisible(find.text('View order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View order'));
    await tester.pumpAndSettle();

    expect(find.text('TRACK ORDER'), findsOneWidget);
    expect(find.byKey(const Key('cancel-order')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('cancel-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancel-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancel-order-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('You cancelled this order'), findsOneWidget);
    expect(find.byKey(const Key('cancel-order')), findsNothing);

    await tester.ensureVisible(find.text('Order history'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Order history'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('11 orders'), findsOneWidget);
    expect(find.text('LDR-0053 · Wash & fold'), findsOneWidget);
    expect(find.text('Cancelled'), findsWidgets);

    await tester.tap(find.widgetWithText(WashdayFilterChip, 'Active'));
    await tester.pumpAndSettle();

    expect(find.text('6 of 11'), findsOneWidget);
    expect(find.text('LDR-0053 · Wash & fold'), findsNothing);

    await tester.tap(find.widgetWithText(WashdayFilterChip, 'All'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(WashdayFilterChip, 'Declined'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 11'), findsOneWidget);
    expect(find.text('LDR-0053 · Wash & fold'), findsNothing);

    await tester.tap(find.widgetWithText(WashdayFilterChip, 'Collected'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 11'), findsOneWidget);
    expect(find.text('LDR-0053 · Wash & fold'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clerk accepts, receives, weighs, readies and hands over', (
    tester,
  ) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _signIn(tester, 'Clerk');

    await tester.tap(find.text('Queue'));
    await tester.pumpAndSettle();

    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('LDR-0051'), findsOneWidget);
    expect(find.text('LDR-0052'), findsOneWidget);

    await tester.tap(find.text('LDR-0051'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('accept-order')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('record-drop-off')), findsOneWidget);
    expect(find.text('Accepted'), findsWidgets);

    await tester.tap(find.byKey(const Key('record-drop-off')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weigh-order')), findsOneWidget);
    expect(find.text('Received'), findsWidgets);

    await tester.tap(find.byKey(const Key('weigh-order')));
    await tester.pumpAndSettle();

    expect(find.text('Weigh and confirm'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('weigh-measure')), '2.0');
    await tester.pump();
    await tester.tap(find.byKey(const Key('weigh-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Weight confirmed'), findsOneWidget);
    expect(find.text('Paid'), findsWidgets);

    // Let the confirmation snackbar clear the footer action before leaving.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Back to order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to order'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mark-ready')), findsOneWidget);
    await tester.tap(find.byKey(const Key('mark-ready')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mark-picked-up')), findsOneWidget);
    await tester.tap(find.byKey(const Key('mark-picked-up')));
    await tester.pumpAndSettle();

    expect(find.text('Order complete'), findsOneWidget);
    expect(find.byKey(const Key('mark-picked-up')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clerk declines a request with a required reason', (
    tester,
  ) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _signIn(tester, 'Clerk');

    await tester.tap(find.text('Queue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LDR-0052'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('decline-order')));
    await tester.pumpAndSettle();

    expect(find.text('Why is this order declined?'), findsOneWidget);
    expect(
      tester
          .widget<WashdayButton>(find.byKey(const Key('decline-confirm')))
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const Key('decline-reason')),
      'Duvet cleaning is fully booked this week.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('decline-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Decline reason'), findsOneWidget);
    expect(
      find.text('Duvet cleaning is fully booked this week.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('accept-order')), findsNothing);

    await tester.tap(find.text('Order queue'));
    await tester.pumpAndSettle();

    expect(find.text('LDR-0052'), findsNothing);
    expect(find.text('1 to review'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('owner can run the same order actions as the clerk', (
    tester,
  ) async {
    _usePhone(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _signIn(tester, 'Owner');

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.text('Shop orders'), findsOneWidget);
    await tester.tap(find.text('LDR-0051'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('accept-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record-drop-off')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weigh-order')));
    await tester.pumpAndSettle();

    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Queue'), findsNothing);

    await tester.enterText(find.byKey(const Key('weigh-measure')), '2.0');
    await tester.pump();
    await tester.tap(find.byKey(const Key('weigh-confirm')));
    await tester.pumpAndSettle();

    // Let the confirmation snackbar clear the footer action before leaving.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Back to order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to order'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mark-ready')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mark-picked-up')));
    await tester.pumpAndSettle();

    expect(find.text('Order complete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
