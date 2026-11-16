import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/fixtures.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class OwnerVouchersScreen extends StatelessWidget {
  const OwnerVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Offers',
          title: 'Voucher management',
          subtitle: 'Manage your offers and their rules.',
          dense: true,
        ),
        WashdayCard(
          padding: EdgeInsets.zero,
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 4, color: WashdayColors.amber500),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            welcomeVoucher.code,
                            style: WashdayType.style(
                              size: 19,
                              weight: 690,
                              color: WashdayColors.ink,
                              letterSpacing: 1.8,
                              height: 1.2,
                              tabularFigures: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const WashdayStatusPill(
                          'Active',
                          tone: WashdayTone.teal,
                          showDot: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      welcomeVoucher.discount,
                      style: WashdayType.style(
                        size: 34,
                        weight: 690,
                        color: WashdayColors.ink,
                        height: 1,
                        letterSpacing: -1.7,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Wash & fold orders · one offer per order.',
                      style: WashdayType.muted(size: 12, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: WashdayColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(
                          WashdayRadii.control,
                        ),
                        border: Border.all(color: WashdayColors.hairline),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _VoucherRule(
                              label: 'Minimum spend',
                              value: welcomeVoucher.minimumSpend
                                  .toStringAsFixed(2),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: WashdayColors.hairline,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _VoucherRule(
                              label: 'Discount cap',
                              value: welcomeVoucher.cap.toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WashdaySectionHead(
                kicker: 'At the counter',
                title: 'Voucher checks',
                titleSize: 18,
              ),
              const SizedBox(height: 6),
              for (var index = 0; index < _checks.length; index++)
                _CheckRow(index: index, text: _checks[index]),
            ],
          ),
        ),
        const WashdayNotice(
          title: 'Voucher rules',
          body:
              'WELCOME10 applies to eligible wash & fold orders and is checked at weighing.',
        ),
      ],
    );
  }

  static const _checks = <String>[
    'Check whether the voucher is active, in date and applies to the service when ordering.',
    'Check minimum spend at weighing, when the subtotal is known.',
    'Only one discount can apply to an order.',
  ];
}

class _VoucherRule extends StatelessWidget {
  const _VoucherRule({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: WashdayType.label()),
        const SizedBox(height: 3),
        Text(
          value,
          style: WashdayType.style(
            size: 17,
            weight: 680,
            color: WashdayColors.ink,
            height: 1.1,
            letterSpacing: -0.5,
            tabularFigures: true,
          ),
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: index == 0
          ? null
          : const BoxDecoration(
              border: Border(top: BorderSide(color: WashdayColors.hairline)),
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
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: WashdayType.body(size: 12.5, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}
