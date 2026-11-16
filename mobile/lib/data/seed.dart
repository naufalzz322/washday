import '../app/roles.dart';
import 'fixtures.dart';
import 'models.dart';

/// Accounts available from the sign-in account picker.
const washdayAccounts = <WashdayAccount>[
  WashdayAccount(
    id: 'customer-a',
    name: 'Customer A',
    email: 'customer.a@washday.test',
    password: 'washday-a',
    detail: 'Alex · Orders, offers and loyalty',
    role: WashdayRole.customer,
    customerId: 'customer-a',
    hasPhoto: true,
  ),
  WashdayAccount(
    id: 'customer-b',
    name: 'Customer B',
    email: 'customer.b@washday.test',
    password: 'washday-b',
    detail: 'Bea · Orders and pickup updates',
    role: WashdayRole.customer,
    customerId: 'customer-b',
  ),
  WashdayAccount(
    id: 'clerk',
    name: 'Clerk',
    email: 'clerk@washday.test',
    password: 'washday-k',
    detail: 'Front desk · Queue and counter',
    role: WashdayRole.clerk,
  ),
  WashdayAccount(
    id: 'owner',
    name: 'Owner',
    email: 'owner@washday.test',
    password: 'washday-o',
    detail: 'Shop owner · Catalog and oversight',
    role: WashdayRole.owner,
  ),
];

WashdayAccount? accountById(String? id) {
  if (id == null) return null;
  for (final account in washdayAccounts) {
    if (account.id == id) return account;
  }
  return null;
}

WashdayAccount? accountByEmail(String email) {
  final value = email.trim().toLowerCase();
  for (final account in washdayAccounts) {
    if (account.email.toLowerCase() == value) return account;
  }
  return null;
}

WashdayAccount customerAccount(String customerId) {
  for (final account in washdayAccounts) {
    if (account.customerId == customerId) return account;
  }
  return washdayAccounts.first;
}

const seedLoyalty = <LoyaltyAccount>[
  LoyaltyAccount(customerId: 'customer-a', stamps: 5, rewardAvailable: false),
  LoyaltyAccount(
    customerId: 'customer-b',
    stamps: 10,
    rewardAvailable: false,
    rewardUsedOn: 'Loyalty reward used',
  ),
];

LoyaltyAccount loyaltyFor(String? customerId) {
  for (final loyalty in seedLoyalty) {
    if (loyalty.customerId == customerId) return loyalty;
  }
  return seedLoyalty.first;
}

const seedVouchers = <CustomerVoucher>[
  CustomerVoucher(
    customerId: 'customer-a',
    offer: welcomeVoucher,
    status: VoucherStatus.active,
  ),
  CustomerVoucher(
    customerId: 'customer-b',
    offer: welcomeVoucher,
    status: VoucherStatus.used,
    statusNote: 'Used on your 4 Oct order',
  ),
];

CustomerVoucher? voucherFor(String? customerId) {
  for (final voucher in seedVouchers) {
    if (voucher.customerId == customerId) return voucher;
  }
  return null;
}

const seedNotifications = <WashdayNotification>[
  WashdayNotification(
    customerId: 'customer-a',
    title: 'Your laundry is ready',
    detail: 'Order LDR-0042 · Ready for pickup',
    orderId: 'LDR-0042',
    time: 'Today · 10:24 AM',
    unread: true,
  ),
  WashdayNotification(
    customerId: 'customer-a',
    title: 'Request accepted',
    detail: 'Order LDR-0049 · Bring it in to be weighed',
    orderId: 'LDR-0049',
    time: 'Today · 9:40 AM',
  ),
  WashdayNotification(
    customerId: 'customer-a',
    title: 'Request declined',
    detail: 'Order LDR-0050 · Dry clean',
    orderId: 'LDR-0050',
    time: 'Yesterday · 4:18 PM',
  ),
  WashdayNotification(
    customerId: 'customer-b',
    title: 'Your laundry is ready',
    detail: 'Order LDR-0041 · Ready for pickup',
    orderId: 'LDR-0041',
    time: 'Today · 10:02 AM',
    unread: true,
  ),
  WashdayNotification(
    customerId: 'customer-b',
    title: 'Order collected',
    detail: 'Order LDR-0038 · Receipt available',
    orderId: 'LDR-0038',
    time: '4 days ago',
  ),
];

List<WashdayNotification> notificationsFor(String? customerId) {
  return seedNotifications
      .where((notification) => notification.customerId == customerId)
      .toList();
}

String _dayLabel(DateTime today, int offset) {
  if (offset == 0) return 'Today';
  if (offset == -1) return 'Yesterday';
  return shortDate(today.add(Duration(days: offset)));
}

