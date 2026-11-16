import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/orders_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class OrderPlacedScreen extends ConsumerWidget {
  const OrderPlacedScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersProvider).byId(orderId);

    return WashdayPage(
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(
            label: 'Orders',
            onTap: () => context.go('/customer/orders'),
          ),
        ),
        WashdayDeepCard(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0x24FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const WashdayKicker('Request sent', color: Color(0xB3FFFFFF)),
              const SizedBox(height: 8),
              Text(
                'Order placed.',
                style: WashdayType.style(
                  size: 34,
                  weight: 680,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -1.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We’ll let you know as soon as the shop accepts it. Bring your laundry in after that.',
                style: WashdayType.style(
                  size: 13,
                  weight: 480,
                  color: const Color(0xCCFFFFFF),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (order == null)
          WashdayCard(
            shadow: false,
            child: Text(
              'This request isn’t available any more.',
              style: WashdayType.muted(size: 14),
            ),
          )
        else ...[
          WashdayCard(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(child: WashdayKicker('Your request')),
                    WashdayStatusPill(order.statusCopy, showDot: true),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  order.id,
                  style: WashdayType.style(
                    size: 32,
                    weight: 680,
                    color: WashdayColors.ink,
                    height: 1,
                    letterSpacing: -1.5,
                    tabularFigures: true,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.service} · ${order.rateLabel}',
                  style: WashdayType.muted(size: 13, height: 1.4),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: WashdayColors.hairline),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Fact(label: 'Drop-off', value: order.dropOff),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: WashdayColors.hairline,
                      ),
                      Expanded(
                        child: _Fact(
                          label: 'Turnaround',
                          value: order.estimate,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.note != null) ...[
                  const SizedBox(height: 12),
                  Text(order.note!, style: WashdayType.muted(size: 12.5)),
                ],
              ],
            ),
          ),
          WashdayCard(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WashdayKicker('What happens next'),
                const SizedBox(height: 10),
                const _NextStep(
                  index: '1',
                  title: 'The shop reviews your request',
                  detail:
                      'You’ll see Accepted or a reason if they can’t take it.',
                ),
                const _NextStep(
                  index: '2',
                  title: 'Bring the laundry in',
                  detail: 'The counter weighs it and confirms the final total.',
                ),
                const _NextStep(
                  index: '3',
                  title: 'Pay when you collect',
                  detail:
                      'Cash or transfer at the counter. No charge is made now.',
                  last: true,
                ),
              ],
            ),
          ),
          WashdayButton(
            label: 'View order',
            onPressed: () => context.go('/customer/orders/${order.id}'),
          ),
          WashdayButton(
            label: 'Back home',
            tone: WashdayButtonTone.secondary,
            onPressed: () => context.go('/customer/home'),
          ),
        ],
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WashdayType.style(
            size: 10,
            weight: 640,
            color: WashdayColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: WashdayType.style(
            size: 13.5,
            weight: 650,
            color: WashdayColors.ink,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.index,
    required this.title,
    required this.detail,
    this.last = false,
  });

  final String index;
  final String title;
  final String detail;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: WashdayColors.teal100,
              shape: BoxShape.circle,
            ),
            child: Text(
              index,
              style: WashdayType.style(
                size: 11,
                weight: 700,
                color: WashdayColors.teal700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WashdayType.strong(size: 13.5)),
                const SizedBox(height: 2),
                Text(detail, style: WashdayType.muted(size: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
