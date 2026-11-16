import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final sessionChanges = ref.watch(catalogProvider).changes;
    final orderEvents = ref.watch(ordersProvider).events;
    final entries = <(ActivityEvent, bool)>[
      for (final event in sessionChanges) (event, true),
      for (final event in orderEvents) (event, false),
    ];
    final visible = entries.where((entry) {
      if (_filter == 'all') return true;
      return entry.$1.kind == _filter;
    }).toList();
    final catalogEvents = entries.where((entry) {
      return entry.$1.kind == 'catalog';
    }).length;

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Audit',
          title: 'Activity log',
          subtitle: 'Who changed what, when, and the old → new value.',
          dense: true,
        ),
        WashdayMetricStrip(
          metrics: [
            WashdayMetric(value: '${visible.length}', label: 'Shown'),
            WashdayMetric(value: '$catalogEvents', label: 'Catalog'),
            WashdayMetric(
              value: '${sessionChanges.length}',
              label: 'This session',
            ),
          ],
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WashdaySectionHead(
                kicker: 'Trace',
                title: 'Activity',
                titleSize: 18,
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final option in const [
                    ('all', 'All'),
                    ('catalog', 'Catalog'),
                    ('orders', 'Orders'),
                    ('vouchers', 'Vouchers'),
                  ])
                    WashdayFilterChip(
                      label: option.$2,
                      selected: _filter == option.$1,
                      onTap: () => setState(() => _filter = option.$1),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (visible.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(WashdayRadii.control),
                    border: Border.all(color: WashdayColors.hairline),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.history_toggle_off_rounded,
                        size: 22,
                        color: WashdayColors.slate400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No activity matches this filter.',
                        style: WashdayType.muted(size: 12),
                      ),
                    ],
                  ),
                )
              else
                for (var index = 0; index < visible.length; index++)
                  _AuditEntry(
                    event: visible[index].$1,
                    recent: visible[index].$2,
                    last: index == visible.length - 1,
                  ),
            ],
          ),
        ),
        const WashdayNotice(
          title: 'Catalog history',
          body:
              'Every catalog change is recorded with the owner account, time and old → new values.',
        ),
      ],
    );
  }
}

class _AuditEntry extends StatelessWidget {
  const _AuditEntry({
    required this.event,
    required this.recent,
    required this.last,
  });

  final ActivityEvent event;
  final bool recent;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final (nodeColor, tintColor) = switch (event.kind) {
      'catalog' => (WashdayColors.teal600, WashdayColors.teal100),
      'vouchers' => (WashdayColors.ink, WashdayColors.slate100),
      _ => (WashdayColors.amber500, WashdayColors.amber100),
    };
    final badgeLabel = switch (event.kind) {
      'catalog' => 'Catalog',
      'vouchers' => 'Voucher',
      _ => 'Order',
    };
    final badgeColor = switch (event.kind) {
      'catalog' => WashdayColors.teal700,
      'vouchers' => WashdayColors.slate700,
      _ => WashdayColors.amber700,
    };
    final eventTime = event.time.startsWith('Today')
        ? event.time
        : 'Today · ${event.time}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tintColor,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.only(top: 3),
                      color: WashdayColors.hairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        event.actor,
                        style: WashdayType.style(
                          size: 11.5,
                          weight: 680,
                          color: WashdayColors.ink,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        eventTime,
                        style: WashdayType.muted(size: 9.5, height: 1.2),
                      ),
                      Container(
                        constraints: const BoxConstraints(minHeight: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: tintColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            recent ? '$badgeLabel · new' : badgeLabel,
                            style: WashdayType.style(
                              size: 8.5,
                              weight: 680,
                              color: badgeColor,
                              letterSpacing: 0.2,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: WashdayType.style(
                      size: 13,
                      weight: 610,
                      color: WashdayColors.inkSecondary,
                      height: 1.35,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (event.before != null && event.after != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: WashdayColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: WashdayColors.hairline),
                      ),
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 3,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (event.changeLabel != null)
                            Text(
                              event.changeLabel!.toUpperCase(),
                              style: WashdayType.style(
                                size: 8.5,
                                weight: 690,
                                color: WashdayColors.textSecondary,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                            ),
                          Text(
                            event.before!,
                            style: WashdayType.style(
                              size: 10.5,
                              weight: 520,
                              color: WashdayColors.red500,
                              height: 1.35,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: WashdayColors.red500,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: WashdayColors.slate400,
                          ),
                          Text(
                            event.after!,
                            style: WashdayType.style(
                              size: 10.5,
                              weight: 660,
                              color: WashdayColors.teal700,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      event.detail,
                      style: WashdayType.muted(size: 10.5, height: 1.45),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
