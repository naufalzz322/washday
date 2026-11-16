import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../data/models.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class OwnerCatalogScreen extends ConsumerWidget {
  const OwnerCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final visibleServices = catalog.categories
        .expand((category) => category.services)
        .where((service) => service.active)
        .length;
    final hiddenServices = catalog.serviceCount - visibleServices;

    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Catalog',
          title: 'Service catalog',
          subtitle: 'Manage categories and the services customers can choose.',
          dense: true,
        ),
        WashdayMetricStrip(
          metrics: [
            WashdayMetric(
              value: '${catalog.categories.length}',
              label: 'Categories',
            ),
            WashdayMetric(value: '$visibleServices', label: 'Visible'),
            WashdayMetric(value: '$hiddenServices', label: 'Hidden'),
          ],
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WashdaySectionHead(
                kicker: 'Customer menu',
                title: 'Categories',
                titleSize: 18,
                trailing: WashdayCountPill(
                  catalog.isCustom ? 'Updated' : 'Default',
                ),
              ),
              const SizedBox(height: 6),
              for (var index = 0; index < catalog.categories.length; index++)
                _CategoryRow(
                  category: catalog.categories[index],
                  showTopBorder: index > 0,
                  onTap: () => context.push(
                    '/owner/category/${catalog.categories[index].id}',
                  ),
                ),
            ],
          ),
        ),
        WashdayButton(
          label: 'Add category',
          icon: Icons.add_rounded,
          onPressed: () => context.push('/owner/add-category'),
        ),
        const WashdayNotice(
          title: 'What customers see',
          body:
              'Visible services appear on the customer category page. Hidden services stay in your catalog without being shown.',
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.showTopBorder,
    required this.onTap,
  });

  final LaundryCategory category;
  final bool showTopBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visible = category.services.where((service) => service.active).length;
    final total = category.services.length;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(WashdayRadii.tile),
                child: Image.asset(
                  category.imageAsset,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.style(
                        size: 14,
                        weight: 640,
                        color: WashdayColors.ink,
                        height: 1.25,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      total == 0
                          ? 'No services yet'
                          : visible == total
                          ? '$total services · all visible'
                          : '$visible of $total services visible',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.muted(size: 11, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (visible < total)
                const WashdayStatusPill('Hidden', tone: WashdayTone.neutral)
              else
                const WashdayStatusPill('Visible', tone: WashdayTone.teal),
              const SizedBox(width: 2),
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
