import 'package:flutter/material.dart';

import '../app/theme.dart';

/// The compact black tile with the Washday droplet.
class WashdayBrandMark extends StatelessWidget {
  const WashdayBrandMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: WashdayColors.ink,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0C1A23),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.58, size * 0.58),
          painter: const _DropletPainter(),
        ),
      ),
    );
  }
}

class _DropletPainter extends CustomPainter {
  const _DropletPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final drop = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..cubicTo(w * 0.64, h * 0.27, w * 0.84, h * 0.46, w * 0.84, h * 0.63)
      ..cubicTo(w * 0.84, h * 0.82, w * 0.69, h * 0.94, w * 0.5, h * 0.94)
      ..cubicTo(w * 0.31, h * 0.94, w * 0.16, h * 0.82, w * 0.16, h * 0.63)
      ..cubicTo(w * 0.16, h * 0.46, w * 0.36, h * 0.27, w * 0.5, h * 0.05)
      ..close();

    canvas.drawPath(drop, Paint()..color = Colors.white);

    final highlight = Path()
      ..moveTo(w * 0.34, h * 0.64)
      ..quadraticBezierTo(w * 0.37, h * 0.78, w * 0.52, h * 0.81);
    canvas.drawPath(
      highlight,
      Paint()
        ..color = WashdayColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DropletPainter oldDelegate) => false;
}

class WashdaySpark extends StatelessWidget {
  const WashdaySpark({
    super.key,
    this.size = 12,
    this.color = WashdayColors.teal600,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SparkPainter(color));
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..quadraticBezierTo(w * 0.57, h * 0.43, w, h * 0.5)
      ..quadraticBezierTo(w * 0.57, h * 0.57, w * 0.5, h)
      ..quadraticBezierTo(w * 0.43, h * 0.57, 0, h * 0.5)
      ..quadraticBezierTo(w * 0.43, h * 0.43, w * 0.5, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class WashdayWordmark extends StatelessWidget {
  const WashdayWordmark({super.key, this.color = WashdayColors.ink});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Washday',
          style: WashdayType.style(
            size: 20,
            weight: 650,
            color: color,
            height: 1,
            letterSpacing: -1.0,
          ),
        ),
        Transform.translate(
          offset: const Offset(1, -3),
          child: const WashdaySpark(size: 12),
        ),
      ],
    );
  }
}

class WashdayBrandLockup extends StatelessWidget {
  const WashdayBrandLockup({
    super.key,
    this.onTap,
    this.semanticLabel = 'Washday home',
    this.showWordmark = true,
  });

  final VoidCallback? onTap;
  final String semanticLabel;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WashdayBrandMark(),
              if (showWordmark) ...[
                const SizedBox(width: 8),
                const WashdayWordmark(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
