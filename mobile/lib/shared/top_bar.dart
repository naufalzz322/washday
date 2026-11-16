import 'package:flutter/material.dart';

import '../app/roles.dart';
import '../app/theme.dart';
import 'brand.dart';

class WashdayTopBar extends StatelessWidget {
  const WashdayTopBar({
    super.key,
    required this.role,
    required this.onBrandTap,
    required this.onProfileTap,
    this.onNotificationsTap,
    this.hasUnreadNotifications = false,
    this.accountName,
    this.hasPhoto = false,
    this.accountInitial,
  });

  final WashdayRole role;
  final VoidCallback onBrandTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationsTap;
  final bool hasUnreadNotifications;
  final String? accountName;
  final bool hasPhoto;
  final String? accountInitial;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: WashdayColors.canvas,
        border: Border(bottom: BorderSide(color: WashdayColors.hairline)),
      ),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        minimum: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // The customer bar carries an extra notification button,
                  // so the wordmark gives way on narrower phones to keep
                  // the brand, account and bell from crowding each other.
                  // Clerk and Owner have no bell and keep the wordmark.
                  final compactBrand =
                      role == WashdayRole.customer &&
                      constraints.maxWidth < 350;
                  return SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: WashdayBrandLockup(
                            onTap: onBrandTap,
                            showWordmark: !compactBrand,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ProfileSwitch(
                              role: role,
                              onTap: onProfileTap,
                              name: accountName,
                              hasPhoto: hasPhoto,
                              initial: accountInitial,
                            ),
                            if (role == WashdayRole.customer) ...[
                              const SizedBox(width: 8),
                              _BellButton(
                                onTap: onNotificationsTap,
                                hasUnread: hasUnreadNotifications,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The reduced app bar used before an account is chosen.
class WashdayGuestTopBar extends StatelessWidget {
  const WashdayGuestTopBar({
    super.key,
    required this.onBrandTap,
    this.semanticLabel = 'Washday welcome',
  });

  final VoidCallback onBrandTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: WashdayColors.canvas,
        border: Border(bottom: BorderSide(color: WashdayColors.hairline)),
      ),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        minimum: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SizedBox(
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: WashdayBrandLockup(
                    onTap: onBrandTap,
                    semanticLabel: semanticLabel,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSwitch extends StatelessWidget {
  const _ProfileSwitch({
    required this.role,
    required this.onTap,
    this.name,
    this.hasPhoto = false,
    this.initial,
  });

  final WashdayRole role;
  final VoidCallback onTap;
  final String? name;
  final bool hasPhoto;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final displayName =
        name ?? (role == WashdayRole.customer ? 'Customer A' : role.label);
    return Semantics(
      button: true,
      label: 'Account menu for $displayName',
      child: Material(
        color: WashdayColors.white,
        shape: StadiumBorder(
          side: BorderSide(color: WashdayColors.hairlineStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 9, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (role == WashdayRole.customer && hasPhoto)
                  ClipOval(
                    child: Image.asset(
                      'assets/images/customer-alex.jpg',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.28),
                    ),
                  )
                else
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: WashdayColors.teal100,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial ?? role.initial,
                      style: WashdayType.style(
                        size: 12,
                        weight: 700,
                        color: WashdayColors.teal700,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Text(
                  displayName,
                  style: WashdayType.style(
                    size: 12,
                    weight: 620,
                    color: WashdayColors.ink,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 1),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: WashdayColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({this.onTap, this.hasUnread = false});

  final VoidCallback? onTap;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasUnread ? 'Notifications, one unread' : 'Notifications',
      child: Material(
        color: WashdayColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WashdayRadii.tile),
          side: const BorderSide(color: WashdayColors.hairlineStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 21,
                  color: WashdayColors.inkSecondary,
                ),
                if (hasUnread)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: WashdayColors.red500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
