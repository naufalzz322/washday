import 'package:flutter/material.dart';

import '../app/roles.dart';
import '../app/theme.dart';
import '../data/models.dart';
import 'ui.dart';

enum WashdayAccountAction { settings, logout }

/// Flat account menu opened from the top-bar profile chip.
Future<WashdayAccountAction?> showWashdayAccountMenu(
  BuildContext context, {
  required WashdayRole role,
  required WashdayAccount account,
}) {
  return showModalBottomSheet<WashdayAccountAction>(
    context: context,
    // The shell's floating dock lives above its nested navigator, so the menu
    // must open on the root navigator to stay fully tappable.
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (sheetContext) => _AccountMenuSheet(role: role, account: account),
  );
}

/// Confirms sign-out before returning to the sign-in screen.
Future<bool> confirmWashdayLogout(
  BuildContext context, {
  required WashdayRole role,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: WashdayColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WashdayRadii.panel),
      ),
      title: Text('Log out?', style: WashdayType.title()),
      content: Text(
        role == WashdayRole.customer
            ? 'You’ll need to sign in again to see your orders and vouchers.'
            : 'You’ll need to sign in again to return to the shop.',
        style: WashdayType.muted(size: 13, height: 1.55),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'Cancel',
            style: WashdayType.style(
              size: 13,
              weight: 620,
              color: WashdayColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            'Log out',
            style: WashdayType.style(
              size: 13,
              weight: 650,
              color: WashdayColors.red500,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class _AccountMenuSheet extends StatelessWidget {
  const _AccountMenuSheet({required this.role, required this.account});

  final WashdayRole role;
  final WashdayAccount account;

  String get _settingsDetail => switch (role) {
    WashdayRole.customer => 'Profile, preferences and support',
    WashdayRole.clerk => 'Preferences and support',
    WashdayRole.owner => 'Preferences, shop settings and support',
  };

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      // heightFactor keeps the sheet this content's height so the area above
      // stays available to the modal barrier for an outside tap.
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                Row(
                  children: [
                    WashdayAccountAvatar(
                      role: role,
                      hasPhoto: account.hasPhoto,
                      initial: account.initial,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WashdayKicker('Signed in'),
                          const SizedBox(height: 5),
                          Text(
                            account.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WashdayType.title(size: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            account.detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WashdayType.muted(size: 11.5, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuRow(
                  icon: Icons.tune_rounded,
                  title: 'Settings',
                  detail: _settingsDetail,
                  onTap: () =>
                      Navigator.of(context).pop(WashdayAccountAction.settings),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: WashdayColors.hairline,
                ),
                _MenuRow(
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  detail: 'Sign out of this account',
                  danger: true,
                  showChevron: false,
                  onTap: () =>
                      Navigator.of(context).pop(WashdayAccountAction.logout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WashdayAccountAvatar extends StatelessWidget {
  const WashdayAccountAvatar({
    super.key,
    required this.role,
    this.size = 44,
    this.hasPhoto = false,
    this.initial,
  });

  final WashdayRole role;
  final double size;
  final bool hasPhoto;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    if (role == WashdayRole.customer && hasPhoto) {
      return ClipOval(
        child: Image.asset(
          'assets/images/customer-alex.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.28),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: WashdayColors.teal100,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial ?? role.initial,
        style: WashdayType.style(
          size: size * 0.34,
          weight: 700,
          color: WashdayColors.teal700,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
    this.danger = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  final bool danger;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final foreground = danger ? WashdayColors.red500 : WashdayColors.ink;
    return Semantics(
      button: true,
      label: '$title. $detail',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WashdayRadii.tile),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 58),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  WashdayLeadingTile(
                    background: danger
                        ? WashdayColors.red100
                        : WashdayColors.teal100,
                    foreground: danger
                        ? WashdayColors.red500
                        : WashdayColors.teal700,
                    child: Icon(icon),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WashdayType.style(
                            size: 14,
                            weight: 640,
                            color: foreground,
                            height: 1.25,
                            letterSpacing: -0.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WashdayType.muted(size: 11.5, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  if (showChevron) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: WashdayColors.slate400,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
