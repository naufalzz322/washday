import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../data/seed.dart';
import '../../data/session_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _noteController = TextEditingController();
  String _dropOff = 'Today';
  bool _useVoucher = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _placeOrder(ServiceOffering service) {
    final account = ref.read(currentAccountProvider);
    final order = ref
        .read(ordersProvider.notifier)
        .placeOrder(
          account: account,
          service: service,
          dropOff: _dropOff,
          note: _noteController.text,
          useWelcomeVoucher: _useVoucher,
        );
    context.go('/customer/order-placed/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final service = catalog.findService(widget.serviceId);
    final account = ref.watch(currentAccountProvider);
    final voucher = voucherFor(account.customerId);

    if (service == null) {
      return WashdayPage(
        bottomClearance: 112,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: WashdayBackLink(
              label: 'All categories',
              onTap: () => context.go('/customer/new-order'),
            ),
          ),
          WashdayCard(
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Service not available', style: WashdayType.title()),
                const SizedBox(height: 7),
                Text(
                  'This service isn’t available. It may have been removed or hidden.',
                  style: WashdayType.muted(size: 14),
                ),
                const SizedBox(height: 14),
                WashdayButton(
                  label: 'Choose another service',
                  tone: WashdayButtonTone.secondary,
                  onPressed: () => context.go('/customer/new-order'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final category = _categoryFor(catalog.categories, service);
    final canUseVoucher =
        voucher != null && voucher.status == VoucherStatus.active;

    return WashdayPage(
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: category?.name ?? 'Services',
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/customer/new-order');
              }
            },
          ),
        ),
        const WashdayPageHeading(
          kicker: 'Step 2 of 2',
          title: 'Review order',
          subtitle: 'Check the service and tell the shop when you’ll drop off.',
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: WashdayColors.teal100,
                      borderRadius: BorderRadius.circular(WashdayRadii.tile),
                    ),
                    child: const Icon(
                      Icons.local_laundry_service_outlined,
                      size: 22,
                      color: WashdayColors.teal700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: WashdayType.title(size: 20)),
                        const SizedBox(height: 3),
                        Text(
                          category == null
                              ? service.description
                              : '${category.name} · ${service.description}',
                          style: WashdayType.muted(size: 12, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: WashdayColors.hairline),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _DetailChip(
                        label: 'Rate',
                        value: '${service.priceLabel} / ${service.unit}',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: WashdayColors.hairline,
                    ),
                    Expanded(
                      child: _DetailChip(
                        label: 'Turnaround',
                        value: service.duration,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WashdayKicker('Drop-off'),
              const SizedBox(height: 5),
              Text(
                'When will you bring it in?',
                style: WashdayType.title(size: 17),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in const ['Today', 'Tomorrow'])
                    WashdayFilterChip(
                      label: option,
                      selected: _dropOff == option,
                      onTap: () => setState(() => _dropOff = option),
                    ),
                ],
              ),
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WashdayKicker('Details'),
              const SizedBox(height: 5),
              Text(
                'Anything the shop should know?',
                style: WashdayType.title(size: 17),
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Note (optional)',
                controller: _noteController,
                hint:
                    'Separate colours, delicate items, a preferred pickup day…',
                maxLines: 3,
                minLines: 3,
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
        ),
        if (canUseVoucher)
          WashdayCard(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: WashdayKicker(
                        'Voucher',
                        color: WashdayColors.amber700,
                      ),
                    ),
                    WashdayStatusPill(
                      _useVoucher ? 'Selected' : 'Not applied',
                      tone: _useVoucher
                          ? WashdayTone.warning
                          : WashdayTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('WELCOME10 · 10% off', style: WashdayType.title(size: 17)),
                const SizedBox(height: 4),
                Text(
                  'Minimum spend 3.00 · discount capped at 5.00. Applied when the shop weighs your bag.',
                  style: WashdayType.muted(size: 12, height: 1.45),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    WashdayFilterChip(
                      label: 'Apply WELCOME10',
                      selected: _useVoucher,
                      onTap: () => setState(() => _useVoucher = true),
                    ),
                    WashdayFilterChip(
                      label: 'No voucher',
                      selected: !_useVoucher,
                      onTap: () => setState(() => _useVoucher = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const WashdayNotice(
          title: 'Final total',
          body:
              'The shop confirms the final total at weighing. Nothing is charged when you place this request.',
        ),
        WashdayButton(
          key: const Key('place-order'),
          label: 'Place order',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => _placeOrder(service),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WashdayType.style(
            size: 10,
            weight: 640,
            color: WashdayColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: WashdayType.style(
            size: 13.5,
            weight: 650,
            color: WashdayColors.ink,
            height: 1.25,
            tabularFigures: true,
          ),
        ),
      ],
    );
  }
}

LaundryCategory? _categoryFor(
  List<LaundryCategory> categories,
  ServiceOffering service,
) {
  for (final category in categories) {
    if (category.services.any((item) => item.id == service.id)) {
      return category;
    }
  }
  return null;
}
