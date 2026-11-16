import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../data/seed.dart';
import '../../data/session_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = (width * 0.094).clamp(33.0, 40.0);
    final account = ref.watch(currentAccountProvider);
    final orders = ref.watch(ordersProvider);
    final order = orders.activeFor(account.customerId);
    final firstName = account.detail.split(' · ').first;

    return WashdayPage(
      gap: 15,
      bottomClearance: 176,
      onRefresh: WashdayRefresh.replay,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: WashdayColors.teal600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  WashdayKicker('Good morning, $firstName'),
                ],
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Laundry,\n',
                      style: WashdayType.style(
                        size: titleSize,
                        weight: 690,
                        color: WashdayColors.ink,
                        height: 1,
                        letterSpacing: titleSize * -0.057,
                      ),
                    ),
                    TextSpan(
                      text: 'handled with care.',
                      style: WashdayType.style(
                        size: titleSize,
                        weight: 550,
                        color: WashdayColors.textSecondary,
                        height: 1,
                        letterSpacing: titleSize * -0.057,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (order == null)
          const _NoActiveOrderCard()
        else
          _ActiveOrderCard(
            order: order,
            onTap: () => context.push('/customer/orders/${order.id}'),
          ),
        const _PromoCard(),
        _LoyaltyCard(loyalty: loyaltyFor(account.customerId)),
      ],
    );
  }
}

class _NoActiveOrderCard extends StatelessWidget {
  const _NoActiveOrderCard();

  @override
  Widget build(BuildContext context) {
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WashdayKicker('No active order'),
          const SizedBox(height: 8),
          Text('Nothing in the wash.', style: WashdayType.title(size: 21)),
          const SizedBox(height: 6),
          Text(
            'Start your next order and choose a drop-off time.',
            style: WashdayType.muted(size: 12.5, height: 1.45),
          ),
          const SizedBox(height: 13),
          WashdayButton(
            label: 'Start an order',
            icon: Icons.arrow_forward_rounded,
            height: 46,
            fontSize: 13.5,
            onPressed: () => context.go('/customer/new-order'),
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order, required this.onTap});

  final WashdayOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final idSize = (width * 0.078).clamp(27.0, 32.0);

