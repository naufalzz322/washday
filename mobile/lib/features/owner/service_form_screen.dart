import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../data/models.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  const ServiceFormScreen({
    super.key,
    required this.categoryId,
    this.serviceId,
  });

  final String categoryId;
  final String? serviceId;

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  String _unit = 'kg';
  bool _active = true;
  String? _error;
  ServiceOffering? _editing;

  bool get _isEditing => _editing != null;

  @override
  void initState() {
    super.initState();
    final service = ref.read(catalogProvider).findService(widget.serviceId);
    if (service == null) return;
    _editing = service;
    _nameController.text = service.name;
    _descriptionController.text = service.description;
    _priceController.text = service.priceLabel;
    _durationController.text = service.duration;
    _unit = service.unit;
    _active = service.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit(LaundryCategory category) {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final duration = _durationController.text.trim();
    final price = double.tryParse(
      _priceController.text.replaceAll(',', '.').trim(),
    );

    if (name.isEmpty) {
      setState(() => _error = 'Add a service name.');
      return;
    }
    if (description.isEmpty) {
      setState(() => _error = 'Add a short description or benefit.');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _error = 'Enter a price greater than zero.');
      return;
    }
    if (duration.isEmpty) {
      setState(() => _error = 'Add a turnaround time, such as 6 h.');
      return;
    }

    final notifier = ref.read(catalogProvider.notifier);
    if (_editing != null) {
      notifier.updateService(
        categoryId: category.id,
        service: _editing!.copyWith(
          name: name,
          description: description,
          price: price,
          unit: _unit,
          duration: duration,
          active: _active,
        ),
      );
    } else {
      notifier.addService(
        categoryId: category.id,
        name: name,
        description: description,
        price: price,
        unit: _unit,
        duration: duration,
        active: _active,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Service updated.' : '$name added to ${category.name}.',
        ),
      ),
    );
    context.go('/owner/category/${category.id}');
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(catalogProvider).findCategory(widget.categoryId);
    if (category == null) {
      return _MissingCategory(onBack: () => context.go('/owner/services'));
    }
    if (widget.serviceId != null && _editing == null) {
      return _MissingService(
        categoryName: category.name,
        onBack: () => context.go('/owner/category/${category.id}'),
      );
    }

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: category.name,
            onTap: () => context.go('/owner/category/${category.id}'),
          ),
        ),
        WashdayPageHeading(
          kicker: 'Catalog',
          title: _isEditing ? 'Edit service' : 'Add a service',
          subtitle: category.name,
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Service details' : 'New service',
                      style: WashdayType.title(size: 18),
                    ),
                  ),
                  WashdayCountPill(_isEditing ? 'Editing' : 'New'),
                ],
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Service name',
                controller: _nameController,
                hint: 'e.g. Wash & fold',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Description or benefit',
                controller: _descriptionController,
                hint: 'What does the customer get?',
                maxLines: 3,
                minLines: 2,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: WashdayField(
                      label: 'Price',
                      controller: _priceController,
                      hint: '2.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: WashdaySelectField<String>(
                      label: 'Unit',
                      value: _unit,
                      minHeight: 55,
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('Per kg')),
                        DropdownMenuItem(
                          value: 'item',
                          child: Text('Per item'),
                        ),
                        DropdownMenuItem(
                          value: 'load',
                          child: Text('Per load'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _unit = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Duration',
                controller: _durationController,
                hint: 'e.g. 6 h',
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 5, 8, 5),
                decoration: BoxDecoration(
                  color: WashdayColors.teal100,
                  borderRadius: BorderRadius.circular(WashdayRadii.control),
                  border: Border.all(color: WashdayColors.teal200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 19,
                      color: WashdayColors.teal700,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Available for new orders',
                        style: WashdayType.style(
                          size: 12.5,
                          weight: 590,
                          color: WashdayColors.inkSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _active,
                      onChanged: (value) => setState(() => _active = value),
                      activeThumbColor: WashdayColors.teal600,
                      activeTrackColor: WashdayColors.teal100,
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
                  decoration: BoxDecoration(
                    color: WashdayColors.red100,
                    borderRadius: BorderRadius.circular(WashdayRadii.control),
                    border: Border.all(
                      color: WashdayColors.red500.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 15,
                        color: WashdayColors.red500,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _error!,
                          style: WashdayType.style(
                            size: 12,
                            weight: 580,
                            color: WashdayColors.red500,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              WashdayButton(
                label: _isEditing ? 'Save changes' : 'Add service',
                onPressed: () => _submit(category),
              ),
            ],
          ),
        ),
        const WashdayNotice(
          title: 'Pricing',
          body:
              'Prices are shown to customers per kilogram, item or load. Final totals are confirmed at weighing.',
        ),
      ],
    );
  }
}

class _MissingCategory extends StatelessWidget {
  const _MissingCategory({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(label: 'Categories', onTap: onBack),
        ),
        WashdayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Category not found', style: WashdayType.title()),
              const SizedBox(height: 7),
              Text(
                'This category isn’t available. It may have been removed or renamed.',
                style: WashdayType.muted(size: 14),
              ),
              const SizedBox(height: 14),
              WashdayButton(
                label: 'Back to categories',
                tone: WashdayButtonTone.secondary,
                onPressed: onBack,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MissingService extends StatelessWidget {
  const _MissingService({required this.categoryName, required this.onBack});

  final String categoryName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(label: categoryName, onTap: onBack),
        ),
        WashdayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Service not found', style: WashdayType.title()),
              const SizedBox(height: 7),
              Text(
                'This service isn’t available. It may have been removed or renamed.',
                style: WashdayType.muted(size: 14),
              ),
              const SizedBox(height: 14),
              WashdayButton(
                label: 'Back to services',
                tone: WashdayButtonTone.secondary,
                onPressed: onBack,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
