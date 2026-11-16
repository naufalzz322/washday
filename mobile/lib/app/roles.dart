import 'package:flutter/widgets.dart';

enum WashdayRole {
  customer,
  clerk,
  owner;

  String get label => switch (this) {
    WashdayRole.customer => 'Customer',
    WashdayRole.clerk => 'Clerk',
    WashdayRole.owner => 'Owner',
  };

  String get initial => switch (this) {
    WashdayRole.customer => 'A',
    WashdayRole.clerk => 'K',
    WashdayRole.owner => 'O',
  };
}

class WashdayViewport {
  const WashdayViewport._();

  static const compactBreakpoint = 370.0;
  static const navStackBreakpoint = 380.0;
  static const contentMaxWidth = 460.0;
  static const navMaxWidth = 378.0;

  static double gutter(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint ? 16 : 20;
}
