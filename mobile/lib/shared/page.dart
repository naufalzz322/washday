import 'package:flutter/material.dart';

import '../app/roles.dart';
import '../app/theme.dart';

/// Replays the page fixtures behind a short pull-to-refresh pause.
///
/// This is review feedback only: no request is sent and no order, queue or
/// dashboard value changes.
abstract final class WashdayRefresh {
  static const duration = Duration(milliseconds: 700);

  static Future<void> replay() => Future<void>.delayed(duration);
}

class WashdayPage extends StatelessWidget {
  const WashdayPage({
    super.key,
    required this.children,
    this.gap = 14,
    this.topPadding = 12,
    this.bottomClearance = 112,
    this.contentMaxWidth = WashdayViewport.contentMaxWidth,
    this.onRefresh,
  });

  final List<Widget> children;
  final double gap;
  final double topPadding;

  /// Space reserved below the last item for the floating navigation or dock.
  final double bottomClearance;
  final double contentMaxWidth;

  /// Enables pull-to-refresh on pages where the content can change.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final gutter = WashdayViewport.gutter(context);
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    final content = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) content.add(SizedBox(height: gap));
      content.add(children[index]);
    }

    final scrollView = SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        gutter,
        topPadding,
        gutter,
        bottomClearance + bottomSafe,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: content,
          ),
        ),
      ),
    );

    if (onRefresh == null) return scrollView;

    return RefreshIndicator(
      onRefresh: onRefresh!,
      color: WashdayColors.teal700,
      backgroundColor: WashdayColors.white,
      displacement: 28,
      child: scrollView,
    );
  }
}
