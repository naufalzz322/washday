import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../data/fixtures.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class CustomerVouchersScreen extends StatelessWidget {
  const CustomerVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final minimum = welcomeVoucher.minimumSpend.toStringAsFixed(2);
    final cap = welcomeVoucher.cap.toStringAsFixed(2);

    return WashdayPage(
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        const WashdayPageHeading(
          kicker: 'Offers',
          title: 'Your vouchers',
          subtitle: 'One code for your next wash & fold order.',
        ),
        WashdayCard(
          padding: EdgeInsets.zero,
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 4, color: WashdayColors.amber500),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WashdayKicker(
                      'Active offer',
                      color: WashdayColors.amber700,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '10% off your order',
                      style: WashdayType.style(
                        size: 28,
                        weight: 680,
                        color: WashdayColors.ink,
                        height: 1.05,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Your first wash & fold order.',
                      style: WashdayType.muted(size: 13, height: 1.45),
                    ),
                  ],
                ),
              ),
              const _TicketSeam(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WashdayKicker('Your code'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              welcomeVoucher.code,
                              maxLines: 1,
                              style: WashdayType.style(
                                size: 30,
                                weight: 690,
                                color: WashdayColors.ink,
                                letterSpacing: 2.4,
                                height: 1.05,
                                tabularFigures: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CopyCodeButton(code: welcomeVoucher.code),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Minimum spend $minimum · discount capped at $cap',
                      style: WashdayType.muted(size: 12, height: 1.45),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: const BoxDecoration(
                  color: WashdayColors.surfaceMuted,
                  border: Border(
                    top: BorderSide(color: WashdayColors.hairline),
                  ),
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
        ),
      ],
    );
  }
}

class _CopyCodeButton extends StatefulWidget {
  const _CopyCodeButton({required this.code});

  final String code;

  @override
  State<_CopyCodeButton> createState() => _CopyCodeButtonState();
}

class _CopyCodeButtonState extends State<_CopyCodeButton> {
  Timer? _resetTimer;
  bool _copied = false;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    _resetTimer?.cancel();
    setState(() => _copied = true);
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      liveRegion: _copied,
      excludeSemantics: true,
      label: _copied
          ? 'Voucher code ${widget.code} copied'
          : 'Copy voucher code ${widget.code}',
      onTap: _copy,
      child: Material(
        color: WashdayColors.teal100,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _copy,
          child: Container(
            constraints: const BoxConstraints(minWidth: 84, minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WashdayRadii.control),
              border: Border.all(color: WashdayColors.teal200),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Row(
                key: ValueKey(_copied),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                    size: 15,
                    color: WashdayColors.teal700,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _copied ? 'Copied' : 'Copy',
                    style: const TextStyle(
                      fontFamily: WashdayType.family,
                      fontSize: 11.5,
                      height: 1.1,
                      color: WashdayColors.teal700,
                      fontVariations: [FontVariation('wght', 650)],
                    ),
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

class _TicketSeam extends StatelessWidget {
  const _TicketSeam();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _SeamPainter())),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: WashdayColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: WashdayColors.hairlineStrong),
            ),
            child: const Icon(
              Icons.percent_rounded,
              size: 13,
              color: WashdayColors.amber700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeamPainter extends CustomPainter {
  const _SeamPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 16.0;
    final paint = Paint()
      ..color = WashdayColors.hairlineStrong
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    final y = size.height / 2;
    for (double x = inset; x < size.width - inset; x += dash + gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, size.width - inset), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SeamPainter oldDelegate) => false;
}
