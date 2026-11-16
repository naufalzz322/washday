import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock.dart';
import 'models.dart';
import 'seed.dart';

class OrdersState {
  const OrdersState({
    required this.orders,
    required this.events,
    required this.nextId,
  });

  final List<WashdayOrder> orders;
  final List<ActivityEvent> events;
  final int nextId;

  List<WashdayOrder> forCustomer(String? customerId) {
    return orders.where((order) => order.customerId == customerId).toList();
  }

  WashdayOrder? byId(String? id) {
    if (id == null) return null;
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  List<WashdayOrder> get openOrders =>
      orders.where((order) => order.isActive).toList();

  List<WashdayOrder> get requests =>
      orders.where((order) => order.stage == OrderStage.pending).toList();

  WashdayOrder? activeFor(String? customerId) {
    for (final order in forCustomer(customerId)) {
      if (order.isActive) return order;
    }
    return null;
  }

  WashdayOrder? latestFor(String? customerId) {
    final own = forCustomer(customerId);
    return own.isEmpty ? null : own.first;
  }

  OrdersState copyWith({
    List<WashdayOrder>? orders,
    List<ActivityEvent>? events,
    int? nextId,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      events: events ?? this.events,
      nextId: nextId ?? this.nextId,
    );
  }
}

class OrdersController extends Notifier<OrdersState> {
  @override
  OrdersState build() {
    final today = ref.watch(washdayTodayProvider);
    final orders = buildSeedOrders(today);
    return OrdersState(
      orders: orders,
      events: buildSeedActivity(today),
      nextId: _nextIdFrom(orders),
    );
  }

  int _nextIdFrom(List<WashdayOrder> orders) {
    var highest = 0;
    for (final order in orders) {
      final numeric = int.tryParse(order.id.replaceFirst('LDR-', ''));
      if (numeric != null && numeric > highest) highest = numeric;
    }
    return highest + 1;
  }

  DateTime get _now => ref.read(washdayClockProvider)();

  String get _stamp => 'Today · ${clockTime(_now)}';

  WashdayOrder? byId(String? id) => state.byId(id);

  WashdayOrder placeOrder({
    required WashdayAccount account,
    required ServiceOffering service,
    required String dropOff,
    String? note,
    bool useWelcomeVoucher = false,
  }) {
    final today = ref.read(washdayTodayProvider);
    final id = 'LDR-${state.nextId.toString().padLeft(4, '0')}';
    final trimmedNote = note?.trim();
    final order = WashdayOrder(
      id: id,
      customerId: account.customerId ?? account.id,
      customer: account.name,
      serviceId: service.id,
      service: service.name,
      unit: service.unit,
      unitRate: service.price,
      estimate: service.duration,
      stage: OrderStage.pending,
      placedOn: today,
      datedOn: today,
      dropOff: dropOff,
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
      voucherCode: useWelcomeVoucher ? welcomeVoucherCode : null,
    );

    state = state.copyWith(
      orders: [order, ...state.orders],
      nextId: state.nextId + 1,
      events: [
        _event(
          title: 'Order $id placed',
          detail: '${account.name} · ${service.name}',
          actor: account.name,
          before: 'Not placed',
          after: 'Pending',
        ),
        ...state.events,
      ],
    );
    return order;
  }

  void accept(String id, {String actor = 'Clerk'}) {
    final order = state.byId(id);
    if (order == null || order.stage != OrderStage.pending) return;
    _replace(order.copyWith(stage: OrderStage.accepted));
    _log(
      order: order,
      title: 'Order $id accepted',
      before: 'Pending',
      after: 'Accepted',
      actor: actor,
    );
  }

  void decline(String id, String reason, {String actor = 'Clerk'}) {
    final order = state.byId(id);
    if (order == null || order.stage != OrderStage.pending) return;
    _replace(
      order.copyWith(stage: OrderStage.declined, declineReason: reason.trim()),
    );
    _log(
      order: order,
      title: 'Order $id declined',
      before: 'Pending',
      after: 'Declined',
      actor: actor,
      detailSuffix: reason.trim(),
    );
  }

  void cancel(String id) {
    final order = state.byId(id);
    if (order == null || order.stage != OrderStage.pending) return;
    _replace(order.copyWith(stage: OrderStage.cancelled));
    _log(
      order: order,
      title: 'Order $id cancelled by customer',
      before: 'Pending',
      after: 'Cancelled',
      actor: order.customer,
    );
  }

