import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/roles.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class WeighOrderScreen extends ConsumerStatefulWidget {
  const WeighOrderScreen({
    super.key,
    this.orderId,
    this.role = WashdayRole.clerk,
  });

  final String? orderId;
  final WashdayRole role;

  @override
  ConsumerState<WeighOrderScreen> createState() => _WeighOrderScreenState();
}

class _WeighOrderScreenState extends ConsumerState<WeighOrderScreen> {
  final _measureController = TextEditingController();
  bool _useVoucher = true;
  String _payment = 'Cash';
  String? _feedback;
  String? _confirmedOrderId;

  @override
  void dispose() {
    _measureController.dispose();
    super.dispose();
  }

  WashdayOrder? get _order {
    final state = ref.watch(ordersProvider);
    if (widget.orderId != null) return state.byId(widget.orderId);
    for (final order in state.orders) {
      if (order.stage == OrderStage.received) return order;
    }
    return null;
  }

  double get _measure {
    final raw = _measureController.text.replaceAll(',', '.').trim();
    return double.tryParse(raw) ?? 0;
  }

  String get _measureUnit => switch (_order?.unit) {
    'kg' => 'kg',
    'load' => 'loads',
    _ => 'items',
  };

  String get _measureLabel => switch (_order?.unit) {
    'kg' => '${_measure.toStringAsFixed(1)} kg',
    'load' => '${_measure.toInt()} loads',
    _ => '${_measure.toInt()} items',
  };

  double get _subtotal => _measure * (_order?.unitRate ?? 0);

  bool get _canUseVoucher =>
      _order?.voucherCode == welcomeVoucherCode && _subtotal >= 3;

  double get _discount {
    if (!_useVoucher || !_canUseVoucher) return 0;
    return math.min(_subtotal * 0.1, 5);
  }

  double get _total => _subtotal - _discount;

  String _money(double value) => value.toStringAsFixed(2);

  bool get _isOwner => widget.role == WashdayRole.owner;

