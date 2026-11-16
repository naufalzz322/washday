import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../data/models.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class OwnerCategoryServicesScreen extends ConsumerWidget {
  const OwnerCategoryServicesScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(catalogProvider).findCategory(categoryId);
    if (category == null) {
      return _MissingCategory(onBack: () => context.go('/owner/services'));
    }

    final visibleCount = category.services.where((s) => s.active).length;
    final hiddenCount = category.services.length - visibleCount;

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: 'Categories',
            onTap: () => context.go('/owner/services'),
          ),
        ),
        _CategorySummary(category: category, visibleCount: visibleCount),
        WashdayMetricStrip(
          metrics: [
            WashdayMetric(
              value: '${category.services.length}',
              label: 'Listed',
            ),
            WashdayMetric(value: '$visibleCount', label: 'Visible'),
            WashdayMetric(value: '$hiddenCount', label: 'Hidden'),
          ],
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WashdaySectionHead(
                kicker: 'Services',
                title: 'In this category',
                titleSize: 18,
                trailing: WashdayCountPill(
                  '${category.services.length} listed',
                ),
              ),
              const SizedBox(height: 4),
              if (category.services.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    'No services in this category yet. Add the first one to get started.',
                    style: WashdayType.muted(size: 13, height: 1.5),
                  ),
                ),
              for (var index = 0; index < category.services.length; index++)
                _ServiceRow(
                  service: category.services[index],
                  showTopBorder: index > 0,
                  onTap: () => context.push(
                    '/owner/category/$categoryId/edit-service/'
                    '${category.services[index].id}',
                  ),
                ),
            ],
          ),
        ),
        WashdayButton(
          label: 'Add service',
          icon: Icons.add_rounded,
          onPressed: () =>
              context.push('/owner/category/$categoryId/add-service'),
        ),
        const WashdayNotice(
          title: 'Customer menu',
          body:
              'Visible services appear on the customer category page. Hidden services stay in your catalog but are not shown.',
        ),
      ],
    );
  }
}

class _CategorySummary extends StatelessWidget {
  const _CategorySummary({required this.category, required this.visibleCount});

  final LaundryCategory category;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      shadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(WashdayRadii.tile),
            child: Image.asset(
              category.imageAsset,
              width: 62,
              height: 62,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WashdayKicker('Category'),
                const SizedBox(height: 5),
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WashdayType.title(size: 24),
                ),
                const SizedBox(height: 3),
                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: WashdayType.muted(size: 11.5, height: 1.45),
                ),
                const SizedBox(height: 7),
                Text(
                  visibleCount == 1
                      ? '1 service visible to customers'
                      : '$visibleCount services visible to customers',
                  style: WashdayType.style(
                    size: 11,
                    weight: 600,
                    color: WashdayColors.teal700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.showTopBorder,
    required this.onTap,
  });

  final ServiceOffering service;
  final bool showTopBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            border: showTopBorder
                ? const Border(top: BorderSide(color: WashdayColors.hairline))
                : null,
          ),
          child: Row(
            children: [
              const WashdayLeadingTile(
                size: 38,
                child: Icon(Icons.local_laundry_service_outlined, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.style(
                        size: 13.5,
                        weight: 640,
                        color: WashdayColors.ink,
                        height: 1.25,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${service.priceLabel} / ${service.unit} · '
                      '${service.duration} turnaround',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.muted(size: 11, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              WashdayStatusPill(
                service.active ? 'Visible' : 'Hidden',
                tone: service.active ? WashdayTone.teal : WashdayTone.neutral,
              ),
              const SizedBox(width: 1),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: WashdayColors.slate400,
              ),
            ],
          ),
        ),
      ),
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
          shadow: false,
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
