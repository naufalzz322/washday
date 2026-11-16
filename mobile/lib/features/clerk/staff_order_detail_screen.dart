import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/roles.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class StaffOrderDetailScreen extends ConsumerWidget {
  const StaffOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.role,
  });

  final String orderId;
  final WashdayRole role;

  bool get _isOwner => role == WashdayRole.owner;

  String get _backLabel => _isOwner ? 'Orders' : 'Order queue';

  String get _backRoute => _isOwner ? '/owner/orders' : '/clerk/queue';

  String get _roleLabel => _isOwner ? 'Owner' : 'Counter';

  String get _actor => role.label;

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) => const _DeclineSheet(),
    );
    if (reason == null || !context.mounted) return;
    ref.read(ordersProvider.notifier).decline(orderId, reason, actor: _actor);
    _notify(context, 'Order declined.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersProvider).byId(orderId);

    if (order == null) {
      return WashdayPage(
        gap: 12,
        topPadding: 10,
        bottomClearance: 112,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: WashdayBackLink(
              label: _backLabel,
              onTap: () => context.go(_backRoute),
            ),
          ),
          WashdayCard(
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Order not found', style: WashdayType.title()),
                const SizedBox(height: 7),
                Text(
                  'This order isn’t in the queue. It may have been removed.',
                  style: WashdayType.muted(size: 14, height: 1.45),
                ),
                const SizedBox(height: 14),
                WashdayButton(
                  label: 'Back to $_backLabel',
                  tone: WashdayButtonTone.secondary,
                  onPressed: () => context.go(_backRoute),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final controller = ref.read(ordersProvider.notifier);
    final tone = switch (order.stage) {
      OrderStage.declined => WashdayTone.red,
      OrderStage.ready => WashdayTone.warning,
      OrderStage.pickedUp || OrderStage.processing => WashdayTone.teal,
      _ => WashdayTone.neutral,
    };

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: _backLabel,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(_backRoute);
              }
            },
          ),
        ),
        WashdayPageHeading(
          kicker: _roleLabel,
          title: 'Order detail',
          subtitle: _isOwner
              ? 'Review and move this order through the shop.'
              : 'Update this order at the counter.',
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: WashdayKicker('Order')),
                  const SizedBox(width: 8),
                  WashdayStatusPill(
                    order.statusCopy,
                    showDot: true,
                    tone: tone,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                order.id,
                style: WashdayType.style(
                  size: 31,
                  weight: 680,
                  color: WashdayColors.ink,
                  height: 1,
                  letterSpacing: -1.5,
                  tabularFigures: true,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${order.customer} · ${order.service}',
                style: WashdayType.muted(size: 13, height: 1.4),
              ),
              if (order.note != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
                  decoration: BoxDecoration(
                    color: WashdayColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(WashdayRadii.control),
                    border: Border.all(color: WashdayColors.hairline),
                  ),
                  child: Text(
                    order.note!,
                    style: WashdayType.muted(size: 12, height: 1.45),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Stat(
                        label: order.measure == null ? 'Unit rate' : 'Measured',
                        value: order.measure == null
                            ? order.rateLabel
                            : order.measureLabel,
                      ),
                    ),
                    Container(width: 1, color: WashdayColors.hairline),
                    Expanded(
                      child: _Stat(
                        label: 'Estimate',
                        value: '${order.estimate} turnaround',
                      ),
                    ),
                    Container(width: 1, color: WashdayColors.hairline),
                    Expanded(
                      child: _Stat(label: 'Drop-off', value: order.dropOff),
                    ),
                  ],
                ),
              ),
              if (order.total != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order total',
                          style: WashdayType.muted(size: 11.5),
                        ),
                      ),
                      Text(
                        order.totalLabel!,
                        style: WashdayType.style(
                          size: 16,
                          weight: 680,
                          color: WashdayColors.ink,
                          tabularFigures: true,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _WorkflowCard(
          order: order,
          onAccept: () {
            controller.accept(order.id, actor: _actor);
            _notify(context, 'Order accepted.');
          },
          onDecline: () => _decline(context, ref),
          onDropOff: () {
            controller.recordDropOff(order.id, actor: _actor);
            _notify(context, 'Drop-off recorded.');
          },
          onWeigh: () => context.push(
            _isOwner
                ? '/owner/orders/${order.id}/weigh'
                : '/clerk/weigh?order=${order.id}',
          ),
          onReady: () {
            controller.markReady(order.id, actor: _actor);
            _notify(context, 'Order marked ready.');
          },
          onPickedUp: () {
            controller.markPickedUp(order.id, actor: _actor);
            _notify(context, 'Order marked picked up.');
          },
        ),
        if (order.isDeclined)
          _DeclinedNote(
            reason:
                order.declineReason ??
                'No reason was recorded for this decline.',
          ),
        if (order.isCancelled) const _CancelledNote(),
        if (_showPayment(order))
          _PaymentCard(
            order: order,
            onRecord: (method) {
              controller.recordPayment(order.id, method, actor: _actor);
              _notify(context, 'Payment recorded by $method.');
            },
          ),
        _StageHistory(order: order),
      ],
    );
  }

  bool _showPayment(WashdayOrder order) {
    return switch (order.stage) {
      OrderStage.received ||
      OrderStage.processing ||
      OrderStage.ready ||
      OrderStage.pickedUp => true,
      _ => false,
    };
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard({
    required this.order,
    required this.onAccept,
    required this.onDecline,
    required this.onDropOff,
    required this.onWeigh,
    required this.onReady,
    required this.onPickedUp,
  });

  final WashdayOrder order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onDropOff;
  final VoidCallback onWeigh;
  final VoidCallback onReady;
  final VoidCallback onPickedUp;

  @override
  Widget build(BuildContext context) {
    final (title, detail) = switch (order.stage) {
      OrderStage.pending => (
        'Review this request',
        'Accept it so the customer can bring the laundry in, or decline with a reason.',
      ),
      OrderStage.accepted => (
        'Waiting for drop-off',
        'Record the drop-off when the customer arrives at the counter.',
      ),
      OrderStage.received => (
        'Weigh the laundry',
        'Confirm the weight and total before the order moves to processing.',
      ),
      OrderStage.processing => (
        'Finish the laundry',
        'Mark the order ready once it has been washed and packed.',
      ),
      OrderStage.ready => (
        'Ready for pickup',
        'Hand the order over when the customer collects it.',
      ),
      OrderStage.pickedUp => (
        'Order complete',
        'This order has been collected. No further shop action is needed.',
      ),
      OrderStage.declined => (
        'Request declined',
        'The customer has been told this request cannot be taken.',
      ),
      OrderStage.cancelled => (
        'Order cancelled',
        'The customer cancelled this request before drop-off.',
      ),
    };

    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WashdaySectionHead(kicker: 'Next step', title: title, titleSize: 18),
          const SizedBox(height: 8),
          Text(detail, style: WashdayType.muted(size: 12.5, height: 1.45)),
          const SizedBox(height: 13),
          ..._actions(context),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    switch (order.stage) {
      case OrderStage.pending:
        return [
          WashdayButton(
            key: const Key('accept-order'),
            label: 'Accept order',
            icon: Icons.check_rounded,
            onPressed: onAccept,
          ),
          const SizedBox(height: 8),
          WashdayButton(
            key: const Key('decline-order'),
            label: 'Decline order',
            tone: WashdayButtonTone.secondary,
            height: 48,
            fontSize: 13.5,
            onPressed: onDecline,
          ),
        ];
      case OrderStage.accepted:
        return [
          WashdayButton(
            key: const Key('record-drop-off'),
            label: 'Record drop-off',
            icon: Icons.inventory_2_outlined,
            onPressed: onDropOff,
          ),
        ];
      case OrderStage.received:
        return [
          WashdayButton(
            key: const Key('weigh-order'),
            label: 'Weigh and confirm',
            icon: Icons.scale_outlined,
            onPressed: onWeigh,
          ),
        ];
      case OrderStage.processing:
        return [
          WashdayButton(
            key: const Key('mark-ready'),
            label: 'Mark ready',
            icon: Icons.check_circle_outline_rounded,
            onPressed: onReady,
          ),
        ];
      case OrderStage.ready:
        final paid = order.isPaid;
        return [
          WashdayButton(
            key: const Key('mark-picked-up'),
            label: paid ? 'Mark picked up' : 'Collect payment first',
            icon: paid ? Icons.shopping_bag_outlined : null,
            onPressed: paid ? onPickedUp : null,
          ),
          if (!paid) ...[
            const SizedBox(height: 7),
            Text(
              'Record the payment below to hand over this order.',
              textAlign: TextAlign.center,
              style: WashdayType.muted(size: 11, height: 1.4),
            ),
          ],
        ];
      case OrderStage.pickedUp:
      case OrderStage.declined:
      case OrderStage.cancelled:
        return const [];
    }
  }
}

