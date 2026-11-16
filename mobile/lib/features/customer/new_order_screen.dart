import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../data/models.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class NewOrderScreen extends ConsumerWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(catalogProvider).categories;

    return WashdayPage(
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: 'Home',
            onTap: () => context.go('/customer/home'),
          ),
        ),
        const WashdayPageHeading(
          kicker: 'Step 1 of 2',
          title: 'New order',
          subtitle: 'Choose a category, then pick the service that suits you.',
        ),
        WashdaySectionHead(
          title: 'Choose a category',
          titleSize: 18,
          trailing: WashdayCountPill('${categories.length} categories'),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 148,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryTile(
              category: category,
              onTap: () => context.push('/customer/category/${category.id}'),
            );
          },
        ),
        const WashdayNotice(
          title: 'Prices by weight',
          body:
              'Choose a category to see the services and current rates. We confirm the final total when your bag is weighed.',
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final LaundryCategory category;
  final VoidCallback onTap;

  IconData get _icon => switch (category.id) {
    'shirts' => Icons.checkroom,
    'pants' => Icons.local_laundry_service,
    'dresses' => Icons.woman,
    _ => Icons.bed,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.name}, ${category.serviceCount} services',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9E5ED),
          borderRadius: BorderRadius.circular(WashdayRadii.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
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
                        Color(0x330C1A23),
                        Color(0xC70C1A23),
                      ],
                      stops: [0.3, 0.62, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xE6FFFFFF),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      _icon,
                      size: 17,
                      color: WashdayColors.inkSecondary,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 40,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WashdayType.style(
                          size: 17,
                          weight: 650,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${category.serviceCount} services',
                        style: WashdayType.style(
                          size: 10.5,
                          weight: 520,
                          color: const Color(0xCCFFFFFF),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xF2FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.north_east_rounded,
                      size: 15,
                      color: WashdayColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
