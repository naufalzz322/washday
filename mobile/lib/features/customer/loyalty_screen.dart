import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        WashdayBackLink(
          label: 'Profile',
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/profile');
            }
          },
        ),
        const WashdayPageHeading(
          kicker: 'Rewards',
          title: 'Loyalty card',
          subtitle: 'Collect 10 stamps for 50% off up to 5 kg.',
        ),
        WashdayDeepCard(
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WashdayKicker('Your progress', color: Color(0xB3FFFFFF)),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '5',
                      style: WashdayType.style(
                        size: 46,
                        weight: 690,
                        color: Colors.white,
                        height: 0.95,
                        letterSpacing: -2.2,
                        tabularFigures: true,
                      ),
                    ),
                    TextSpan(
                      text: ' / 10',
                      style: WashdayType.style(
                        size: 16,
                        weight: 500,
                        color: const Color(0xB3FFFFFF),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Semantics(
                label:
                    'Five of ten loyalty stamps earned; five more eligible paid pickups to earn a reward',
                child: ExcludeSemantics(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cell = (constraints.maxWidth - 8 * 4) / 5;
                      final size = math.min(46.0, cell);
                      return Column(
                        children: [
                          _stampRow(0, 5, size),
                          const SizedBox(height: 9),
                          _stampRow(5, 5, size),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(height: 1, color: const Color(0x24FFFFFF)),
              const SizedBox(height: 12),
              Text(
                '5 more eligible paid pickups unlock your reward.',
                style: WashdayType.style(
                  size: 12,
                  weight: 500,
                  color: const Color(0xCCFFFFFF),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 7),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('How stamps work', style: WashdayType.title(size: 17)),
              const SizedBox(height: 5),
              for (var index = 0; index < _rules.length; index++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: index == 0
                      ? null
                      : const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: WashdayColors.hairline),
                          ),
                        ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '0${index + 1}',
                          style: WashdayType.style(
                            size: 10.5,
                            weight: 700,
                            color: WashdayColors.teal700,
                            letterSpacing: 0.6,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _rules[index],
                          style: WashdayType.body(size: 12.5, height: 1.55),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static const _rules = <String>[
    'A stamp is earned after an order is picked up and paid.',
    'An order must weigh at least 1 kg to earn a stamp.',
    'Unused rewards do not expire.',
    'The reward applies to per-kilogram services.',
  ];

  Widget _stampRow(int start, int count, double size) {
    return Row(
      children: [
        for (var index = 0; index < 5; index++)
          Expanded(
            child: Center(
              child: index < count
                  ? _LoyaltyStamp(
                      size: size,
                      kind: start + index == 9
                          ? _LoyaltyStampKind.reward
                          : start + index < 5
                          ? _LoyaltyStampKind.earned
                          : _LoyaltyStampKind.empty,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

enum _LoyaltyStampKind { earned, empty, reward }

class _LoyaltyStamp extends StatelessWidget {
  const _LoyaltyStamp({required this.size, required this.kind});

  final double size;
  final _LoyaltyStampKind kind;

  @override
  Widget build(BuildContext context) {
    final decoration = switch (kind) {
      _LoyaltyStampKind.earned => const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      _LoyaltyStampKind.empty => BoxDecoration(
        color: const Color(0x14FFFFFF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x3DFFFFFF), width: 1.2),
      ),
      _LoyaltyStampKind.reward => const BoxDecoration(
        color: WashdayColors.amber500,
        shape: BoxShape.circle,
      ),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: decoration,
      child: switch (kind) {
        _LoyaltyStampKind.earned => Icon(
          Icons.water_drop_rounded,
          size: size * 0.36,
          color: WashdayColors.ink,
        ),
        _LoyaltyStampKind.empty => Container(
          width: 4.5,
          height: 4.5,
          decoration: const BoxDecoration(
            color: Color(0x66FFFFFF),
            shape: BoxShape.circle,
          ),
        ),
        _LoyaltyStampKind.reward => Icon(
          Icons.card_giftcard_rounded,
          size: size * 0.42,
          color: WashdayColors.ink,
        ),
      },
    );
  }
}