    return WashdayCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Active order', style: WashdayType.kicker()),
                    ),
                    const SizedBox(width: 8),
                    WashdayStatusPill(order.statusCopy, showDot: true),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  order.id,
                  style: WashdayType.style(
                    size: idSize,
                    weight: 680,
                    color: WashdayColors.ink,
                    height: 1,
                    letterSpacing: idSize * -0.05,
                    tabularFigures: true,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.local_laundry_service_outlined,
                      size: 14,
                      color: WashdayColors.teal700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${order.service}  ·  Est. ${order.estimate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WashdayType.muted(size: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                _OrderProgress(currentStage: order.stageIndex),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: WashdayColors.surfaceMuted,
              border: Border(top: BorderSide(color: WashdayColors.hairline)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 15,
                  color: WashdayColors.teal700,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    order.counterLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WashdayType.style(
                      size: 12,
                      weight: 640,
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
                        text: order.unitRateLabel,
                        style: WashdayType.style(
                          size: 14.5,
                          weight: 660,
                          color: WashdayColors.inkSecondary,
                          height: 1,
                          letterSpacing: -0.3,
                          tabularFigures: true,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${order.unit}',
                        style: WashdayType.muted(size: 11, height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 17,
                  color: WashdayColors.slate400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderProgress extends StatelessWidget {
  const _OrderProgress({required this.currentStage});

  final int currentStage;

  @override
  Widget build(BuildContext context) {
    const stages = orderTimeline;
    final step = currentStage.clamp(0, stages.length - 1);
    final currentLabel = stages[step].label;
    final nextLabel = step == stages.length - 1
        ? 'Complete'
        : stages[step + 1].label;
    return Semantics(
      label: 'Order progress: $currentLabel now, $nextLabel next',
      child: SizedBox(
        height: 47,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ProgressLinePainter(
                  currentFraction: stages.length <= 1
                      ? 0
                      : step / (stages.length - 1),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < stages.length; index++)
                  Expanded(
                    child: _ProgressStep(
                      label: stages[index].label,
                      state: index < currentStage
                          ? _StepState.done
                          : index == currentStage
                          ? _StepState.current
                          : _StepState.next,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, current, next }

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.label, required this.state});

  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == _StepState.current;
    final isDone = state == _StepState.done;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDone ? WashdayColors.teal700 : WashdayColors.white,
            shape: BoxShape.circle,
            border: isDone
                ? null
                : Border.all(
                    color: isCurrent
                        ? WashdayColors.amber500
                        : WashdayColors.hairlineStrong,
                    width: isCurrent ? 2 : 1.2,
                  ),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Container(
                  width: isCurrent ? 7 : 4.5,
                  height: isCurrent ? 7 : 4.5,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? WashdayColors.amber500
                        : WashdayColors.slate400,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        const SizedBox(height: 7),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: WashdayType.style(
              size: 9.8,
              weight: isCurrent
                  ? 680
                  : isDone
                  ? 600
                  : 500,
              color: isCurrent
                  ? WashdayColors.amber700
                  : isDone
                  ? WashdayColors.inkSecondary
                  : WashdayColors.textSecondary,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressLinePainter extends CustomPainter {
  const _ProgressLinePainter({required this.currentFraction});

  final double currentFraction;

  @override
  void paint(Canvas canvas, Size size) {
    const y = 12.0;
    final span = size.width / 5;
    final left = span / 2;
    final right = size.width - span / 2;
    if (right <= left) return;

    final basePaint = Paint()
      ..color = WashdayColors.hairlineStrong
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, y), Offset(right, y), basePaint);

    final progressPaint = Paint()
      ..color = WashdayColors.teal600
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final progressX = left + (right - left) * currentFraction;
    if (progressX > left) {
      canvas.drawLine(Offset(left, y), Offset(progressX, y), progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressLinePainter oldDelegate) =>
      oldDelegate.currentFraction != currentFraction;
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = (width * 0.068).clamp(24.0, 27.0);
    return WashdayCard(
      padding: EdgeInsets.zero,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WashdayKicker(
                            'Current offer',
                            color: WashdayColors.amber700,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '10% off your order',
                            style: WashdayType.style(
                              size: titleSize,
                              weight: 670,
                              color: WashdayColors.ink,
                              height: 1.06,
                              letterSpacing: titleSize * -0.045,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Use code',
                                style: WashdayType.muted(size: 12, height: 1.4),
                              ),
                              const SizedBox(width: 7),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: WashdayColors.amber100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: WashdayColors.amber200,
                                  ),
                                ),
                                child: Text(
                                  welcomeVoucher.code,
                                  style: WashdayType.style(
                                    size: 11,
                                    weight: 700,
                                    color: WashdayColors.amber700,
                                    letterSpacing: 1.35,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Minimum spend 3.00 · discount capped at 5.00',
                            style: WashdayType.muted(size: 12, height: 1.45),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: WashdayColors.amber100,
                        borderRadius: BorderRadius.circular(
                          WashdayRadii.control,
                        ),
                        border: Border.all(color: WashdayColors.amber200),
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        size: 27,
                        color: WashdayColors.amber700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: const BoxDecoration(
              color: WashdayColors.surfaceMuted,
              border: Border(top: BorderSide(color: WashdayColors.hairline)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: WashdayColors.slate400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Applied at weighing · one offer per order.',
                    style: WashdayType.muted(size: 11.5, height: 1.4),
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

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.loyalty});

  final LoyaltyAccount loyalty;

  @override
  Widget build(BuildContext context) {
    final stamps = loyalty.stamps.clamp(0, 10);
    final remaining = 10 - stamps;
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: WashdayColors.teal100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: WashdayColors.teal700,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text('Loyalty card', style: WashdayType.title(size: 17)),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$stamps',
                      style: WashdayType.style(
                        size: 22,
                        weight: 670,
                        color: WashdayColors.ink,
                        height: 1,
                        letterSpacing: -0.9,
                        tabularFigures: true,
                      ),
                    ),
                    TextSpan(
                      text: ' / 10',
                      style: WashdayType.style(
                        size: 12.5,
                        weight: 500,
                        color: WashdayColors.textSecondary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cell = (constraints.maxWidth - 8 * 4) / 5;
              final stamp = math.min(46.0, cell);
              Widget row(int start, int count) => Row(
                children: [
                  for (var index = 0; index < 5; index++)
                    Expanded(
                      child: Center(
                        child: index < count
                            ? _Stamp(
                                size: stamp,
                                kind: start + index < stamps
                                    ? _StampKind.earned
                                    : start + index == 9
                                    ? _StampKind.reward
                                    : _StampKind.empty,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              );
              return Column(
                children: [
                  row(0, math.min(5, stamps > 0 ? 5 : 0)),
                  const SizedBox(height: 9),
                  row(5, stamps > 5 ? 5 : 0),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: WashdayColors.hairline)),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$remaining more eligible paid pickups earn ',
                    style: WashdayType.muted(size: 12, height: 1.45),
                  ),
                  TextSpan(
                    text: '50% off up to 5 kg',
                    style: WashdayType.style(
                      size: 12,
                      weight: 650,
                      color: WashdayColors.inkSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StampKind { earned, empty, reward }

class _Stamp extends StatelessWidget {
  const _Stamp({required this.size, required this.kind});

  final double size;
  final _StampKind kind;

  @override
  Widget build(BuildContext context) {
    final decoration = switch (kind) {
      _StampKind.earned => const BoxDecoration(
        color: WashdayColors.ink,
        shape: BoxShape.circle,
      ),
      _StampKind.empty => BoxDecoration(
        color: WashdayColors.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(color: WashdayColors.hairlineStrong, width: 1.2),
      ),
      _StampKind.reward => BoxDecoration(
        color: WashdayColors.amber100,
        shape: BoxShape.circle,
        border: Border.all(color: WashdayColors.amber200),
      ),
    };

    final child = switch (kind) {
      _StampKind.earned => Icon(
        Icons.water_drop_rounded,
        size: size * 0.33,
        color: Colors.white,
      ),
      _StampKind.empty => Container(
        width: 4.5,
        height: 4.5,
        decoration: const BoxDecoration(
          color: WashdayColors.slate400,
          shape: BoxShape.circle,
        ),
      ),
      _StampKind.reward => Icon(
        Icons.card_giftcard_rounded,
        size: size * 0.38,
        color: WashdayColors.amber700,
      ),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: decoration,
      child: child,
    );
  }
}
