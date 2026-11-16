import '../app/roles.dart';

enum OrderStage {
  pending,
  accepted,
  received,
  processing,
  ready,
  pickedUp,
  declined,
  cancelled,
}

extension OrderStageCopy on OrderStage {
  String get label => switch (this) {
    OrderStage.pending => 'Pending',
    OrderStage.accepted => 'Accepted',
    OrderStage.received => 'Received',
    OrderStage.processing => 'Processing',
    OrderStage.ready => 'Ready',
    OrderStage.pickedUp => 'Picked up',
    OrderStage.declined => 'Declined',
    OrderStage.cancelled => 'Cancelled',
  };

  String get description => switch (this) {
    OrderStage.pending => 'Waiting for the shop',
    OrderStage.accepted => 'The shop accepted your order',
    OrderStage.received => 'Drop-off recorded',
    OrderStage.processing => 'Laundry processed',
    OrderStage.ready => 'Ready for pickup',
    OrderStage.pickedUp => 'Collected from the shop',
    OrderStage.declined => 'The shop declined this request',
    OrderStage.cancelled => 'Cancelled before drop-off',
  };

  /// Position on the six-step order timeline, or null for terminal states.
  int? get stepIndex => switch (this) {
    OrderStage.pending => 0,
    OrderStage.accepted => 1,
    OrderStage.received => 2,
    OrderStage.processing => 3,
    OrderStage.ready => 4,
    OrderStage.pickedUp => 5,
    OrderStage.declined || OrderStage.cancelled => null,
  };

  /// Stages the shop can still act on.
  bool get isOpen => switch (this) {
    OrderStage.pending ||
    OrderStage.accepted ||
    OrderStage.received ||
    OrderStage.processing ||
    OrderStage.ready => true,
    _ => false,
  };
}

/// The six steps shown on customer progress indicators.
const orderTimeline = <OrderStage>[
  OrderStage.pending,
  OrderStage.accepted,
  OrderStage.received,
  OrderStage.processing,
  OrderStage.ready,
  OrderStage.pickedUp,
];

String shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String longDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String clockTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

class WashdayOrder {
  const WashdayOrder({
    required this.id,
    required this.customerId,
    required this.customer,
    required this.serviceId,
    required this.service,
    required this.unit,
    required this.unitRate,
    required this.estimate,
    required this.stage,
    required this.placedOn,
    required this.datedOn,
    this.dropOff = 'Today',
    this.note,
    this.measure,
    this.subtotal,
    this.discount = 0,
    this.total,
    this.voucherCode,
    this.isPaid = false,
    this.paymentMethod,
    this.declineReason,
  });

  final String id;
  final String customerId;
  final String customer;
  final String serviceId;
  final String service;

  /// Billing unit: `kg`, `item` or `load`.
  final String unit;
  final double unitRate;
  final String estimate;
  final OrderStage stage;

  final DateTime placedOn;

  /// Fixture date used by date filters: drop-off for open orders and
  /// collection for picked-up orders.
  final DateTime datedOn;

  final String dropOff;
  final String? note;

  /// Weighed kilograms or item count, once the counter has measured it.
  final double? measure;
  final double? subtotal;
  final double discount;
  final double? total;
  final String? voucherCode;
  final bool isPaid;
  final String? paymentMethod;
  final String? declineReason;

  String get unitRateLabel => unitRate.toStringAsFixed(2);

  String get statusCopy => stage.label;

  String get counterLabel => switch (stage) {
    OrderStage.pending => 'Waiting for the shop',
    OrderStage.accepted => 'Accepted · bring it in',
    OrderStage.received => 'Drop-off recorded',
    OrderStage.processing => 'In progress',
    OrderStage.ready => 'Ready for pickup',
    OrderStage.pickedUp => 'Picked up ${shortDate(datedOn)}',
    OrderStage.declined => 'Request declined',
    OrderStage.cancelled => 'Cancelled',
  };

  String get measureLabel {
    if (measure == null) return 'Not measured';
    return switch (unit) {
      'kg' => '${measure!.toStringAsFixed(1)} kg',
      'load' => '${measure!.toInt()} loads',
      _ => '${measure!.toInt()} items',
    };
  }

  String get rateLabel => '$unitRateLabel / $unit';

  String? get totalLabel => total?.toStringAsFixed(2);

  int get stageIndex => stage.stepIndex ?? 0;

  bool get isActive => stage.isOpen;
  bool get isDeclined => stage == OrderStage.declined;
  bool get isCancelled => stage == OrderStage.cancelled;
  bool get isCollected => stage == OrderStage.pickedUp;

  WashdayOrder copyWith({
    String? id,
    String? customerId,
    String? customer,
    String? serviceId,
    String? service,
    String? unit,
    double? unitRate,
    String? estimate,
    OrderStage? stage,
    DateTime? placedOn,
    DateTime? datedOn,
    String? dropOff,
    String? note,
    double? measure,
    double? subtotal,
    double? discount,
    double? total,
    String? voucherCode,
    bool? isPaid,
    String? paymentMethod,
    String? declineReason,
  }) {
    return WashdayOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      serviceId: serviceId ?? this.serviceId,
      service: service ?? this.service,
      unit: unit ?? this.unit,
      unitRate: unitRate ?? this.unitRate,
      estimate: estimate ?? this.estimate,
      stage: stage ?? this.stage,
      placedOn: placedOn ?? this.placedOn,
      datedOn: datedOn ?? this.datedOn,
      dropOff: dropOff ?? this.dropOff,
      note: note ?? this.note,
      measure: measure ?? this.measure,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      voucherCode: voucherCode ?? this.voucherCode,
      isPaid: isPaid ?? this.isPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      declineReason: declineReason ?? this.declineReason,
    );
  }
}

