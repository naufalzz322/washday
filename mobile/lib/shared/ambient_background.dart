import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app/theme.dart';

/// The layered sky-to-canvas wash behind every screen.
class WashdayAmbientBackground extends StatelessWidget {
  const WashdayAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(painter: _AmbientPainter(), child: SizedBox.expand()),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter();

  void _radial(
    Canvas canvas,
    Rect rect, {
    required Alignment alignment,
    required double radius,
    required List<Color> colors,
    List<double>? stops,
  }) {
    final gradient = RadialGradient(
      center: alignment,
      radius: radius,
      colors: colors,
      stops: stops,
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE7F0F5),
            Color(0xFFEDF4F7),
            Color(0xFFF3F7F9),
            WashdayColors.canvas,
          ],
          stops: [0, 0.32, 0.68, 1],
        ).createShader(rect),
    );

    _radial(
      canvas,
      rect,
      alignment: const Alignment(-0.95, -1),
      radius: 0.9,
      colors: const [Color(0x66D5E9EF), Color(0x00D5E9EF)],
    );
    _radial(
      canvas,
      rect,
      alignment: const Alignment(1, -1),
      radius: 0.86,
      colors: const [Color(0x40F3E8DC), Color(0x00F3E8DC)],
    );
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) => false;
}

/// Mirrors the prototype's glass blur without leaking it into every card.
class WashdayBlur extends StatelessWidget {
  const WashdayBlur({
    super.key,
    required this.child,
    this.sigma = 20,
    this.saturation = 1.2,
  });

  final Widget child;
  final double sigma;
  final double saturation;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }
}

class WashdaySurfaceGradient extends StatelessWidget {
  const WashdaySurfaceGradient({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE6E7F0F5), Color(0xCCE7F0F5)],
        ),
        border: Border(bottom: BorderSide(color: WashdayColors.hairline)),
      ),
      child: child,
    );
  }
}

class WashdayHairline extends StatelessWidget {
  const WashdayHairline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: WashdayColors.hairline);
  }
}