List<WashdayOrder> buildSeedOrders(DateTime today) {
  DateTime day(int offset) =>
      DateTime(today.year, today.month, today.day).add(Duration(days: offset));

  return <WashdayOrder>[
    // Customer A — every customer-facing state.
    WashdayOrder(
      id: 'LDR-0051',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'shirts-express',
      service: 'Express wash',
      unit: 'kg',
      unitRate: 4.00,
      estimate: '3 h',
      stage: OrderStage.pending,
      placedOn: day(0),
      datedOn: day(0),
      dropOff: 'Today',
      note: 'Two shirts and a blazer.',
    ),
    WashdayOrder(
      id: 'LDR-0050',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'dresses-dry-clean',
      service: 'Dry clean',
      unit: 'item',
      unitRate: 8.00,
      estimate: '48 h',
      stage: OrderStage.declined,
      placedOn: day(-1),
      datedOn: day(-1),
      dropOff: 'Yesterday',
      declineReason:
          'Fully booked for 48-hour dry cleaning this week. Please choose a later drop-off or a wash service.',
    ),
    WashdayOrder(
      id: 'LDR-0049',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'dresses-gentle-wash',
      service: 'Gentle wash',
      unit: 'kg',
      unitRate: 3.00,
      estimate: '24 h',
      stage: OrderStage.accepted,
      placedOn: day(0),
      datedOn: day(0),
      dropOff: 'Today',
      note: 'One dress, please use the gentle cycle.',
    ),
    WashdayOrder(
      id: 'LDR-0048',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'shirts-wash-fold',
      service: 'Wash & fold',
      unit: 'kg',
      unitRate: 2.00,
      estimate: '6 h',
      stage: OrderStage.received,
      placedOn: day(0),
      datedOn: day(0),
      dropOff: 'Today',
    ),
    WashdayOrder(
      id: 'LDR-0047',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'shirts-wash-fold',
      service: 'Wash & fold',
      unit: 'kg',
      unitRate: 2.00,
      estimate: '6 h',
      stage: OrderStage.processing,
      placedOn: day(-1),
      datedOn: day(-1),
      dropOff: 'Yesterday',
      measure: 4.2,
      subtotal: 8.40,
      discount: 0.84,
      total: 7.56,
      voucherCode: 'WELCOME10',
      isPaid: true,
      paymentMethod: 'Cash',
    ),
    WashdayOrder(
      id: 'LDR-0046',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'bedding-wash-fold',
      service: 'Bedding wash & fold',
      unit: 'kg',
      unitRate: 2.50,
      estimate: '6 h',
      stage: OrderStage.ready,
      placedOn: day(-1),
      datedOn: day(-1),
      dropOff: 'Yesterday',
      measure: 3.0,
      subtotal: 7.50,
      total: 7.50,
      isPaid: true,
      paymentMethod: 'Cash',
    ),
    WashdayOrder(
      id: 'LDR-0045',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'shirts-press-only',
      service: 'Press only',
      unit: 'item',
      unitRate: 3.50,
      estimate: '24 h',
      stage: OrderStage.cancelled,
      placedOn: day(-2),
      datedOn: day(-2),
      dropOff: 'Cancelled',
      note: 'Three work shirts.',
    ),
    WashdayOrder(
      id: 'LDR-0042',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'shirts-express',
      service: 'Express wash',
      unit: 'kg',
      unitRate: 4.00,
      estimate: '3 h',
      stage: OrderStage.ready,
      placedOn: day(0),
      datedOn: day(0),
      dropOff: 'Today',
      measure: 2.1,
      subtotal: 8.40,
      total: 8.40,
    ),
    WashdayOrder(
      id: 'LDR-0039',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'shirts-press-only',
      service: 'Press only',
      unit: 'item',
      unitRate: 3.50,
      estimate: '24 h',
      stage: OrderStage.pickedUp,
      placedOn: day(-4),
      datedOn: day(-3),
      dropOff: _dayLabel(today, -4),
      measure: 4,
      subtotal: 14.00,
      total: 14.00,
      isPaid: true,
      paymentMethod: 'Cash',
    ),
    WashdayOrder(
      id: 'LDR-0031',
      customerId: 'customer-a',
      customer: 'Customer A',
      serviceId: 'shirts-wash-fold',
      service: 'Wash & fold',
      unit: 'kg',
      unitRate: 2.00,
      estimate: '6 h',
      stage: OrderStage.pickedUp,
      placedOn: day(-18),
      datedOn: day(-17),
      dropOff: _dayLabel(today, -18),
      measure: 6.2,
      subtotal: 12.40,
      discount: 1.24,
      total: 11.16,
      voucherCode: 'WELCOME10',
      isPaid: true,
      paymentMethod: 'Cash',
    ),

    // Customer B — its own pending request, loyalty order and receipt.
    WashdayOrder(
      id: 'LDR-0052',
      customerId: 'customer-b',
      customer: 'Customer B',
      serviceId: 'bedding-duvet',
      service: 'Duvet clean',
      unit: 'item',
      unitRate: 9.00,
      estimate: '24 h',
      stage: OrderStage.pending,
      placedOn: day(0),
      datedOn: day(0),
      dropOff: 'Tomorrow',
      note: 'One double duvet.',
    ),
    WashdayOrder(
      id: 'LDR-0044',
      customerId: 'customer-b',
      customer: 'Customer B',
      serviceId: 'pants-wash-fold',
      service: 'Wash & fold',
      unit: 'kg',
      unitRate: 2.00,
      estimate: '6 h',
      stage: OrderStage.accepted,
      placedOn: day(-1),
      datedOn: day(-1),
      dropOff: 'Today',
    ),
    WashdayOrder(
      id: 'LDR-0043',
      customerId: 'customer-b',
      customer: 'Customer B',
      serviceId: 'pants-wash-fold',
      service: 'Wash & fold',
      unit: 'kg',
      unitRate: 2.00,
      estimate: '6 h',
      stage: OrderStage.processing,
      placedOn: day(-2),
      datedOn: day(-2),
      dropOff: _dayLabel(today, -2),
      measure: 4.0,
      subtotal: 8.00,
      discount: 2.50,
      total: 5.50,
      voucherCode: 'Loyalty reward',
      isPaid: true,
      paymentMethod: 'Transfer',
    ),
    WashdayOrder(
      id: 'LDR-0041',
      customerId: 'customer-b',
      customer: 'Customer B',
      serviceId: 'pants-wash-fold',
      service: 'Wash & fold',
      unit: 'kg',
      unitRate: 2.00,
      estimate: '6 h',
      stage: OrderStage.ready,
      placedOn: day(0),
      datedOn: day(0),
      dropOff: 'Today',
      measure: 5.6,
      subtotal: 11.20,
      total: 11.20,
    ),
    WashdayOrder(
      id: 'LDR-0038',
      customerId: 'customer-b',
      customer: 'Customer B',
      serviceId: 'dresses-dry-clean',
      service: 'Dry clean',
      unit: 'item',
      unitRate: 8.00,
      estimate: '48 h',
      stage: OrderStage.pickedUp,
      placedOn: day(-5),
      datedOn: day(-4),
      dropOff: _dayLabel(today, -5),
      measure: 2,
      subtotal: 16.00,
      total: 16.00,
      isPaid: true,
      paymentMethod: 'QR',
    ),

    // Walk-in order visible to Clerk and Owner only.
    WashdayOrder(
      id: 'LDR-0040',
      customerId: 'walk-in',
      customer: 'Walk-in',
      serviceId: 'bedding-wash-fold',
      service: 'Bedding wash & fold',
      unit: 'kg',
      unitRate: 2.50,
      estimate: '6 h',
      stage: OrderStage.ready,
      placedOn: day(-1),
      datedOn: day(-1),
      dropOff: 'Walk-in',
      measure: 3.0,
      subtotal: 7.50,
      total: 7.50,
      isPaid: true,
      paymentMethod: 'Cash',
    ),
  ];
}

