import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme.dart';

class WashdayApp extends StatefulWidget {
  const WashdayApp({super.key});

  @override
  State<WashdayApp> createState() => _WashdayAppState();
}

class _WashdayAppState extends State<WashdayApp> {
  late final GoRouter _router = buildWashdayRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Washday',
      debugShowCheckedModeBanner: false,
      theme: buildWashdayTheme(),
      scrollBehavior: const _WashdayScrollBehavior(),
      routerConfig: _router,
    );
  }
}

/// Lets the local web preview drag-scroll with a mouse, so pull-to-refresh
/// can be reviewed the same way it is used on a phone.
class _WashdayScrollBehavior extends MaterialScrollBehavior {
  const _WashdayScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}
