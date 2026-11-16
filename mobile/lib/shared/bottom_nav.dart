import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app/theme.dart';

class WashdayNavItem {
  const WashdayNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class WashdayBottomNav extends StatelessWidget {
  const WashdayBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<WashdayNavItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final stackLabels = MediaQuery.sizeOf(context).width < 380;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xF2FFFFFF),
            borderRadius: BorderRadius.circular(WashdayRadii.pill),
            border: Border.all(color: WashdayColors.hairlineStrong),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F1F374A),
                blurRadius: 34,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: SizedBox(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < items.length; index++)
                      Expanded(
                        child: _NavTab(
                          item: items[index],
                          selected: selectedIndex == index,
                          stackLabel: stackLabels,
                          onTap: () => onSelected(index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.stackLabel,
    required this.onTap,
  });

  final WashdayNavItem item;
  final bool selected;
  final bool stackLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : WashdayColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? WashdayColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(WashdayRadii.pill),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1F0C1A23),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: stackLabel
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 19, color: foreground),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WashdayType.style(
                          size: 10.5,
                          weight: selected ? 650 : 590,
                          color: foreground,
                          height: 1.1,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 19, color: foreground),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WashdayType.style(
                            size: 12,
                            weight: selected ? 650 : 590,
                            color: foreground,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
