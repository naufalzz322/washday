import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../data/models.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class CategoryServicesScreen extends ConsumerStatefulWidget {
  const CategoryServicesScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<CategoryServicesScreen> createState() =>
      _CategoryServicesScreenState();
}

class _CategoryServicesScreenState
    extends ConsumerState<CategoryServicesScreen> {
  String? _selectedServiceId;

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(catalogProvider).findCategory(widget.categoryId);
    if (category == null) {
      return _MissingCategory(onBack: () => context.go('/customer/new-order'));
    }

    final services = category.services
        .where((service) => service.active)
        .toList();
    final selected = services.where(
      (service) => service.id == _selectedServiceId,
    );
    final width = MediaQuery.sizeOf(context).width;
    final heroTitle = (width * 0.084).clamp(31.0, 38.0);

    return WashdayPage(
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: 'All categories',
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/customer/new-order');
              }
            },
          ),
        ),
        _CatalogHero(category: category, titleSize: heroTitle),
        WashdaySectionHead(
          kicker: 'Services',
          title: 'Choose a service',
          titleSize: 18,
          trailing: WashdayCountPill(
            services.length == 1
                ? '1 available'
                : '${services.length} available',
          ),
        ),
        if (services.isEmpty)
          WashdayCard(
            shadow: false,
            child: Text(
              'No services are available in this category yet. Check back soon.',
              style: WashdayType.muted(size: 13, height: 1.5),
            ),
          ),
        for (var index = 0; index < services.length; index++)
          _ServiceChoice(
            service: services[index],
            selected: _selectedServiceId == services[index].id,
            onTap: () => setState(() {
              final id = services[index].id;
              _selectedServiceId = _selectedServiceId == id ? null : id;
            }),
          ),
        if (selected.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
            decoration: BoxDecoration(
              color: WashdayColors.teal100,
              borderRadius: BorderRadius.circular(WashdayRadii.control),
              border: Border.all(color: WashdayColors.teal200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: WashdayColors.teal700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${selected.first.name} selected · ${selected.first.priceLabel} / ${selected.first.unit}. We’ll confirm the final total at weighing.',
                    style: WashdayType.style(
                      size: 12,
                      weight: 560,
                      color: WashdayColors.teal900,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          WashdayButton(
            key: const Key('continue-to-checkout'),
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: () =>
                context.push('/customer/checkout/${selected.first.id}'),
          ),
        ],
        const WashdayNotice(
          title: 'Pricing',
          body:
              'The final total is confirmed at weighing. Offers are applied at checkout.',
        ),
      ],
    );
  }
}

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({required this.category, required this.titleSize});

  final LaundryCategory category;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WashdayRadii.panel),
        border: Border.all(color: WashdayColors.hairlineStrong),
        color: WashdayColors.deepStart,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(category.imageAsset, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x0A0C1A23),
                  Color(0x4D0C1A23),
                  Color(0xD10C1A23),
                ],
                stops: [0.22, 0.56, 1],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 17,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const WashdayKicker('Category', color: Color(0xC7FFFFFF)),
                const SizedBox(height: 7),
                Text(
                  category.name,
                  style: WashdayType.style(
                    size: titleSize,
                    weight: 680,
                    color: Colors.white,
                    height: 1.01,
                    letterSpacing: titleSize * -0.055,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: WashdayType.style(
                    size: 12.5,
                    weight: 480,
                    color: const Color(0xDBFFFFFF),
                    height: 1.5,
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

class _ServiceChoice extends StatelessWidget {
  const _ServiceChoice({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final ServiceOffering service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${service.name}, ${service.priceLabel} per ${service.unit}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: selected ? WashdayColors.teal100 : WashdayColors.white,
            borderRadius: BorderRadius.circular(WashdayRadii.card),
            border: Border.all(
              color: selected
                  ? WashdayColors.teal600
                  : WashdayColors.cardBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? WashdayColors.white : WashdayColors.teal100,
                  borderRadius: BorderRadius.circular(WashdayRadii.tile),
                ),
                child: const Icon(
                  Icons.local_laundry_service_outlined,
                  size: 21,
                  color: WashdayColors.teal700,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WashdayType.strong(size: 14.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: selected
                                ? WashdayColors.teal700
                                : WashdayColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? WashdayColors.teal700
                                  : WashdayColors.hairlineStrong,
                              width: 1.4,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.muted(size: 11.5, height: 1.4),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: WashdayColors.teal700,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${service.duration} turnaround',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WashdayType.style(
                              size: 10.5,
                              weight: 580,
                              color: WashdayColors.teal700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: service.priceLabel,
                                style: WashdayType.style(
                                  size: 12.5,
                                  weight: 680,
                                  color: WashdayColors.ink,
                                  tabularFigures: true,
                                ),
                              ),
                              TextSpan(
                                text: ' / ${service.unit}',
                                style: WashdayType.muted(
                                  size: 9.5,
                                  height: 1.2,
                                ),
                              ),
                            ],
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
          child: WashdayBackLink(label: 'All categories', onTap: onBack),
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
                label: 'Choose another category',
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
