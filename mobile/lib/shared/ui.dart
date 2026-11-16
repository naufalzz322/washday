import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';

class WashdayCard extends StatelessWidget {
  const WashdayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = WashdayRadii.card,
    this.color = WashdayColors.card,
    this.gradient,
    this.borderColor = WashdayColors.cardBorder,
    this.shadow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Gradient? gradient;
  final Color borderColor;
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: WashdayColors.shadowSoft,
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

class WashdayDeepCard extends StatelessWidget {
  const WashdayDeepCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = WashdayRadii.panel,
    this.gradientColors = const [
      WashdayColors.deepStart,
      Color(0xFF0F303B),
      WashdayColors.deepEnd,
    ],
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24123B47),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
            ),
          ),
          Positioned(
            top: -104,
            right: -86,
            width: 250,
            height: 250,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WashdayColors.teal500.withValues(alpha: 0.26),
                    WashdayColors.teal500.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class WashdayKicker extends StatelessWidget {
  const WashdayKicker(
    this.text, {
    super.key,
    this.color = WashdayColors.teal700,
    this.letterSpacing = 1.05,
  });

  final String text;
  final Color color;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: WashdayType.style(
        size: 10.5,
        weight: 700,
        color: color,
        letterSpacing: letterSpacing,
        height: 1.2,
      ),
    );
  }
}

class WashdaySectionHead extends StatelessWidget {
  const WashdaySectionHead({
    super.key,
    required this.title,
    this.kicker,
    this.trailing,
    this.titleSize = 19,
  });

  final String? kicker;
  final String title;
  final Widget? trailing;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kicker != null) ...[
                WashdayKicker(kicker!),
                const SizedBox(height: 6),
              ],
              Text(title, style: WashdayType.title(size: titleSize)),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}

class WashdayPageHeading extends StatelessWidget {
  const WashdayPageHeading({
    super.key,
    this.kicker,
    required this.title,
    this.subtitle,
    this.titleWidget,
    this.dense = false,
  });

