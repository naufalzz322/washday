import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/roles.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../../data/seed.dart';
import '../../data/session_controller.dart';
import '../../shared/ambient_background.dart';
import '../../shared/top_bar.dart';
import '../../shared/ui.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  WashdayAccount? _selectedAccount;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final result = ref
        .read(sessionProvider.notifier)
        .signIn(_emailController.text, _passwordController.text);
    if (!result.ok) {
      setState(() => _error = result.message);
      return;
    }
    setState(() => _error = null);
    context.go(result.account!.homeRoute);
  }

  Future<void> _chooseAccount() async {
    final account = await showModalBottomSheet<WashdayAccount>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => const _AccountSheet(),
    );
    if (!mounted || account == null) return;
    setState(() {
      _selectedAccount = account;
      _emailController.text = account.email;
      _passwordController.text = account.password;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = WashdayViewport.gutter(context);
    final titleSize = (width * 0.096).clamp(34.0, 42.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WashdayAmbientBackground()),
          Column(
            children: [
              WashdayGuestTopBar(
                onBrandTap: () => context.go('/'),
                semanticLabel: 'Washday home',
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    gutter,
                    14,
                    gutter,
                    24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WashdayKicker('Welcome back'),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Sign in to\n',
                                  style: WashdayType.style(
                                    size: titleSize,
                                    weight: 660,
                                    color: WashdayColors.ink,
                                    height: 0.99,
                                    letterSpacing: titleSize * -0.058,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Washday.',
                                  style: WashdayType.style(
                                    size: titleSize,
                                    weight: 560,
                                    color: WashdayColors.slate500,
                                    height: 0.99,
                                    letterSpacing: titleSize * -0.058,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 11),
                          Text(
                            'Use your details to sign in.',
                            style: WashdayType.muted(size: 13.5),
                          ),
                          const SizedBox(height: 15),
                          WashdayCard(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
                            shadow: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                WashdayField(
                                  label: 'Email',
                                  controller: _emailController,
                                  hint: 'you@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.username],
                                  textFieldKey: const Key('sign-in-email'),
                                  onChanged: (_) {
                                    if (_error != null) {
                                      setState(() => _error = null);
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                WashdayField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  hint: 'Your password',
                                  obscureText: !_showPassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  textFieldKey: const Key('sign-in-password'),
                                  onChanged: (_) {
                                    if (_error != null) {
                                      setState(() => _error = null);
                                    }
                                  },
                                  onSubmitted: (_) => _signIn(),
                                  suffix: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: TextButton(
                                      onPressed: () => setState(
                                        () => _showPassword = !_showPassword,
                                      ),
                                      style: TextButton.styleFrom(
                                        minimumSize: const Size(48, 38),
                                        foregroundColor: WashdayColors.teal700,
                                        backgroundColor: _showPassword
                                            ? WashdayColors.teal100
                                            : Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _showPassword ? 'Hide' : 'Show',
                                        style: WashdayType.style(
                                          size: 12,
                                          weight: 650,
                                          color: WashdayColors.teal700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    key: const Key('sign-in-error'),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: WashdayColors.red100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0x4DC74636),
                                      ),
                                    ),
                                    child: Text(
                                      _error!,
                                      style: WashdayType.style(
                                        size: 12,
                                        weight: 560,
                                        color: WashdayColors.red500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                WashdayButton(
                                  key: const Key('sign-in-submit'),
                                  label: 'Sign in',
                                  onPressed: _signIn,
                                  height: 54,
                                ),
                                const SizedBox(height: 11),
                                Text(
                                  'Enter your email and password.',
                                  textAlign: TextAlign.center,
                                  style: WashdayType.muted(
                                    size: 12,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            'Or use a saved account',
                            style: WashdayType.style(
                              size: 12,
                              weight: 640,
                              color: WashdayColors.inkSecondary,
                            ),
                          ),
                          const SizedBox(height: 7),
                          _AccountPicker(
                            account: _selectedAccount,
                            onTap: _chooseAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountPicker extends StatelessWidget {
  const _AccountPicker({required this.account, required this.onTap});

  final WashdayAccount? account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: account == null
          ? 'Choose an account'
          : 'Account ${account!.name}. Choose another account',
      child: Material(
        color: WashdayColors.white,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        child: InkWell(
          key: const Key('account-picker'),
          borderRadius: BorderRadius.circular(WashdayRadii.control),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WashdayRadii.control),
              border: Border.all(
                color: account == null
                    ? WashdayColors.hairlineStrong
                    : WashdayColors.teal200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: WashdayColors.teal100,
                    borderRadius: BorderRadius.circular(WashdayRadii.tile),
                  ),
                  child: Icon(
                    account == null
                        ? Icons.person_outline_rounded
                        : Icons.check_rounded,
                    size: 16,
                    color: WashdayColors.teal700,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account?.name ?? 'Select account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WashdayType.style(
                          size: 13.5,
                          weight: 620,
                          color: WashdayColors.ink,
                        ),
                      ),
                      if (account != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          account!.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WashdayType.muted(size: 11, height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: WashdayColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSheet extends StatelessWidget {
  const _AccountSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
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
                const WashdayKicker('Saved accounts'),
                const SizedBox(height: 6),
                Text('Choose an account', style: WashdayType.title()),
                const SizedBox(height: 4),
                Text(
                  'We’ll fill in the email and password. You still need to sign in.',
                  style: WashdayType.muted(size: 12, height: 1.45),
                ),
                const SizedBox(height: 10),
                for (final account in washdayAccounts)
                  _AccountOption(
                    account: account,
                    onTap: () => Navigator.of(context).pop(account),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  const _AccountOption({required this.account, required this.onTap});

  final WashdayAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('account-option-${account.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: WashdayColors.hairline)),
          ),
          child: Row(
            children: [
              if (account.hasPhoto)
                ClipOval(
                  child: Image.asset(
                    'assets/images/customer-alex.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.28),
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: WashdayColors.teal100,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    account.initial,
                    style: WashdayType.style(
                      size: 14,
                      weight: 700,
                      color: WashdayColors.teal700,
                    ),
                  ),
                ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: WashdayType.style(
                        size: 14,
                        weight: 640,
                        color: WashdayColors.ink,
                      ),
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
              const Icon(
                Icons.chevron_right_rounded,
                color: WashdayColors.slate400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
