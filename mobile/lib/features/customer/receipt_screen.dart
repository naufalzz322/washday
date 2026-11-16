import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersProvider).byId(orderId);
    final receipt = receiptForOrder(order);

    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/customer/orders/$orderId');
      }
    }

    return WashdayPage(
      bottomClearance: 112,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WashdayBackLink(label: 'Order', onTap: back),
        ),
        WashdayPageHeading(
          kicker: 'Receipt',
          title: 'Payment receipt',
          subtitle: receipt == null
              ? 'This receipt is not ready yet.'
              : 'Paid and saved with your order.',
        ),
        if (receipt == null)
          const _UnavailableReceipt()
        else
          _ReceiptPaper(receipt: receipt),
        WashdayButton(label: 'Back to order', onPressed: back),
        if (receipt != null)
          Align(
            alignment: Alignment.center,
            child: WashdayTextLink(
              'View order history',
              onTap: () => context.go('/customer/orders'),
            ),
          ),
      ],
    );
  }
}

class _ReceiptPaper extends StatelessWidget {
  const _ReceiptPaper({required this.receipt});

  final OrderReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        borderRadius: BorderRadius.circular(WashdayRadii.panel),
        border: Border.all(color: WashdayColors.hairlineStrong),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141F374A),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: WashdayColors.teal700),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WashdayLeadingTile(
                      size: 42,
                      child: Icon(Icons.local_laundry_service_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Washday',
                            style: WashdayType.style(
                              size: 21,
                              weight: 660,
                              letterSpacing: -0.7,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Wash & fold · one shop',
                            style: WashdayType.muted(size: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const WashdayStatusPill(
                      'Paid',
                      tone: WashdayTone.teal,
                      showDot: true,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const WashdayDashedRule(),
                const SizedBox(height: 4),
                _ReceiptMetaRow('Order', receipt.orderId),
                _ReceiptMetaRow('Customer', receipt.customer),
                _ReceiptMetaRow('Collected', receipt.collectedOn),
                _ReceiptMetaRow('Payment', receipt.paymentMethod),
                const SizedBox(height: 8),
                const WashdayDashedRule(),
                const SizedBox(height: 15),
                const WashdayKicker('Items'),
                const SizedBox(height: 9),
                for (var index = 0; index < receipt.lines.length; index++) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _ReceiptLineRow(line: receipt.lines[index]),
                ],
                const SizedBox(height: 14),
                const WashdayDashedRule(),
                const SizedBox(height: 7),
                _ReceiptAmountRow('Subtotal', receipt.subtotal),
                if (receipt.hasDiscount)
                  _ReceiptAmountRow(
                    '${receipt.discountLabel ?? 'Discount'} discount',
                    receipt.discount ?? '',
                    accent: WashdayColors.teal700,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total paid',
                              style: WashdayType.style(
                                size: 14,
                                weight: 650,
                                color: WashdayColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'No further payment due',
                              style: WashdayType.muted(size: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        receipt.total,
                        style: WashdayType.style(
                          size: 32,
                          weight: 660,
                          color: WashdayColors.ink,
                          height: 1,
                          letterSpacing: -1.4,
                          tabularFigures: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: WashdayColors.teal100,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: WashdayColors.teal200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 17,
                        color: WashdayColors.teal700,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Paid in full · ${receipt.paymentMethod}',
                          style: WashdayType.style(
                            size: 12,
                            weight: 620,
                            color: WashdayColors.teal700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                const WashdayDashedRule(),
                const SizedBox(height: 13),
                Text(
                  'Thank you for choosing Washday.',
                  textAlign: TextAlign.center,
                  style: WashdayType.muted(size: 11.5),
                ),
                const SizedBox(height: 4),
                Text(
                  receipt.orderId,
                  textAlign: TextAlign.center,
                  style: WashdayType.style(
                    size: 10,
                    weight: 650,
                    color: WashdayColors.slate400,
                    letterSpacing: 2,
                    tabularFigures: true,
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

class _ReceiptMetaRow extends StatelessWidget {
  const _ReceiptMetaRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: WashdayType.muted(size: 11.5))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: WashdayType.style(
                size: 12.5,
                weight: 620,
                color: WashdayColors.inkSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptLineRow extends StatelessWidget {
  const _ReceiptLineRow({required this.line});

  final ReceiptLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.label,
                style: WashdayType.style(
                  size: 13.5,
                  weight: 620,
                  color: WashdayColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                line.detail,
                style: WashdayType.muted(size: 11.5, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          line.amount,
          style: WashdayType.style(
            size: 13.5,
            weight: 620,
            color: WashdayColors.ink,
            tabularFigures: true,
          ),
        ),
      ],
    );
  }
}

class _ReceiptAmountRow extends StatelessWidget {
  const _ReceiptAmountRow(this.label, this.value, {this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: WashdayType.muted(
                size: 12,
                color: accent ?? WashdayColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: WashdayType.style(
              size: 12.5,
              weight: 620,
              color: accent ?? WashdayColors.inkSecondary,
              tabularFigures: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableReceipt extends StatelessWidget {
  const _UnavailableReceipt();

  @override
  Widget build(BuildContext context) {
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      child: Column(
        children: [
          const WashdayLeadingTile(
            size: 46,
            child: Icon(Icons.receipt_long_outlined),
          ),
          const SizedBox(height: 12),
          Text(
            'Available after pickup',
            textAlign: TextAlign.center,
            style: WashdayType.title(size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'Once your order is paid and collected, the full breakdown is saved here.',
            textAlign: TextAlign.center,
            style: WashdayType.muted(size: 12.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}