class _DeclinedNote extends StatelessWidget {
  const _DeclinedNote({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: WashdayColors.red100,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        border: Border.all(color: const Color(0x4DC74636)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: WashdayColors.red500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Decline reason', style: WashdayType.strong(size: 13)),
                const SizedBox(height: 3),
                Text(
                  reason,
                  style: WashdayType.muted(size: 11.5, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledNote extends StatelessWidget {
  const _CancelledNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: WashdayColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        border: Border.all(color: WashdayColors.hairlineStrong),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.block_rounded,
              size: 18,
              color: WashdayColors.slate500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The customer cancelled this request. It never reached the counter.',
              style: WashdayType.style(
                size: 12,
                weight: 560,
                color: WashdayColors.inkSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.order, required this.onRecord});

  final WashdayOrder order;
  final ValueChanged<String> onRecord;

  @override
  Widget build(BuildContext context) {
    final paid = order.isPaid;
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WashdaySectionHead(
            kicker: 'Payment',
            title: 'Payment status',
            titleSize: 18,
            trailing: WashdayStatusPill(
              paid ? 'Paid' : 'Unpaid',
              tone: paid ? WashdayTone.teal : WashdayTone.warning,
              showDot: true,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            paid
                ? 'Recorded as ${order.paymentMethod ?? 'paid'}.'
                : order.total == null
                ? 'Confirm the weight before taking payment.'
                : 'Collect ${order.totalLabel} and choose how the customer paid.',
            style: WashdayType.muted(size: 12, height: 1.45),
          ),
          if (!paid && order.total != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final method in const [
                  'Cash',
                  'Transfer',
                  'QR',
                  'E-wallet',
                ])
                  ActionChip(
                    label: Text(method),
                    onPressed: () => onRecord(method),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StageHistory extends StatelessWidget {
  const _StageHistory({required this.order});

  final WashdayOrder order;

  @override
  Widget build(BuildContext context) {
    final current = order.stage.stepIndex;
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 6),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WashdaySectionHead(
            kicker: 'History',
            title: 'Status history',
            titleSize: 18,
          ),
          if (current == null) ...[
            const SizedBox(height: 8),
            Text(
              order.isDeclined
                  ? 'The request stopped at Pending.'
                  : 'The request stopped before drop-off.',
              style: WashdayType.muted(size: 12, height: 1.45),
            ),
          ] else ...[
            const SizedBox(height: 14),
            for (var index = 0; index < orderTimeline.length; index++)
              _HistoryItem(
                title: orderTimeline[index].label,
                detail: index < current
                    ? 'Complete'
                    : index == current
                    ? 'Current status'
                    : 'Not reached',
                last: index == orderTimeline.length - 1,
                active: index <= current,
              ),
          ],
        ],
      ),
    );
  }
}

class _DeclineSheet extends StatefulWidget {
  const _DeclineSheet();

  @override
  State<_DeclineSheet> createState() => _DeclineSheetState();
}

class _DeclineSheetState extends State<_DeclineSheet> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final canSubmit = _reasonController.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
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
                const WashdayKicker('Decline request'),
                const SizedBox(height: 6),
                Text(
                  'Why is this order declined?',
                  style: WashdayType.title(size: 21),
                ),
                const SizedBox(height: 5),
                Text(
                  'The customer sees this reason. Be specific about timing or the service.',
                  style: WashdayType.muted(size: 12, height: 1.45),
                ),
                const SizedBox(height: 12),
                WashdayField(
                  label: 'Reason',
                  controller: _reasonController,
                  hint: 'e.g. Fully booked for dry cleaning this week.',
                  maxLines: 3,
                  minLines: 3,
                  textFieldKey: const Key('decline-reason'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                WashdayButton(
                  key: const Key('decline-confirm'),
                  label: 'Decline order',
                  tone: WashdayButtonTone.secondary,
                  height: 48,
                  fontSize: 13.5,
                  onPressed: canSubmit
                      ? () => Navigator.of(
                          context,
                        ).pop(_reasonController.text.trim())
                      : null,
                ),
                const SizedBox(height: 8),
                WashdayButton(
                  label: 'Keep request',
                  height: 48,
                  fontSize: 13.5,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: WashdayType.label()),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WashdayType.style(
              size: 12.5,
              weight: 640,
              color: WashdayColors.ink,
              height: 1.25,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.title,
    required this.detail,
    this.last = false,
    this.active = false,
  });

  final String title;
  final String detail;
  final bool last;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 14,
            child: Column(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: active
                        ? WashdayColors.teal700
                        : WashdayColors.hairlineStrong,
                    shape: BoxShape.circle,
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
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: WashdayType.style(
                      size: 13,
                      weight: active ? 660 : 590,
                      color: active
                          ? WashdayColors.ink
                          : WashdayColors.inkSecondary,
                      height: 1.3,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: WashdayType.muted(size: 11, height: 1.35),
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
