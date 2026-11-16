import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fixtures.dart';
import 'models.dart';

/// The owner-editable catalog for the current session.
///
/// The default categories and services come from the bundled fixtures. Changes
/// live in memory until the backend and offline sync layer are connected.
class CatalogState {
  const CatalogState({required this.categories, this.changes = const []});

  final List<LaundryCategory> categories;
  final List<ActivityEvent> changes;

  int get serviceCount =>
      categories.fold(0, (total, category) => total + category.services.length);

  /// Whether the current catalog differs from the bundled default catalog.
  bool get isCustom {
    if (categories.length != washdayCategories.length) return true;
    for (var index = 0; index < categories.length; index++) {
      final current = categories[index];
      final original = washdayCategories[index];
      if (current.id != original.id ||
          current.name != original.name ||
          current.description != original.description ||
          current.services.length != original.services.length) {
        return true;
      }
      for (
        var serviceIndex = 0;
        serviceIndex < current.services.length;
        serviceIndex++
      ) {
        final a = current.services[serviceIndex];
        final b = original.services[serviceIndex];
        if (a.id != b.id ||
            a.name != b.name ||
            a.description != b.description ||
            a.price != b.price ||
            a.unit != b.unit ||
            a.duration != b.duration ||
            a.active != b.active) {
          return true;
        }
      }
    }
    return false;
  }

  LaundryCategory? findCategory(String? id) {
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  ServiceOffering? findService(String? id) {
    if (id == null) return null;
    for (final category in categories) {
      for (final service in category.services) {
        if (service.id == id) return service;
      }
    }
    return null;
  }
}

class CatalogController extends Notifier<CatalogState> {
  @override
  CatalogState build() {
    return CatalogState(categories: List.unmodifiable(washdayCategories));
  }

  void addCategory({
    required String name,
    required String description,
    required String imageAsset,
  }) {
    final id = _uniqueCategoryId(name);
    final category = LaundryCategory(
      id: id,
      name: name.trim(),
      description: description.trim(),
      imageAsset: imageAsset,
      services: const [],
    );
    state = CatalogState(
      categories: [...state.categories, category],
      changes: [
        ActivityEvent(
          title: 'Category added',
          detail: '${category.name} · no services yet',
          time: _timeStamp(),
          tone: 'amber',
          kind: 'catalog',
          actor: 'Owner',
          changeLabel: 'Category',
          before: 'Not listed',
          after: category.name,
        ),
        ...state.changes,
      ],
    );
  }

  void addService({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String unit,
    required String duration,
    required bool active,
  }) {
    final category = state.findCategory(categoryId);
    if (category == null) return;

    final baseId = _slug(name);
    var serviceId = '$categoryId-$baseId';
    var suffix = 2;
    while (state.findService(serviceId) != null) {
      serviceId = '$categoryId-$baseId-${suffix++}';
    }

    final service = ServiceOffering(
      id: serviceId,
      name: name.trim(),
      description: description.trim(),
      price: price,
      unit: unit,
      duration: duration.trim(),
      active: active,
    );
    _replaceCategory(
      category.copyWithServices([...category.services, service]),
    );
    _log(
      title: 'Service added to ${category.name}',
      detail: '${service.name} · ${service.priceLabel} / ${service.unit}',
      changeLabel: 'Service',
      before: 'Not listed',
      after: service.name,
    );
  }

  void updateService({
    required String categoryId,
    required ServiceOffering service,
  }) {
    final category = state.findCategory(categoryId);
    if (category == null) return;

    final existing = state.findService(service.id);
    if (existing == null) return;

    _replaceCategory(
      category.copyWithServices([
        for (final item in category.services)
          if (item.id == service.id) service else item,
      ]),
    );

    if (existing.price != service.price) {
      _log(
        title: 'Service “${service.name}” price updated',
        detail: '${category.name} · ${service.unitLabel}',
        changeLabel: 'Price',
        before: '${existing.priceLabel} / ${existing.unit}',
        after: '${service.priceLabel} / ${service.unit}',
      );
    } else if (existing.name != service.name) {
      _log(
        title: 'Service renamed',
        detail: category.name,
        changeLabel: 'Name',
        before: existing.name,
        after: service.name,
      );
    } else if (existing.active != service.active) {
      _log(
        title:
            'Service “${service.name}” ${service.active ? 'made visible' : 'hidden'}',
        detail: '${category.name} · customer menu',
        changeLabel: 'Availability',
        before: existing.active ? 'Visible' : 'Hidden',
        after: service.active ? 'Visible' : 'Hidden',
      );
    } else {
      _log(
        title: 'Service “${service.name}” updated',
        detail: category.name,
        changeLabel: 'Details',
        before: existing.duration,
        after: service.duration,
      );
    }
  }

  void reset() {
    state = const CatalogState(categories: washdayCategories);
  }

  void clearActivity() {
    if (state.changes.isEmpty) return;
    state = CatalogState(categories: state.categories);
  }

  void _replaceCategory(LaundryCategory updated) {
    state = CatalogState(
      categories: [
        for (final category in state.categories)
          if (category.id == updated.id) updated else category,
      ],
      changes: state.changes,
    );
  }

  void _log({
    required String title,
    required String detail,
    required String changeLabel,
    required String before,
    required String after,
  }) {
    state = CatalogState(
      categories: state.categories,
      changes: [
        ActivityEvent(
          title: title,
          detail: detail,
          time: _timeStamp(),
          tone: 'amber',
          kind: 'catalog',
          actor: 'Owner',
          changeLabel: changeLabel,
          before: before,
          after: after,
        ),
        ...state.changes,
      ],
    );
  }

  String _uniqueCategoryId(String name) {
    final base = _slug(name);
    var id = base;
    var suffix = 2;
    while (state.findCategory(id) != null) {
      id = '$base-${suffix++}';
    }
    return id;
  }

  String _slug(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'category' : slug;
  }

  String _timeStamp() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour < 12 ? 'AM' : 'PM';
    return 'Today · $hour:$minute $suffix';
  }
}

final catalogProvider = NotifierProvider<CatalogController, CatalogState>(
  CatalogController.new,
);

extension on LaundryCategory {
  LaundryCategory copyWithServices(List<ServiceOffering> services) {
    return LaundryCategory(
      id: id,
      name: name,
      description: description,
      imageAsset: imageAsset,
      services: services,
    );
  }
}
