import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/roles.dart';
import '../../app/theme.dart';
import '../../data/seed.dart';
import '../../data/session_controller.dart';
import '../../shared/account_menu.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class WashdaySettingsScreen extends ConsumerStatefulWidget {
  const WashdaySettingsScreen({super.key, required this.role});

  final WashdayRole role;

  @override
  ConsumerState<WashdaySettingsScreen> createState() =>
      _WashdaySettingsScreenState();
}

class _WashdaySettingsScreenState extends ConsumerState<WashdaySettingsScreen> {
  late final List<_Preference> _preferences = _preferencesFor(widget.role);

  static List<_Preference> _preferencesFor(WashdayRole role) {
    return switch (role) {
      WashdayRole.customer => [
        _Preference('Order updates', 'Status changes and pickup-ready alerts.'),
        _Preference(
          'Pickup reminders',
          'A reminder before the pickup window closes.',
        ),
        _Preference(
          'Offers and rewards',
          'Loyalty milestones and shop offers.',
          value: false,
        ),
      ],
      WashdayRole.clerk => [
        _Preference(
          'Queue alerts',
          'New orders waiting to be weighed or handed over.',
        ),
        _Preference(
          'Counter handoff',
          'A sound when a customer is checked in.',
        ),
      ],
      WashdayRole.owner => [
        _Preference('Daily summary', 'Orders and queue at closing.'),
        _Preference('New order alerts', 'A sound when an order is created.'),
        _Preference('Catalog changes', 'A digest when staff update services.'),
      ],
    };
  }

  String get _homeRoute => switch (widget.role) {
    WashdayRole.customer => '/customer/home',
    WashdayRole.clerk => '/clerk/home',
    WashdayRole.owner => '/owner/home',
  };

  String get _subtitle => switch (widget.role) {
    WashdayRole.customer => 'Your account, preferences and support.',
    WashdayRole.clerk => 'Your preferences and support.',
    WashdayRole.owner => 'Your account, preferences and shop settings.',
  };

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_homeRoute);
    }
  }

  Future<void> _logOut() async {
    final confirmed = await confirmWashdayLogout(context, role: widget.role);
    if (!confirmed || !mounted) return;
    ref.read(sessionProvider.notifier).signOut();
    context.go('/sign-in');
  }

  Future<void> _showHelp() {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) => const _HelpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(currentAccountProvider);
    final loyalty = loyaltyFor(account.customerId);
    return WashdayPage(
      gap: 14,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        WashdayBackLink(label: 'Back', onTap: _back),
        WashdayPageHeading(
          kicker: 'Account',
          title: 'Settings',
          subtitle: _subtitle,
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          shadow: false,
          child: Row(
            children: [
              WashdayAccountAvatar(
                role: widget.role,
                size: 46,
                hasPhoto: account.hasPhoto,
                initial: account.initial,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: WashdayType.title(size: 18)),
                    const SizedBox(height: 3),
                    Text(
                      account.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.muted(size: 11.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.role == WashdayRole.customer)
          _SettingsSection(
            label: 'Account',
            child: WashdayCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WashdayListRow(
                    title: 'Profile',
                    subtitle: 'Name, phone and email',
                    leading: const WashdayLeadingTile(
                      child: Icon(Icons.person_outline_rounded),
                    ),
                    showTopBorder: false,
                    onTap: () => context.push('/customer/profile'),
                  ),
                  WashdayListRow(
                    title: 'Notifications',
                    subtitle: 'Order and pickup updates',
                    leading: const WashdayLeadingTile(
                      child: Icon(Icons.notifications_none_rounded),
                    ),
                    onTap: () => context.push('/customer/notifications'),
                  ),
                  WashdayListRow(
                    title: 'Loyalty card',
                    subtitle: 'Stamps and reward progress',
                    leading: const WashdayLeadingTile(
                      child: Icon(Icons.loyalty_outlined),
                    ),
                    trailing: WashdayCountPill('${loyalty.stamps} / 10'),
                    onTap: () => context.push('/customer/loyalty'),
                  ),
                ],
              ),
            ),
          ),
        if (widget.role == WashdayRole.owner)
          _SettingsSection(
            label: 'Shop',
            child: WashdayCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shadow: false,
              child: WashdayListRow(
                title: 'Shop settings',
                subtitle: 'Loyalty and order timing',
                leading: const WashdayLeadingTile(
                  child: Icon(Icons.tune_rounded),
                ),
                showTopBorder: false,
                onTap: () => context.go('/owner/settings'),
              ),
            ),
          ),
        _SettingsSection(
          label: 'Preferences',
          child: WashdayCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < _preferences.length; index++)
                  _PreferenceRow(
                    preference: _preferences[index],
                    showTopBorder: index > 0,
                    onChanged: (value) =>
                        setState(() => _preferences[index].value = value),
                  ),
              ],
            ),
          ),
        ),
        _SettingsSection(
          label: 'Support',
          child: WashdayCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shadow: false,
            child: WashdayListRow(
              title: 'Help & support',
              subtitle: 'Answers to common shop questions',
              leading: const WashdayLeadingTile(
                child: Icon(Icons.help_outline_rounded),
              ),
              showTopBorder: false,
              onTap: _showHelp,
            ),
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shadow: false,
          child: WashdayListRow(
            title: 'Log out',
            subtitle: 'You’ll need to sign in again.',
            titleColor: WashdayColors.red500,
            leading: const WashdayLeadingTile(
              background: WashdayColors.red100,
              foreground: WashdayColors.red500,
              child: Icon(Icons.logout_rounded),
            ),
            showChevron: false,
            showTopBorder: false,
            onTap: _logOut,
          ),
        ),
      ],
    );
  }
}

