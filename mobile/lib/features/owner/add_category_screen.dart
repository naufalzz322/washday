import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/catalog_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  static const _covers = <(String, String)>[
    ('assets/images/hero-shirt.jpg', 'Shirts'),
    ('assets/images/category-pants.jpg', 'Pants'),
    ('assets/images/category-dresses.jpg', 'Dresses'),
    ('assets/images/category-bedding.jpg', 'Bedding'),
  ];

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _cover = _covers.first.$1;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Add a category name.');
      return;
    }
    if (description.isEmpty) {
      setState(() => _error = 'Add a short description for this category.');
      return;
    }

    ref
        .read(catalogProvider.notifier)
        .addCategory(name: name, description: description, imageAsset: _cover);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name added to the catalog.')));
    context.go('/owner/services');
  }

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: 'Categories',
            onTap: () => context.go('/owner/services'),
          ),
        ),
        const WashdayPageHeading(
          kicker: 'Catalog',
          title: 'Add category',
          subtitle: 'Add a category to your customer catalog.',
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New category', style: WashdayType.title(size: 18)),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Category name',
                controller: _nameController,
                hint: 'e.g. Uniforms',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Description',
                controller: _descriptionController,
                hint: 'What belongs in this category?',
                maxLines: 3,
                minLines: 2,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 12),
              Text(
                'Cover photo',
                style: WashdayType.style(
                  size: 12,
                  weight: 640,
                  color: WashdayColors.inkSecondary,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  for (var index = 0; index < _covers.length; index++) ...[
                    if (index > 0) const SizedBox(width: 7),
                    Expanded(
                      child: _CoverChoice(
                        asset: _covers[index].$1,
                        label: _covers[index].$2,
                        selected: _cover == _covers[index].$1,
                        onTap: () => setState(() {
                          _cover = _covers[index].$1;
                          _error = null;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Choose a photo for this category.',
                style: WashdayType.muted(size: 11, height: 1.5),
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
              WashdayButton(label: 'Add category', onPressed: _submit),
            ],
          ),
        ),
        const WashdayNotice(
          title: 'Before you add',
          body:
              'New categories start empty. Add at least one visible service before customers can order from it.',
        ),
      ],
    );
  }
}

class _CoverChoice extends StatelessWidget {
  const _CoverChoice({
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label cover photo',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(WashdayRadii.tile),
                border: Border.all(
                  color: selected
                      ? WashdayColors.teal600
                      : WashdayColors.hairline,
                  width: selected ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(asset, fit: BoxFit.cover),
                  if (selected) const ColoredBox(color: Color(0x140B1821)),
                  if (selected)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: WashdayColors.teal600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WashdayType.style(
                size: 9.5,
                weight: selected ? 650 : 540,
                color: selected
                    ? WashdayColors.teal700
                    : WashdayColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