class WashdayAccount {
  const WashdayAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.detail,
    required this.role,
    this.customerId,
    this.hasPhoto = false,
  });

  /// Stable identifier; customer accounts use `customer-a` / `customer-b`.
  final String id;
  final String name;
  final String email;
  final String password;
  final String detail;
  final WashdayRole role;
  final String? customerId;
  final bool hasPhoto;

  String get homeRoute => switch (role) {
    WashdayRole.customer => '/customer/home',
    WashdayRole.clerk => '/clerk/home',
    WashdayRole.owner => '/owner/home',
  };

  String get initial => switch (role) {
    WashdayRole.customer => 'A',
    WashdayRole.clerk => 'K',
    WashdayRole.owner => 'O',
  };
}

class LoyaltyAccount {
  const LoyaltyAccount({
    required this.customerId,
    required this.stamps,
    required this.rewardAvailable,
    this.rewardUsedOn,
  });

  final String customerId;
  final int stamps;
  final bool rewardAvailable;
  final String? rewardUsedOn;

  LoyaltyAccount copyWith({int? stamps, bool? rewardAvailable}) {
    return LoyaltyAccount(
      customerId: customerId,
      stamps: stamps ?? this.stamps,
      rewardAvailable: rewardAvailable ?? this.rewardAvailable,
      rewardUsedOn: rewardUsedOn,
    );
  }
}

enum VoucherStatus { active, used, expired }

class CustomerVoucher {
  const CustomerVoucher({
    required this.customerId,
    required this.offer,
    required this.status,
    this.statusNote,
  });

  final String customerId;
  final VoucherOffer offer;
  final VoucherStatus status;
  final String? statusNote;
}

class WashdayNotification {
  const WashdayNotification({
    required this.customerId,
    required this.title,
    required this.detail,
    required this.orderId,
    required this.time,
    this.unread = false,
  });

  final String customerId;
  final String title;
  final String detail;
  final String orderId;
  final String time;
  final bool unread;
}

class ServiceOffering {
  const ServiceOffering({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.duration,
    this.active = true,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String duration;
  final bool active;

  String get priceLabel => price.toStringAsFixed(2);

  String get unitLabel => switch (unit) {
    'kg' => 'per kg',
    'load' => 'per load',
    _ => 'per item',
  };

  ServiceOffering copyWith({
    String? name,
    String? description,
    double? price,
    String? unit,
    String? duration,
    bool? active,
  }) {
    return ServiceOffering(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      duration: duration ?? this.duration,
      active: active ?? this.active,
    );
  }
}

class LaundryCategory {
  const LaundryCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.services,
  });

  final String id;
  final String name;
  final String description;
  final String imageAsset;
  final List<ServiceOffering> services;

  int get serviceCount => services.length;
}

class QueueEntry {
  const QueueEntry({
    required this.id,
    required this.customer,
    required this.service,
    required this.stage,
  });

  final String id;
  final String customer;
  final String service;
  final OrderStage stage;
}

class VoucherOffer {
  const VoucherOffer({
    required this.code,
    required this.discount,
    required this.minimumSpend,
    required this.cap,
    required this.description,
  });

  final String code;
  final String discount;
  final double minimumSpend;
  final double cap;
  final String description;
}

class ReceiptLine {
  const ReceiptLine({
    required this.label,
    required this.detail,
    required this.amount,
  });

  final String label;
  final String detail;
  final String amount;
}

class OrderReceipt {
  const OrderReceipt({
    required this.orderId,
    required this.customer,
    required this.collectedOn,
    required this.paymentMethod,
    required this.lines,
    required this.subtotal,
    required this.total,
    this.discountLabel,
    this.discount,
  });

  final String orderId;
  final String customer;
  final String collectedOn;
  final String paymentMethod;
  final List<ReceiptLine> lines;
  final String subtotal;
  final String total;
  final String? discountLabel;
  final String? discount;

  bool get hasDiscount => discount != null;
}

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;
}

class QueueLoad {
  const QueueLoad({
    required this.label,
    required this.count,
    required this.max,
    required this.tone,
  });

  final String label;
  final int count;
  final int max;
  final String tone;
}

class ActivityEvent {
  const ActivityEvent({
    required this.title,
    required this.detail,
    required this.time,
    required this.tone,
    this.kind = 'orders',
    this.actor = 'Shop',
    this.changeLabel,
    this.before,
    this.after,
  });

  final String title;
  final String detail;
  final String time;
  final String tone;

  /// Catalog, order or voucher history grouping.
  final String kind;
  final String actor;
  final String? changeLabel;
  final String? before;
  final String? after;
}

class OversightOrder {
  const OversightOrder({
    required this.id,
    required this.customer,
    required this.service,
    required this.stage,
    required this.payment,
    required this.intake,
    required this.measure,
    required this.total,
  });

  final String id;
  final String customer;
  final String service;
  final OrderStage stage;
  final String payment;
  final String intake;
  final String measure;
  final String total;

  bool get isPaid => payment.startsWith('Paid');

  String get statusCopy => stage.label;
}
