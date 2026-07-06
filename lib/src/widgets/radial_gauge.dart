import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/gauge_annotation.dart';
import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../core/gauge_pointer.dart';
import '../core/gauge_range.dart';
import '../core/value_to_angle.dart';
import '../engine/radial_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A radial (circular) gauge with needle, ticks, labels, ranges, extra
/// pointers, annotations, and full accessibility support.
///
/// New in v0.3.0:
/// - [child] — a Flutter widget rendered at the centre of the gauge face.
/// - [annotations] — a list of [GaugeAnnotation] widgets pinned at specific
///   value positions around the gauge arc.
/// - [labelFormatter] — custom formatter for the numeric tick labels.
/// - [unitText] — unit suffix appended to the auto-formatted centre value.
///
/// Example:
/// ```dart
/// RadialGauge(
///   controller: speedCtrl,
///   min: 0,
///   max: 200,
///   unitText: 'km/h',
///   showCenterLabel: true,
///   annotations: [
///     GaugeAnnotation(
///       value: 100,
///       radiusFraction: 0.55,
///       widget: const Text('100', style: TextStyle(color: Colors.red)),
///     ),
///   ],
/// )
/// ```
class RadialGauge extends StatelessWidget {
  const RadialGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 100,
    this.startAngleDeg = 225,
    this.sweepAngleDeg = 270,
    this.ranges = const [],
    this.majorDivisions = 5,
    this.minorDivisions = 5,
    this.showLabels = true,
    this.showNeedle = true,
    this.interactive = false,
    this.onChanged,
    this.showCenterLabel = false,
    this.centerLabel,
    this.centerLabelStyle,
    this.style,
    this.mode,
    this.extraPointers = const [],
    this.semanticsLabel,
    this.child,
    this.annotations = const [],
    this.labelFormatter,
    this.unitText,
    this.fillColor,
  });

  // ─── Named constructors / presets ───────────────────────────────────────────

  /// Speedometer preset: 0–[max] km/h, danger above 80 %.
  factory RadialGauge.speedometer({
    Key? key,
    required GaugeController controller,
    double max = 200,
    bool showCenterLabel = false,
    String? centerLabel,
    TextStyle? centerLabelStyle,
    GaugeStyle? style,
    GaugeMode? mode,
    List<GaugePointer> extraPointers = const [],
    String? semanticsLabel,
    Widget? child,
    List<GaugeAnnotation> annotations = const [],
    String Function(double)? labelFormatter,
    String? unitText,
    Color? fillColor,
  }) {
    return RadialGauge(
      key: key,
      controller: controller,
      min: 0,
      max: max,
      startAngleDeg: 225,
      sweepAngleDeg: 270,
      majorDivisions: 10,
      minorDivisions: 5,
      showNeedle: true,
      showLabels: true,
      ranges: [
        GaugeRange(min: 0, max: max * 0.6, color: const Color(0xFF0077BB)),
        GaugeRange(
            min: max * 0.6, max: max * 0.8, color: const Color(0xFFEE7733)),
        GaugeRange(min: max * 0.8, max: max, color: const Color(0xFFCC3311)),
      ],
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      style: style,
      mode: mode,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
      annotations: annotations,
      labelFormatter: labelFormatter,
      unitText: unitText,
      fillColor: fillColor,
      child: child,
    );
  }

  /// Tachometer preset: 0–[maxRpm] RPM, redline above [redlineRpm].
  factory RadialGauge.tachometer({
    Key? key,
    required GaugeController controller,
    double redlineRpm = 6500,
    double maxRpm = 8000,
    bool showCenterLabel = false,
    String? centerLabel,
    TextStyle? centerLabelStyle,
    GaugeStyle? style,
    GaugeMode? mode,
    List<GaugePointer> extraPointers = const [],
    String? semanticsLabel,
    Widget? child,
    List<GaugeAnnotation> annotations = const [],
    String Function(double)? labelFormatter,
    String? unitText,
    Color? fillColor,
  }) {
    return RadialGauge(
      key: key,
      controller: controller,
      min: 0,
      max: maxRpm,
      majorDivisions: 8,
      minorDivisions: 5,
      ranges: [
        GaugeRange(
            min: redlineRpm, max: maxRpm, color: const Color(0xFFCC3311)),
      ],
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      style: style,
      mode: mode,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
      annotations: annotations,
      labelFormatter: labelFormatter,
      unitText: unitText,
      fillColor: fillColor,
      child: child,
    );
  }

  /// Fuel gauge preset: 0–100 %.
  factory RadialGauge.fuel({
    Key? key,
    required GaugeController controller,
    bool showCenterLabel = false,
    String? centerLabel,
    TextStyle? centerLabelStyle,
    GaugeStyle? style,
    GaugeMode? mode,
    List<GaugePointer> extraPointers = const [],
    String? semanticsLabel,
    Widget? child,
    List<GaugeAnnotation> annotations = const [],
    String Function(double)? labelFormatter,
    String? unitText,
    Color? fillColor,
  }) {
    return RadialGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      majorDivisions: 4,
      minorDivisions: 0,
      ranges: [
        const GaugeRange(min: 0, max: 25, color: Color(0xFFCC3311)),
        const GaugeRange(min: 25, max: 50, color: Color(0xFFEE7733)),
        const GaugeRange(min: 50, max: 100, color: Color(0xFF0077BB)),
      ],
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      style: style,
      mode: mode,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
      annotations: annotations,
      labelFormatter: labelFormatter,
      unitText: unitText,
      fillColor: fillColor,
      child: child,
    );
  }

  /// Compass preset: 0–360°.
  factory RadialGauge.compass({
    Key? key,
    required GaugeController controller,
    bool showCenterLabel = false,
    String? centerLabel,
    TextStyle? centerLabelStyle,
    GaugeStyle? style,
    GaugeMode? mode,
    List<GaugePointer> extraPointers = const [],
    String? semanticsLabel,
    Widget? child,
    List<GaugeAnnotation> annotations = const [],
    String Function(double)? labelFormatter,
    String? unitText,
    Color? fillColor,
  }) {
    return RadialGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 360,
      startAngleDeg: 270,
      sweepAngleDeg: 360,
      majorDivisions: 8,
      minorDivisions: 3,
      showLabels: true,
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      style: style,
      mode: mode,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
      annotations: annotations,
      labelFormatter: labelFormatter,
      unitText: unitText,
      fillColor: fillColor,
      child: child,
    );
  }

  // ─── Properties ─────────────────────────────────────────────────────────────

  final GaugeController controller;
  final double min;
  final double max;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final List<GaugeRange> ranges;
  final int majorDivisions;
  final int minorDivisions;
  final bool showLabels;
  final bool showNeedle;
  final bool interactive;
  final ValueChanged<double>? onChanged;
  final bool showCenterLabel;
  final String? centerLabel;
  final TextStyle? centerLabelStyle;
  final GaugeStyle? style;
  final GaugeMode? mode;
  final List<GaugePointer> extraPointers;
  final String? semanticsLabel;

  /// Widget rendered at the centre of the gauge face (on top of the canvas).
  ///
  /// When provided, the canvas centre label is hidden even if
  /// [showCenterLabel] is `true`.
  final Widget? child;

  /// List of [GaugeAnnotation]s pinned at specific value positions on the arc.
  final List<GaugeAnnotation> annotations;

  /// Custom formatter for the numeric tick labels.
  ///
  /// ```dart
  /// labelFormatter: (v) => v >= 1000 ? '${(v/1000).toStringAsFixed(1)}k' : '${v.toInt()}',
  /// ```
  final String Function(double)? labelFormatter;

  /// Unit suffix appended to the auto-formatted centre value label.
  final String? unitText;

  /// Solid fill colour for the dial face, drawn beneath the track, ticks,
  /// and needle. Useful for skeuomorphic analog gauge clusters with an
  /// opaque disc background instead of a transparent one.
  final Color? fillColor;

  // ─── Internal ───────────────────────────────────────────────────────────────

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _resolve(context);

    final leaf = _RadialGaugeLeaf(
      controller: controller,
      tokens: tokens,
      min: min,
      max: max,
      startAngleDeg: startAngleDeg,
      sweepAngleDeg: sweepAngleDeg,
      ranges: ranges,
      majorDivisions: majorDivisions,
      minorDivisions: minorDivisions,
      showLabels: showLabels,
      showNeedle: showNeedle,
      interactive: interactive,
      onChanged: onChanged,
      showCenterLabel: child == null && showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
      labelFormatter: labelFormatter,
      unitText: unitText,
      fillColor: fillColor,
    );

    final hasOverlays = child != null || annotations.isNotEmpty;

    if (!hasOverlays) return leaf;

    return Stack(
      children: [
        leaf,
        if (child != null)
          Positioned.fill(
            child: Align(alignment: Alignment.center, child: child!),
          ),
        if (annotations.isNotEmpty)
          LayoutBuilder(builder: (ctx, constraints) {
            final side = math.min(constraints.maxWidth, constraints.maxHeight);
            if (side == 0) return const SizedBox.shrink();
            final cx = side / 2;
            final cy = side / 2;
            final trackR = side / 2 - tokens.trackStrokeWidth / 2 - 2;
            final startRad = degToRad(startAngleDeg);
            final sweepRad = degToRad(sweepAngleDeg);

            return Stack(
              children: [
                for (final ann in annotations)
                  Builder(builder: (_) {
                    final frac =
                        ((ann.value - min) / (max - min)).clamp(0.0, 1.0);
                    final angle = startRad + frac * sweepRad;
                    final r = trackR * ann.radiusFraction;
                    final x = cx + math.cos(angle) * r + ann.offset.dx;
                    final y = cy + math.sin(angle) * r + ann.offset.dy;
                    return Positioned(
                      left: x,
                      top: y,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: ann.widget,
                      ),
                    );
                  }),
              ],
            );
          }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private leaf — pure canvas rendering.
// ---------------------------------------------------------------------------

class _RadialGaugeLeaf extends LeafRenderObjectWidget {
  const _RadialGaugeLeaf({
    required this.controller,
    required this.tokens,
    required this.min,
    required this.max,
    required this.startAngleDeg,
    required this.sweepAngleDeg,
    required this.ranges,
    required this.majorDivisions,
    required this.minorDivisions,
    required this.showLabels,
    required this.showNeedle,
    required this.interactive,
    required this.onChanged,
    required this.showCenterLabel,
    required this.centerLabel,
    required this.centerLabelStyle,
    required this.extraPointers,
    required this.semanticsLabel,
    required this.labelFormatter,
    required this.unitText,
    required this.fillColor,
  });

  final GaugeController controller;
  final GaugeTokens tokens;
  final double min;
  final double max;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final List<GaugeRange> ranges;
  final int majorDivisions;
  final int minorDivisions;
  final bool showLabels;
  final bool showNeedle;
  final bool interactive;
  final ValueChanged<double>? onChanged;
  final bool showCenterLabel;
  final String? centerLabel;
  final TextStyle? centerLabelStyle;
  final List<GaugePointer> extraPointers;
  final String? semanticsLabel;
  final String Function(double)? labelFormatter;
  final String? unitText;
  final Color? fillColor;

  @override
  RadialGaugeRenderBox createRenderObject(BuildContext context) {
    return RadialGaugeRenderBox(
      controller: controller,
      tokens: tokens,
      min: min,
      max: max,
      startAngleDeg: startAngleDeg,
      sweepAngleDeg: sweepAngleDeg,
      ranges: ranges,
      majorDivisions: majorDivisions,
      minorDivisions: minorDivisions,
      showLabels: showLabels,
      showNeedle: showNeedle,
      interactive: interactive,
      onChanged: onChanged,
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
      labelFormatter: labelFormatter,
      unitText: unitText,
      fillColor: fillColor,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RadialGaugeRenderBox renderObject) {
    renderObject
      ..tokens = tokens
      ..min = min
      ..max = max
      ..ranges = ranges
      ..majorDivisions = majorDivisions
      ..minorDivisions = minorDivisions
      ..showLabels = showLabels
      ..showNeedle = showNeedle
      ..interactive = interactive
      ..onChanged = onChanged
      ..showCenterLabel = showCenterLabel
      ..centerLabel = centerLabel
      ..centerLabelStyle = centerLabelStyle
      ..extraPointers = extraPointers
      ..semanticsLabel = semanticsLabel
      ..labelFormatter = labelFormatter
      ..unitText = unitText
      ..fillColor = fillColor;
  }
}