  void recordDropOff(String id, {String actor = 'Clerk'}) {
    final order = state.byId(id);
    if (order == null || order.stage != OrderStage.accepted) return;
    _replace(order.copyWith(stage: OrderStage.received));
    _log(
      order: order,
      title: 'Drop-off recorded for $id',
      before: 'Accepted',
      after: 'Received',
      actor: actor,
    );
  }

  void confirmWeigh({
    required String id,
    required double measure,
    required double subtotal,
    required double discount,
    required double total,
    String? voucherCode,
    String actor = 'Clerk',
  }) {
    final order = state.byId(id);
    if (order == null || order.stage != OrderStage.received) return;
    final measureLabel = order.unit == 'kg'
        ? '${measure.toStringAsFixed(1)} kg'
        : '${measure.toInt()} items';
    _replace(
      order.copyWith(
        stage: OrderStage.processing,
        measure: measure,
        subtotal: subtotal,
        discount: discount,
        total: total,
        voucherCode: voucherCode,
      ),
    );
    _log(
      order: order,
      title: 'Order $id weighed and confirmed',
      before: 'Received',
      after: 'Processing',
      actor: actor,
      detailSuffix: '$measureLabel · ${total.toStringAsFixed(2)}',
    );
  }

  void recordPayment(String id, String method, {String actor = 'Clerk'}) {
    final order = state.byId(id);
    if (order == null || order.isPaid) return;
    _replace(order.copyWith(isPaid: true, paymentMethod: method));
    state = state.copyWith(
      events: [
        _event(
          title: 'Payment received for $id',
          detail: '${order.customer} · ${order.service}',
          actor: actor,
          before: 'Unpaid',
          after: 'Paid · $method',
          changeLabel: 'Payment',
        ),
        ...state.events,
      ],
    );
  }

  void markReady(String id, {String actor = 'Clerk'}) {
    final order = state.byId(id);
    if (order == null || order.stage != OrderStage.processing) return;
    _replace(order.copyWith(stage: OrderStage.ready));
    _log(
      order: order,
      title: 'Order $id marked ready',
      before: 'Processing',
      after: 'Ready',
      actor: actor,
    );
  }

  void markPickedUp(String id, {String actor = 'Clerk'}) {
    final order = state.byId(id);
    if (order == null || order.stage != OrderStage.ready) return;
    _replace(order.copyWith(stage: OrderStage.pickedUp));
    _log(
      order: order,
      title: 'Order $id marked picked up',
      before: 'Ready',
      after: 'Picked up',
      actor: actor,
    );
  }

  void _replace(WashdayOrder updated) {
    state = state.copyWith(
      orders: [
        for (final order in state.orders)
          if (order.id == updated.id) updated else order,
      ],
    );
  }

  void _log({
    required WashdayOrder order,
    required String title,
    required String before,
    required String after,
    required String actor,
    String detailSuffix = '',
  }) {
    state = state.copyWith(
      events: [
        _event(
          title: title,
          detail: detailSuffix.isEmpty
              ? '${order.customer} · ${order.service}'
              : '${order.customer} · ${order.service} · $detailSuffix',
          actor: actor,
          before: before,
          after: after,
        ),
        ...state.events,
      ],
    );
  }

  ActivityEvent _event({
    required String title,
    required String detail,
    required String actor,
    required String before,
    required String after,
    String changeLabel = 'Status',
  }) {
    return ActivityEvent(
      title: title,
      detail: detail,
      time: _stamp,
      tone: 'teal',
      actor: actor,
      changeLabel: changeLabel,
      before: before,
      after: after,
    );
  }
}

const welcomeVoucherCode = 'WELCOME10';

final ordersProvider = NotifierProvider<OrdersController, OrdersState>(
  OrdersController.new,
);

/// Builds the in-app receipt shown for collected orders.
OrderReceipt? receiptForOrder(WashdayOrder? order) {
  if (order == null || !order.isCollected) return null;
  final subtotal = (order.subtotal ?? order.total ?? 0).toStringAsFixed(2);
  final total = (order.total ?? order.subtotal ?? 0).toStringAsFixed(2);
  final discount = order.discount > 0
      ? order.discount.toStringAsFixed(2)
      : null;
  return OrderReceipt(
    orderId: order.id,
    customer: order.customer,
    collectedOn: longDate(order.datedOn),
    paymentMethod: order.paymentMethod ?? 'Cash',
    lines: [
      ReceiptLine(
        label: order.service,
        detail: '${order.measureLabel} × ${order.unitRateLabel}',
        amount: subtotal,
      ),
    ],
    subtotal: subtotal,
    discountLabel: discount == null ? null : order.voucherCode,
    discount: discount == null ? null : '−$discount',
    total: total,
  );
}