  String get _backRoute {
    if (_isOwner) {
      return widget.orderId == null
          ? '/owner/orders'
          : '/owner/orders/${widget.orderId}';
    }
    return widget.orderId == null
        ? '/clerk/queue'
        : '/clerk/queue/${widget.orderId}';
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_backRoute);
    }
  }

  @override
  void initState() {
    super.initState();
    final order = ref.read(ordersProvider).byId(widget.orderId);
    if (order != null && order.stage == OrderStage.received) {
      _measureController.text = order.measure == null
          ? ''
          : order.unit == 'kg'
          ? order.measure!.toStringAsFixed(1)
          : order.measure!.toInt().toString();
    }
    _useVoucher = order?.voucherCode == welcomeVoucherCode;
  }

  void _confirm(WashdayOrder order) {
    final measure = _measure;
    if (measure <= 0) {
      setState(
        () => _feedback =
            'Enter a ${_measureUnit == 'kg' ? 'weight' : 'count'} first.',
      );
      return;
    }
    final subtotal = _subtotal;
    final discount = _discount;
    final total = _total;
    final controller = ref.read(ordersProvider.notifier);
    controller.confirmWeigh(
      id: order.id,
      measure: measure,
      subtotal: subtotal,
      discount: discount,
      total: total,
      voucherCode: discount > 0 ? order.voucherCode : null,
      actor: widget.role.label,
    );
    controller.recordPayment(order.id, _payment, actor: widget.role.label);
    setState(() {
      _feedback = null;
      _confirmedOrderId = order.id;
      _measureController.text = order.unit == 'kg'
          ? measure.toStringAsFixed(1)
          : measure.toInt().toString();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Weight confirmed · ${_money(total)} paid by $_payment.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final confirmed = _confirmedOrderId == order?.id;

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: order == null
                ? (_isOwner ? 'Orders' : 'Order queue')
                : order.id,
            onTap: _back,
          ),
        ),
        WashdayPageHeading(
          kicker: _isOwner ? 'Owner' : 'Counter',
          title: 'Weigh and confirm',
          subtitle: 'Check the weight, discount and total.',
          dense: true,
        ),
        if (order == null)
          WashdayCard(
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('No order to weigh', style: WashdayType.title()),
                const SizedBox(height: 7),
                Text(
                  'Choose an order that has been dropped off to record its weight.',
                  style: WashdayType.muted(size: 14, height: 1.45),
                ),
                const SizedBox(height: 14),
                WashdayButton(
                  label: 'Back to the queue',
                  tone: WashdayButtonTone.secondary,
                  onPressed: () => context.go(_backRoute),
                ),
              ],
            ),
          )
        else if (order.stage != OrderStage.received && !confirmed)
          WashdayCard(
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Already measured', style: WashdayType.title()),
                const SizedBox(height: 7),
                Text(
                  '${order.id} is ${order.statusCopy.toLowerCase()}. Its weight was recorded earlier.',
                  style: WashdayType.muted(size: 14, height: 1.45),
                ),
                const SizedBox(height: 14),
                WashdayButton(
                  label: 'Back to order',
                  tone: WashdayButtonTone.secondary,
                  onPressed: _back,
                ),
              ],
            ),
          )
        else ...[
          WashdayCard(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            shadow: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WashdayKicker('Order summary'),
                      const SizedBox(height: 6),
                      Text(order.service, style: WashdayType.title(size: 22)),
                      const SizedBox(height: 5),
                      Text(
                        '${order.id} · ${order.customer}',
                        style: WashdayType.muted(size: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                WashdayStatusPill(
                  confirmed ? 'Paid' : order.statusCopy,
                  tone: confirmed ? WashdayTone.teal : WashdayTone.neutral,
                ),
              ],
            ),
          ),
          WashdayCard(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Weight and discount', style: WashdayType.title(size: 17)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        key: const Key('weigh-measure'),
                        controller: _measureController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled: !confirmed,
                        onChanged: (_) => setState(() => _feedback = null),
                        style: WashdayType.style(
                          size: 32,
                          weight: 680,
                          color: WashdayColors.ink,
                          height: 1.1,
                          letterSpacing: -1.2,
                          tabularFigures: true,
                        ),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: WashdayColors.surfaceMuted,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _measureUnit,
                      style: WashdayType.style(
                        size: 18,
                        weight: 640,
                        color: WashdayColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Rate ${order.rateLabel}. ${_measure > 0 ? 'Measured $_measureLabel.' : 'Enter the measured amount.'}',
                  style: WashdayType.muted(size: 11, height: 1.5),
                ),
                if (order.voucherCode != null) ...[
                  const SizedBox(height: 14),
                  _DiscountChoice(
                    selected: _useVoucher,
                    title: '${order.voucherCode} · 10% off',
                    subtitle: 'Minimum spend 3.00 · capped at 5.00',
                    onTap: confirmed
                        ? null
                        : () => setState(() {
                            _useVoucher = true;
                            _feedback = null;
                          }),
                  ),
                  const SizedBox(height: 8),
                  _DiscountChoice(
                    selected: !_useVoucher,
                    title: 'No discount',
                    onTap: confirmed
                        ? null
                        : () => setState(() {
                            _useVoucher = false;
                            _feedback = null;
                          }),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: WashdayColors.hairline),
                    ),
                  ),
                  child: Column(
                    children: [
                      _PriceRow(label: 'Subtotal', amount: _money(_subtotal)),
                      _PriceRow(
                        label: 'Discount',
                        amount: _discount > 0
                            ? '−${_money(_discount)}'
                            : '0.00',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  style: WashdayType.strong(size: 13.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  confirmed ? 'Paid' : 'Due at the counter',
                                  style: WashdayType.muted(size: 10.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _money(_total),
                            key: const Key('weigh-total'),
                            style: WashdayType.style(
                              size: 26,
                              weight: 690,
                              color: WashdayColors.ink,
                              height: 1,
                              letterSpacing: -1.1,
                              tabularFigures: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          WashdayCard(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Payment method', style: WashdayType.title(size: 17)),
                const SizedBox(height: 9),
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
                      WashdayFilterChip(
                        label: method,
                        selected: _payment == method,
                        onTap: () {
                          if (confirmed) return;
                          setState(() => _payment = method);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                WashdayButton(
                  key: const Key('weigh-confirm'),
                  label: confirmed
                      ? 'Weight confirmed'
                      : 'Confirm weight and payment',
                  icon: confirmed ? Icons.check_rounded : null,
                  height: 50,
                  onPressed: confirmed ? null : () => _confirm(order),
                ),
                if (_feedback != null) ...[
                  const SizedBox(height: 9),
                  Text(
                    _feedback!,
                    textAlign: TextAlign.center,
                    style: WashdayType.style(
                      size: 12,
                      weight: 580,
                      color: WashdayColors.red500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (confirmed)
            WashdayButton(
              label: 'Back to order',
              tone: WashdayButtonTone.secondary,
              onPressed: _back,
            ),
        ],
      ],
    );
  }
}

class _DiscountChoice extends StatelessWidget {
  const _DiscountChoice({
    required this.selected,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: selected
                ? WashdayColors.teal100
                : WashdayColors.surfaceMuted,
            borderRadius: BorderRadius.circular(WashdayRadii.control),
            border: Border.all(
              color: selected ? WashdayColors.teal600 : WashdayColors.hairline,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: WashdayType.style(
                        size: 12.5,
                        weight: 640,
                        color: WashdayColors.ink,
                        height: 1.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: WashdayType.muted(size: 10.5, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: selected ? WashdayColors.teal700 : WashdayColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? WashdayColors.teal700
                        : WashdayColors.hairlineStrong,
                    width: 1.3,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 11,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: WashdayType.muted(size: 13, height: 1.4)),
          ),
          Text(
            amount,
            style: WashdayType.style(
              size: 13,
              weight: 650,
              color: WashdayColors.inkSecondary,
              tabularFigures: true,
            ),
          ),
        ],
      ),
    );
  }
}
