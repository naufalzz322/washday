import 'package:flutter/material.dart';

/// Colour and type tokens for the Washday app.
///
/// The palette keeps the prototype's cool laundry-blue canvas and petrol teal,
/// but uses opaque surfaces and quiet hairlines instead of layered glass so the
/// hierarchy stays readable in every role area.
abstract final class WashdayColors {
  static const canvas = Color(0xFFF1F5F7);
  static const canvasTop = Color(0xFFE7F0F5);

  static const ink = Color(0xFF0C1A23);
  static const inkSecondary = Color(0xFF20313C);
  static const textSecondary = Color(0xFF5A6A76);

  static const slate100 = Color(0xFFE9EFF3);
  static const slate400 = Color(0xFF80909C);
  static const slate500 = Color(0xFF62737F);
  static const slate700 = Color(0xFF3C505D);
  static const dottedBorder = Color(0xFFB7C5CF);
  static const hairline = Color(0xFFE1E8ED);
  static const hairlineStrong = Color(0xFFCFDAE2);

  static const teal100 = Color(0xFFE2F0F3);
  static const teal200 = Color(0xFFC6E3E9);
  static const teal500 = Color(0xFF3A91A4);
  static const teal600 = Color(0xFF26798B);
  static const teal700 = Color(0xFF155C6C);
  static const teal900 = Color(0xFF0B3B46);

  static const amber100 = Color(0xFFFBF0DC);
  static const amber200 = Color(0xFFF5DFB6);
  static const amber500 = Color(0xFFD99B3D);
  static const amber700 = Color(0xFF7C4B08);

  static const red500 = Color(0xFFC74636);
  static const red100 = Color(0xFFFBEAE7);

  static const white = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE3EAEF);
  static const surfaceMuted = Color(0xFFF7FAFC);

  static const deepStart = Color(0xFF123B47);
  static const deepEnd = Color(0xFF0B2630);

  static const shadowSoft = Color(0x0A1F374A);
  static const shadow = Color(0x141F374A);
}

/// Shared corner radii. A single, slightly tighter scale keeps cards, fields
/// and image tiles looking like one system rather than a set of one-offs.
abstract final class WashdayRadii {
  static const panel = 24.0;
  static const card = 20.0;
  static const control = 14.0;
  static const tile = 12.0;
  static const pill = 999.0;
}

abstract final class WashdayType {
  static const family = 'InterTight';

  static TextStyle style({
    double size = 15,
    double weight = 500,
    Color color = WashdayColors.ink,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? decorationColor,
    bool tabularFigures = false,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
      fontVariations: [FontVariation('wght', weight)],
      fontFeatures: tabularFigures
          ? const [FontFeature.tabularFigures()]
          : null,
    );
  }

  /// Uppercase editorial label used above headings and inside cards.
  static TextStyle kicker({Color color = WashdayColors.teal700}) => style(
    size: 10.5,
    weight: 700,
    color: color,
    letterSpacing: 1.15,
    height: 1.2,
  );

  /// Large, tightly tracked display heading.
  static TextStyle display({
    double size = 40,
    Color color = WashdayColors.ink,
    double? height = 0.99,
  }) => style(
    size: size,
    weight: 680,
    color: color,
    height: height,
    letterSpacing: size * -0.058,
  );

  static TextStyle title({double size = 19, Color color = WashdayColors.ink}) =>
      style(
        size: size,
        weight: 650,
        color: color,
        height: 1.22,
        letterSpacing: -0.5,
      );

  static TextStyle body({
    double size = 15,
    Color color = WashdayColors.inkSecondary,
    double height = 1.52,
  }) => style(size: size, weight: 500, color: color, height: height);

  static TextStyle muted({
    double size = 13,
    Color color = WashdayColors.textSecondary,
    double height = 1.5,
  }) => style(size: size, weight: 480, color: color, height: height);

  static TextStyle strong({
    double size = 14,
    Color color = WashdayColors.ink,
  }) => style(
    size: size,
    weight: 640,
    color: color,
    height: 1.25,
    letterSpacing: -0.1,
  );

  static TextStyle label({Color color = WashdayColors.textSecondary}) => style(
    size: 11,
    weight: 650,
    color: color,
    letterSpacing: 0.9,
    height: 1.2,
  );
}

ThemeData buildWashdayTheme() {
  const scheme = ColorScheme.light(
    primary: WashdayColors.ink,
    onPrimary: Colors.white,
    secondary: WashdayColors.teal700,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: WashdayColors.ink,
    error: WashdayColors.red500,
    onError: Colors.white,
    outline: WashdayColors.hairlineStrong,
  );

  final base = WashdayType.body();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: WashdayType.family,
    scaffoldBackgroundColor: WashdayColors.canvas,
    canvasColor: Colors.transparent,
    splashFactory: InkSparkle.splashFactory,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: WashdayColors.teal600,
      selectionColor: WashdayColors.teal100,
      selectionHandleColor: WashdayColors.teal600,
    ),
    textTheme: TextTheme(
      bodyLarge: base,
      bodyMedium: WashdayType.body(size: 14),
      bodySmall: WashdayType.muted(size: 12),
      titleLarge: WashdayType.style(size: 22, weight: 650),
      titleMedium: WashdayType.style(size: 18, weight: 640),
      labelLarge: WashdayType.style(size: 14, weight: 620),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      hintStyle: WashdayType.style(
        size: 15,
        weight: 480,
        color: WashdayColors.slate400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        borderSide: const BorderSide(color: WashdayColors.hairlineStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        borderSide: const BorderSide(color: WashdayColors.teal600, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        borderSide: const BorderSide(color: WashdayColors.red500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        borderSide: const BorderSide(color: WashdayColors.red500, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: WashdayColors.ink,
      contentTextStyle: WashdayType.body(color: Colors.white, size: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WashdayRadii.control),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: WashdayColors.hairline,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? WashdayColors.white
            : WashdayColors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? WashdayColors.teal600
            : WashdayColors.hairlineStrong,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}
