import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/roles.dart';
import '../../app/theme.dart';
import '../../shared/ambient_background.dart';
import '../../shared/top_bar.dart';
import '../../shared/ui.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = WashdayViewport.gutter(context);
    final titleSize = (width * 0.12).clamp(42.0, 56.0);
    final contentWidth = math.min(
      WashdayViewport.contentMaxWidth,
      width - gutter * 2,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: WashdayAmbientBackground()),
          Column(
            children: [
              WashdayGuestTopBar(onBrandTap: () {}),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: WashdayViewport.contentMaxWidth,
                            ),
                            child: _WelcomeHeader(titleSize: titleSize),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: gutter),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          // Let the photograph take the remaining space on
                          // normal phones, while keeping a readable minimum on
                          // short screens or when text is scaled up.
                          final remaining =
                              constraints.viewportMainAxisExtent -
                              constraints.precedingScrollExtent;
                          final heroHeight = remaining.clamp(220.0, 440.0);
                          return SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: WashdayViewport.contentMaxWidth,
                                ),
                                child: _WelcomeMedia(
                                  width: contentWidth,
                                  height: heroHeight,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const _WelcomeCtaBar(),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.titleSize});

  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Wash & fold · one shop', style: WashdayType.kicker()),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Laundry day,\n',
                  style: WashdayType.style(
                    size: titleSize,
                    weight: 660,
                    color: WashdayColors.ink,
                    height: 0.94,
                    letterSpacing: titleSize * -0.062,
                  ),
                ),
                TextSpan(
                  text: 'handled.',
                  style: WashdayType.style(
                    size: titleSize,
                    weight: 560,
                    color: WashdayColors.slate500,
                    height: 0.94,
                    letterSpacing: titleSize * -0.062,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Text(
              'Drop off your bag. We wash, fold and tell you the moment it’s ready.',
              style: WashdayType.muted(size: 14, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeMedia extends StatelessWidget {
  const _WelcomeMedia({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WashdayRadii.panel),
        border: Border.all(color: const Color(0xA6FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: WashdayColors.shadow,
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login-hero.jpg',
            semanticLabel:
                'A person carrying a basket of fresh laundry in warm daylight',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.16),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x000B1821), Color(0x2E0B1821)],
                stops: [0.52, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCtaBar extends StatelessWidget {
  const _WelcomeCtaBar();

  @override
  Widget build(BuildContext context) {
    final gutter = WashdayViewport.gutter(context);
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: WashdayColors.canvas,
        border: Border(top: BorderSide(color: WashdayColors.hairline)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 14 + bottomSafe),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: WashdayViewport.contentMaxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WashdayButton(
                  label: 'Get started',
                  icon: Icons.arrow_forward_rounded,
                  height: 56,
                  fontSize: 16,
                  radius: WashdayRadii.control,
                  onPressed: () => context.go('/sign-in'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Track every order from drop-off to pickup.',
                  textAlign: TextAlign.center,
                  style: WashdayType.muted(size: 11.5, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
