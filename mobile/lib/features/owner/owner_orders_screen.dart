import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class OwnerOrdersScreen extends ConsumerStatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  ConsumerState<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends ConsumerState<OwnerOrdersScreen> {
  final _searchController = TextEditingController();
  String _filter = 'all';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WashdayOrder> get _visibleOrders {
    final query = _query.trim().toLowerCase();
    final orders = ref.watch(ordersProvider).orders;
    return orders.where((order) {
      final matchesFilter = switch (_filter) {
        'requests' => order.stage == OrderStage.pending,
        'in_shop' => order.isActive && order.stage != OrderStage.pending,
        'ready' => order.stage == OrderStage.ready,
        'collected' => order.isCollected,
        'declined' => order.isDeclined,
        _ => true,
      };
      final matchesQuery =
          query.isEmpty ||
          order.id.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query) ||
          order.service.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleOrders;
    final orders = ref.watch(ordersProvider).orders;
    final requests = orders
        .where((order) => order.stage == OrderStage.pending)
        .length;
    final inShop = orders
        .where((order) => order.isActive && order.stage != OrderStage.pending)
        .length;
    final collected = orders.where((order) => order.isCollected).length;
    final filtered = _filter != 'all' || _query.trim().isNotEmpty;

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Owner',
          title: 'Orders',
          subtitle: 'Review requests and move orders through the shop.',
          dense: true,
        ),
        WashdayMetricStrip(
          metrics: [
            WashdayMetric(value: '$requests', label: 'Requests'),
            WashdayMetric(value: '$inShop', label: 'In shop'),
            WashdayMetric(value: '$collected', label: 'Picked up'),
          ],
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          shadow: false,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            style: WashdayType.body(size: 14),
            decoration: InputDecoration(
              hintText: 'Order ID, customer or service',
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: WashdayColors.slate400,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: WashdayColors.textSecondary,
                      ),
                      tooltip: 'Clear search',
                    ),
              filled: true,
              fillColor: WashdayColors.surfaceMuted,
            ),
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WashdaySectionHead(
                kicker: 'All orders',
                title: 'Shop orders',
                titleSize: 18,
                trailing: WashdayCountPill(
                  filtered
                      ? '${visible.length} shown'
                      : '${visible.length} orders',
                ),
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final option in const [
                    ('all', 'All'),
                    ('requests', 'Requests'),
                    ('in_shop', 'In shop'),
                    ('ready', 'Ready'),
                    ('collected', 'Collected'),
                    ('declined', 'Declined'),
                  ])
                    WashdayFilterChip(
                      label: option.$2,
                      selected: _filter == option.$1,
                      onTap: () => setState(() => _filter = option.$1),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 22,
                        color: WashdayColors.slate400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        filtered
                            ? 'No orders match this search.'
                            : 'No orders yet.',
                        style: WashdayType.muted(size: 12.5),
                      ),
                    ],
                  ),
                )
              else
                for (var index = 0; index < visible.length; index++)
                  _OwnerOrderRow(
                    order: visible[index],
                    showTopBorder: index > 0,
                    onTap: () =>
                        context.push('/owner/orders/${visible[index].id}'),
                  ),
            ],
          ),
        ),
        const WashdayNotice(
          title: 'Shop actions',
          body:
              'Open an order to accept or decline it, record drop-off, confirm the weight and payment, mark it ready or hand it over.',
        ),
      ],
    );
  }
}

class _OwnerOrderRow extends StatelessWidget {
  const _OwnerOrderRow({
    required this.order,
    required this.showTopBorder,
    required this.onTap,
  });

  final WashdayOrder order;
  final bool showTopBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = order.service.characters.first.toUpperCase();
    final tone = switch (order.stage) {
      OrderStage.ready => WashdayTone.warning,
      OrderStage.declined => WashdayTone.red,
      OrderStage.processing || OrderStage.pickedUp => WashdayTone.teal,
      _ => WashdayTone.neutral,
    };

    return WashdayListRow(
      title: order.id,
      subtitle: '${order.customer} · ${order.service} · ${order.counterLabel}',
      leading: WashdayLeadingTile(
        background: order.stage == OrderStage.ready
            ? WashdayColors.amber100
            : order.isActive
            ? WashdayColors.teal100
            : WashdayColors.surfaceMuted,
        foreground: order.stage == OrderStage.ready
            ? WashdayColors.amber700
            : order.isActive
            ? WashdayColors.teal700
            : WashdayColors.slate500,
        child: Text(initial),
      ),
      trailing: WashdayStatusPill(order.statusCopy, tone: tone),
      onTap: onTap,
      showTopBorder: showTopBorder,
    );
  }
}