  final String? kicker;
  final String title;
  final String? subtitle;
  final Widget? titleWidget;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final size = dense
        ? (width * 0.076).clamp(27.0, 32.0)
        : (width * 0.086).clamp(31.0, 37.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kicker != null) ...[
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
                Flexible(child: WashdayKicker(kicker!)),
              ],
            ),
            const SizedBox(height: 9),
          ],
          titleWidget ??
              Text(
                title,
                style: WashdayType.style(
                  size: size,
                  weight: 680,
                  color: WashdayColors.ink,
                  height: 1.01,
                  letterSpacing: size * -0.056,
                ),
              ),
          if (subtitle != null) ...[
            SizedBox(height: dense ? 7 : 9),
            Text(
              subtitle!,
              style: WashdayType.muted(size: dense ? 12.5 : 13.5, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class WashdayCountPill extends StatelessWidget {
  const WashdayCountPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: WashdayColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WashdayRadii.pill),
        border: Border.all(color: WashdayColors.hairline),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: WashdayType.style(
            size: 10.5,
            weight: 640,
            color: WashdayColors.textSecondary,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

enum WashdayTone { warning, neutral, teal, red }

class WashdayStatusPill extends StatelessWidget {
  const WashdayStatusPill(
    this.label, {
    super.key,
    this.tone = WashdayTone.warning,
    this.showDot = false,
  });

  final String label;
  final WashdayTone tone;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, borderColor, dotColor) = switch (tone) {
      WashdayTone.warning => (
        WashdayColors.amber100,
        WashdayColors.amber700,
        const Color(0x66D99B3D),
        WashdayColors.amber500,
      ),
      WashdayTone.neutral => (
        WashdayColors.surfaceMuted,
        WashdayColors.slate700,
        WashdayColors.hairline,
        WashdayColors.slate400,
      ),
      WashdayTone.teal => (
        WashdayColors.teal100,
        WashdayColors.teal700,
        WashdayColors.teal200,
        WashdayColors.teal600,
      ),
      WashdayTone.red => (
        WashdayColors.red100,
        WashdayColors.red500,
        const Color(0x4DC74636),
        WashdayColors.red500,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(WashdayRadii.pill),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        widthFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: WashdayType.style(
                size: 10.5,
                weight: 650,
                color: foreground,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum WashdayButtonTone { primary, secondary, onDark, onDarkQuiet }

class WashdayButton extends StatelessWidget {
  const WashdayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = WashdayButtonTone.primary,
    this.icon,
    this.height = 52,
    this.expand = true,
    this.fontSize = 15,
    this.radius = WashdayRadii.control,
  });

  final String label;
  final VoidCallback? onPressed;
  final WashdayButtonTone tone;
  final IconData? icon;
  final double height;
  final bool expand;
  final double fontSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, borderColor, shadows) = switch (tone) {
      WashdayButtonTone.primary => (
        WashdayColors.ink,
        Colors.white,
        Colors.transparent,
        const [
          BoxShadow(
            color: WashdayColors.shadowSoft,
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      WashdayButtonTone.secondary => (
        WashdayColors.white,
        WashdayColors.inkSecondary,
        WashdayColors.hairlineStrong,
        const <BoxShadow>[],
      ),
      WashdayButtonTone.onDark => (
        Colors.white,
        WashdayColors.ink,
        Colors.transparent,
        const <BoxShadow>[],
      ),
      WashdayButtonTone.onDarkQuiet => (
        const Color(0x14FFFFFF),
        Colors.white,
        const Color(0x42FFFFFF),
        const <BoxShadow>[],
      ),
    };

    final button = Container(
      height: height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: WashdayType.style(
                      size: fontSize,
                      weight: 640,
                      color: foreground,
                      height: 1.15,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (expand) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}

class WashdayTextLink extends StatelessWidget {
  const WashdayTextLink(
    this.label, {
    super.key,
    required this.onTap,
    this.color = WashdayColors.teal700,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: WashdayType.style(size: 12.5, weight: 640, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WashdayBackLink extends StatelessWidget {
  const WashdayBackLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: WashdayColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: WashdayColors.hairlineStrong),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: WashdayColors.inkSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: WashdayType.style(
                  size: 12.5,
                  weight: 640,
                  color: WashdayColors.teal700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WashdayNotice extends StatelessWidget {
  const WashdayNotice({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.info_outline_rounded,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: WashdayColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        border: Border.all(color: WashdayColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: WashdayColors.teal100,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: WashdayColors.teal700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WashdayType.style(
                    size: 12.5,
                    weight: 650,
                    color: WashdayColors.inkSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(body, style: WashdayType.muted(size: 11.5, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WashdayFilterChip extends StatelessWidget {
  const WashdayFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? WashdayColors.ink : WashdayColors.white,
            borderRadius: BorderRadius.circular(WashdayRadii.pill),
            border: Border.all(
              color: selected
                  ? WashdayColors.ink
                  : WashdayColors.hairlineStrong,
            ),
          ),
          // Keep the chip at its label width inside a Wrap instead of
          // stretching to the full row.
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: WashdayType.style(
                size: 12,
                weight: selected ? 650 : 590,
                color: selected ? Colors.white : WashdayColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WashdaySkeletonBlock extends StatelessWidget {
  const WashdaySkeletonBlock({
    super.key,
    required this.height,
    this.width,
    this.radius = 8,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: WashdayColors.slate100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class WashdayLeadingTile extends StatelessWidget {
  const WashdayLeadingTile({
    super.key,
    required this.child,
    this.size = 38,
    this.radius = WashdayRadii.tile,
    this.background = WashdayColors.teal100,
    this.foreground = WashdayColors.teal700,
  });

  final Widget child;
  final double size;
  final double radius;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: WashdayColors.hairline),
      ),
      child: IconTheme(
        data: IconThemeData(color: foreground, size: size * 0.5),
        child: DefaultTextStyle(
          style: WashdayType.style(
            size: size * 0.34,
            weight: 700,
            color: foreground,
          ),
          child: child,
        ),
      ),
    );
  }
}

class WashdayListRow extends StatelessWidget {
  const WashdayListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.showTopBorder = true,
    this.padding = const EdgeInsets.symmetric(vertical: 11),
    this.titleMaxLines = 1,
    this.titleColor = WashdayColors.ink,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool showTopBorder;
  final EdgeInsetsGeometry padding;
  final int titleMaxLines;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 11)],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: WashdayType.style(
                      size: 13.5,
                      weight: 640,
                      color: titleColor,
                      height: 1.3,
                      letterSpacing: -0.15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: WashdayType.muted(size: 11.5, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (showChevron) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: WashdayColors.slate400,
              ),
            ],
          ],
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: WashdayColors.hairline))
            : null,
      ),
      child: onTap == null
          ? row
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: row,
              ),
            ),
    );
  }
}

class WashdayDetailRow extends StatelessWidget {
  const WashdayDetailRow(
    this.label,
    this.value, {
    super.key,
    this.emphasizeValue = false,
  });

  final String label;
  final String value;
  final bool emphasizeValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: WashdayColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: WashdayType.muted(size: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: WashdayType.style(
                size: 12.5,
                weight: emphasizeValue ? 660 : 560,
                color: emphasizeValue
                    ? WashdayColors.ink
                    : WashdayColors.inkSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WashdayMetric {
  const WashdayMetric({required this.value, required this.label});

  final String value;
  final String label;
}

/// A compact row of figures used to summarise an account, catalog or list.
class WashdayMetricStrip extends StatelessWidget {
  const WashdayMetricStrip({
    super.key,
    required this.metrics,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
  });

  final List<WashdayMetric> metrics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: WashdayColors.white,
        borderRadius: BorderRadius.circular(WashdayRadii.card),
        border: Border.all(color: WashdayColors.cardBorder),
      ),
      child: Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            if (index > 0)
              Container(width: 1, height: 28, color: WashdayColors.hairline),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    metrics[index].value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WashdayType.style(
                      size: 20,
                      weight: 660,
                      color: WashdayColors.ink,
                      height: 1.05,
                      letterSpacing: -0.7,
                      tabularFigures: true,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    metrics[index].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: WashdayType.muted(size: 10.5, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WashdayField extends StatelessWidget {
  const WashdayField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.textFieldKey,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final Key? textFieldKey;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: WashdayType.style(
            size: 12,
            weight: 630,
            color: WashdayColors.inkSecondary,
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          key: textFieldKey,
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: WashdayType.style(
            size: 15,
            weight: 500,
            color: WashdayColors.ink,
            letterSpacing: -0.1,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            errorText: errorText,
            filled: true,
            fillColor: WashdayColors.surfaceMuted,
          ),
        ),
      ],
    );
  }
}

class WashdaySelectField<T> extends StatelessWidget {
  const WashdaySelectField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.minHeight = 50,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final field = Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: WashdayColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        border: Border.all(color: WashdayColors.hairlineStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: WashdayColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(WashdayRadii.control),
          dropdownColor: WashdayColors.white,
          style: WashdayType.body(size: 15),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label!,
          style: WashdayType.style(
            size: 12,
            weight: 630,
            color: WashdayColors.inkSecondary,
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 7),
        field,
      ],
    );
  }
}

class WashdayDashedRule extends StatelessWidget {
  const WashdayDashedRule({
    super.key,
    this.color = WashdayColors.dottedBorder,
    this.height = 1,
  });

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _DashedRulePainter(color)),
    );
  }
}

class _DashedRulePainter extends CustomPainter {
  const _DashedRulePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + dashWidth, size.width), size.height / 2),
        paint,
      );
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRulePainter oldDelegate) =>
      oldDelegate.color != color;
}

class WashdayStampRow extends StatelessWidget {
  const WashdayStampRow({super.key, required this.earned, this.total = 10});

  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < total; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < earned
                        ? WashdayColors.ink
                        : index == total - 1
                        ? WashdayColors.amber100
                        : WashdayColors.surfaceMuted,
                    border: Border.all(
                      color: index < earned
                          ? WashdayColors.ink
                          : index == total - 1
                          ? WashdayColors.amber200
                          : WashdayColors.hairlineStrong,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: index < earned
                        ? const Icon(
                            Icons.water_drop_rounded,
                            size: 12,
                            color: Colors.white,
                          )
                        : index == total - 1
                        ? const Icon(
                            Icons.card_giftcard_rounded,
                            size: 13,
                            color: WashdayColors.amber700,
                          )
                        : Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: WashdayColors.dottedBorder,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