class _Preference {
  _Preference(this.title, this.detail, {this.value = true});

  final String title;
  final String detail;
  bool value;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: WashdayKicker(label),
        ),
        child,
      ],
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.preference,
    required this.showTopBorder,
    required this.onChanged,
  });

  final _Preference preference;
  final bool showTopBorder;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: showTopBorder
              ? const Border(top: BorderSide(color: WashdayColors.hairline))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preference.title,
                    style: WashdayType.style(
                      size: 13.5,
                      weight: 640,
                      color: WashdayColors.ink,
                      height: 1.3,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preference.detail,
                    style: WashdayType.muted(size: 11.5, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch.adaptive(
              value: preference.value,
              onChanged: onChanged,
              activeThumbColor: WashdayColors.white,
              activeTrackColor: WashdayColors.teal600,
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  static const _faqs = [
    (
      'Change or cancel an order',
      'Call the shop before the wash starts. Counter staff can update pickup or add items.',
    ),
    (
      'Pickup and storage',
      'Ready orders are held for 30 days. Bring your order number when you collect.',
    ),
    (
      'Loyalty rewards',
      'Every 10 completed orders earns 50% off up to 5 kg. Stamps are added at pickup.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      // Hug the content so the modal barrier above the sheet stays tappable.
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: WashdayColors.white,
              borderRadius: BorderRadius.circular(WashdayRadii.panel),
              border: Border.all(color: WashdayColors.hairline),
              boxShadow: const [
                BoxShadow(
                  color: WashdayColors.shadow,
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: WashdayColors.dottedBorder,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const WashdayKicker('Support'),
                  const SizedBox(height: 6),
                  Text('Help & support', style: WashdayType.title(size: 22)),
                  const SizedBox(height: 6),
                  Text(
                    'Quick answers for common shop questions.',
                    style: WashdayType.muted(size: 12.5, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  for (var index = 0; index < _faqs.length; index++)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        border: index == 0
                            ? null
                            : const Border(
                                top: BorderSide(color: WashdayColors.hairline),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _faqs[index].$1,
                            style: WashdayType.style(
                              size: 13,
                              weight: 640,
                              color: WashdayColors.ink,
                              height: 1.35,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _faqs[index].$2,
                            style: WashdayType.muted(size: 11.5, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    'Still need a hand? Ask at the counter during opening hours.',
                    style: WashdayType.muted(size: 11.5, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  WashdayButton(
                    label: 'Close',
                    tone: WashdayButtonTone.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
