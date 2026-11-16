import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class ClerkQueueScreen extends ConsumerStatefulWidget {
  const ClerkQueueScreen({super.key});

  @override
  ConsumerState<ClerkQueueScreen> createState() => _ClerkQueueScreenState();
}

class _ClerkQueueScreenState extends ConsumerState<ClerkQueueScreen> {
  final _searchController = TextEditingController();
  String _filter = 'all';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WashdayOrder> _matching(List<WashdayOrder> orders) {
    final query = _query.trim().toLowerCase();
    return orders.where((order) {
      return query.isEmpty ||
          order.id.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query) ||
          order.service.toLowerCase().contains(query);
    }).toList();
  }

  List<WashdayOrder> get _requests {
    final orders = ref.watch(ordersProvider);
    return _matching(orders.requests);
  }

  List<WashdayOrder> get _inShop {
    final orders = ref.watch(ordersProvider);
    final open = orders.openOrders
        .where((order) => order.stage != OrderStage.pending)
        .toList();
    return switch (_filter) {
      'ready' => _matching(
        open.where((order) => order.stage == OrderStage.ready).toList(),
      ),
      'weigh' => _matching(
        open.where((order) => order.stage == OrderStage.received).toList(),
      ),
      _ => _matching(open),
    };
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _openWeigh() async {
    final received = ref
        .watch(ordersProvider)
        .orders
        .where((order) => order.stage == OrderStage.received)
        .toList();
    if (received.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No dropped-off orders are waiting to be weighed.'),
          ),
        );
      return;
    }
    if (received.length == 1) {
      context.push('/clerk/weigh?order=${received.first.id}');
      return;
    }
    final picked = await showModalBottomSheet<WashdayOrder>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _WeighPickerSheet(orders: received),
    );
    if (!mounted || picked == null) return;
    context.push('/clerk/weigh?order=${picked.id}');
  }

  @override
  Widget build(BuildContext context) {
    final requests = _requests;
    final inShop = _inShop;
    final showRequests = _filter == 'all' || _filter == 'requests';
    final showInShop = _filter != 'requests';
    final filtered = _filter != 'all' || _query.trim().isNotEmpty;

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Clerk',
          title: 'Order queue',
          subtitle: 'Accept requests and move orders through the shop.',
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
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
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in const [
                    ('all', 'All'),
                    ('requests', 'Requests'),
                    ('weigh', 'To weigh'),
                    ('ready', 'Ready'),
                  ])
                    WashdayFilterChip(
                      label: option.$2,
                      selected: _filter == option.$1,
                      onTap: () => setState(() => _filter = option.$1),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showRequests) ...[
          _QueueCard(
            kicker: 'Requests',
            title: 'Waiting for the shop',
            countLabel: '${requests.length} to review',
            orders: requests,
            emptyMessage: 'No requests waiting for a decision.',
            onTap: (order) => context.push('/clerk/queue/${order.id}'),
          ),
          const SizedBox(height: 12),
        ],
        if (showInShop)
          _QueueCard(
            kicker: 'In shop',
            title: 'Accepted and in progress',
            countLabel: filtered && _filter != 'all'
                ? '${inShop.length} shown'
                : '${inShop.length} orders',
            orders: inShop,
            emptyMessage: _filter == 'ready'
                ? 'No orders are ready for pickup.'
                : _filter == 'weigh'
                ? 'No dropped-off orders are waiting to be weighed.'
                : 'No orders in the shop right now.',
            onTap: (order) => context.push('/clerk/queue/${order.id}'),
          ),
        Row(
          children: [
            Expanded(
              child: WashdayButton(
                label: 'Weigh an order',
                onPressed: _openWeigh,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: WashdayButton(
                label: 'Counter order',
                tone: WashdayButtonTone.secondary,
                onPressed: () => context.push('/clerk/new-order'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.kicker,
    required this.title,
    required this.countLabel,
    required this.orders,
    required this.emptyMessage,
    required this.onTap,
  });

  final String kicker;
  final String title;
  final String countLabel;
  final List<WashdayOrder> orders;
  final String emptyMessage;
  final ValueChanged<WashdayOrder> onTap;

  @override
  Widget build(BuildContext context) {
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 10),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WashdaySectionHead(
            kicker: kicker,
            title: title,
            titleSize: 18,
            trailing: WashdayCountPill(countLabel),
          ),
          const SizedBox(height: 10),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 22,
                    color: WashdayColors.slate400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: WashdayType.muted(size: 12.5),
                  ),
                ],
              ),
            )
          else
            for (var index = 0; index < orders.length; index++)
              _QueueRow(
                order: orders[index],
                showTopBorder: index > 0,
                onTap: () => onTap(orders[index]),
              ),
        ],
      ),
    );
  }
}

class _WeighPickerSheet extends StatelessWidget {
  const _WeighPickerSheet({required this.orders});

  final List<WashdayOrder> orders;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: WashdayColors.white,
              borderRadius: BorderRadius.circular(WashdayRadii.panel),
              border: Border.all(color: WashdayColors.hairline),
              boxShadow: const [
                BoxShadow(
                  color: WashdayColors.shadow,
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: WashdayColors.dottedBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const WashdayKicker('Weigh'),
                const SizedBox(height: 6),
                Text('Choose an order', style: WashdayType.title(size: 22)),
                const SizedBox(height: 4),
                Text(
                  'Orders that have been dropped off.',
                  style: WashdayType.muted(size: 12, height: 1.45),
                ),
                const SizedBox(height: 10),
                for (final order in orders)
                  WashdayListRow(
                    title: order.id,
                    subtitle: '${order.customer} · ${order.service}',
                    leading: WashdayLeadingTile(
                      background: WashdayColors.teal100,
                      foreground: WashdayColors.teal700,
                      child: Text(order.service.characters.first.toUpperCase()),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: WashdayColors.slate400,
                    ),
                    onTap: () => Navigator.of(context).pop(order),
                    showTopBorder: order != orders.first,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
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
    final isReady = order.stage == OrderStage.ready;
    final isProcessing = order.stage == OrderStage.processing;
    final isPending = order.stage == OrderStage.pending;

    return WashdayListRow(
      title: order.id,
      subtitle: '${order.customer} · ${order.service}',
      leading: WashdayLeadingTile(
        background: isReady
            ? WashdayColors.amber100
            : isPending
            ? WashdayColors.teal100
            : isProcessing
            ? WashdayColors.teal100
            : WashdayColors.surfaceMuted,
        foreground: isReady
            ? WashdayColors.amber700
            : isPending || isProcessing
            ? WashdayColors.teal700
            : WashdayColors.slate500,
        child: Text(initial),
      ),
      trailing: WashdayStatusPill(
        order.statusCopy,
        tone: isReady ? WashdayTone.warning : WashdayTone.neutral,
      ),
      onTap: onTap,
      showTopBorder: showTopBorder,
    );
  }
}