List<ActivityEvent> buildSeedActivity(DateTime today) {
  return <ActivityEvent>[
    ActivityEvent(
      title: 'Order LDR-0042 marked ready',
      detail: 'Customer A · Express wash',
      time: '10:24 AM',
      tone: 'teal',
      actor: 'Clerk K',
      changeLabel: 'Status',
      before: 'Processing',
      after: 'Ready',
    ),
    ActivityEvent(
      title: 'Payment received for LDR-0043',
      detail: 'Customer B · Wash & fold',
      time: '9:58 AM',
      tone: 'teal',
      actor: 'Clerk K',
      changeLabel: 'Payment',
      before: 'Unpaid',
      after: 'Paid · Transfer',
    ),
    ActivityEvent(
      title: 'Order LDR-0050 declined',
      detail: 'Customer A · Dry clean',
      time: 'Yesterday · 4:18 PM',
      tone: 'amber',
      actor: 'Clerk K',
      changeLabel: 'Status',
      before: 'Pending',
      after: 'Declined',
    ),
    ActivityEvent(
      title: 'Order LDR-0049 accepted',
      detail: 'Customer A · Gentle wash',
      time: 'Yesterday · 4:02 PM',
      tone: 'teal',
      actor: 'Clerk K',
      changeLabel: 'Status',
      before: 'Pending',
      after: 'Accepted',
    ),
    ActivityEvent(
      title: 'Service price updated',
      detail: 'Press only · Shirts',
      time: '9:12 AM',
      tone: 'amber',
      kind: 'catalog',
      actor: 'Owner',
      changeLabel: 'Price',
      before: '3.00 / item',
      after: '3.50 / item',
    ),
    ActivityEvent(
      title: 'Voucher WELCOME10 minimum spend updated',
      detail: 'Applies to eligible wash & fold orders',
      time: '8:46 AM',
      tone: 'amber',
      kind: 'vouchers',
      actor: 'Owner',
      changeLabel: 'Minimum spend',
      before: '5.00',
      after: '3.00',
    ),
  ];
}
