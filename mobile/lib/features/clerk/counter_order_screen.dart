import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class CounterOrderScreen extends ConsumerStatefulWidget {
  const CounterOrderScreen({super.key});

  @override
  ConsumerState<CounterOrderScreen> createState() => _CounterOrderScreenState();
}

class _CounterOrderScreenState extends ConsumerState<CounterOrderScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _customer = 'Customer A';
  String _categoryId = 'shirts';
  String _serviceId = 'shirts-wash-fold';
  bool _created = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _selectCustomer(String customer) {
    setState(() {
      _customer = customer;
      _created = false;
    });
  }

  void _createOrder() {
    setState(() => _created = true);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final categories = catalog.categories
        .where((category) => category.services.any((service) => service.active))
        .toList();
    final selectedCategory =
        catalog.findCategory(_categoryId) ?? categories.first;
    final services = selectedCategory.services
        .where((service) => service.active)
        .toList();
    final service = services.firstWhere(
      (item) => item.id == _serviceId,
      orElse: () => services.first,
    );
    final customerLabel =
        _customer == 'Walk-in' && _nameController.text.isNotEmpty
        ? 'Walk-in · ${_nameController.text.trim()}'
        : _customer;

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        const WashdayPageHeading(
          kicker: 'Counter',
          title: 'Counter order',
          subtitle: 'Start an order for a customer at the counter.',
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Customer', style: WashdayType.title(size: 17)),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: _CustomerTile(
                      title: 'Customer A',
                      subtitle: 'Returning',
                      selected: _customer == 'Customer A',
                      onTap: () => _selectCustomer('Customer A'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CustomerTile(
                      title: 'Walk-in',
                      subtitle: 'New customer',
                      selected: _customer == 'Walk-in',
                      onTap: () => _selectCustomer('Walk-in'),
                    ),
                  ),
                ],
              ),
              if (_customer == 'Walk-in') ...[
                const SizedBox(height: 12),
                WashdayField(
                  label: 'Walk-in name',
                  controller: _nameController,
                  hint: 'Enter name',
                  enabled: true,
                  onChanged: (_) => setState(() => _created = false),
                ),
                const SizedBox(height: 10),
                WashdayField(
                  label: 'Phone (optional)',
                  controller: _phoneController,
                  hint: 'Optional',
                  keyboardType: TextInputType.phone,
                  enabled: true,
                ),
              ],
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Order details', style: WashdayType.title(size: 17)),
              const SizedBox(height: 11),
              const _SelectLabel('Category'),
              _SelectField<String>(
                value: selectedCategory.id,
                items: [
                  for (final category in categories)
                    DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  final nextCategory = catalog.findCategory(value);
                  if (nextCategory == null) return;
                  final nextServices = nextCategory.services
                      .where((item) => item.active)
                      .toList();
                  if (nextServices.isEmpty) return;
                  setState(() {
                    _categoryId = value;
                    _serviceId = nextServices.first.id;
                    _created = false;
                  });
                },
              ),
              const SizedBox(height: 10),
              const _SelectLabel('Service'),
              _SelectField<String>(
                value: service.id,
                items: [
                  for (final option in services)
                    DropdownMenuItem(
                      value: option.id,
                      child: Text(
                        '${option.name} · ${option.priceLabel} / ${option.unit}',
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _serviceId = value;
                    _created = false;
                  });
                },
              ),
              const SizedBox(height: 13),
              WashdayButton(
                label: 'Create order',
                height: 50,
                onPressed: _createOrder,
              ),
              if (_created) ...[
                const SizedBox(height: 10),
                _OrderStarted(
                  customer: customerLabel,
                  service: service.name,
                  onContinue: () => context.push('/clerk/weigh'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $subtitle',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(11, 9, 9, 9),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.strong(size: 12.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.muted(size: 10.5, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
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

class _OrderStarted extends StatelessWidget {
  const _OrderStarted({
    required this.customer,
    required this.service,
    required this.onContinue,
  });

  final String customer;
  final String service;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 9),
      decoration: BoxDecoration(
        color: WashdayColors.teal100,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        border: Border.all(color: WashdayColors.teal200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: WashdayColors.teal700,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Order started for $customer · $service.',
                  style: WashdayType.style(
                    size: 12,
                    weight: 620,
                    color: WashdayColors.teal900,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          WashdayTextLink('Continue to weighing', onTap: onContinue),
        ],
      ),
    );
  }
}

class _SelectLabel extends StatelessWidget {
  const _SelectLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: WashdayType.style(
          size: 12,
          weight: 630,
          color: WashdayColors.inkSecondary,
          letterSpacing: 0.05,
        ),
      ),
    );
  }
}

class _SelectField<T> extends StatelessWidget {
  const _SelectField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: WashdayColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        border: Border.all(color: WashdayColors.hairlineStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: WashdayColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(WashdayRadii.control),
          dropdownColor: WashdayColors.white,
          style: WashdayType.body(size: 14.5),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
