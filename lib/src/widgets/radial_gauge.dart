import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../core/gauge_range.dart';
import '../engine/radial_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A radial (circular) gauge with optional needle, ticks, labels, and ranges.
///
/// Example:
/// ```dart
/// RadialGauge(
///   controller: GaugeController(initialValue: 60),
///   min: 0,
///   max: 100,
/// )
/// ```
class RadialGauge extends LeafRenderObjectWidget {
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
    this.style,
    this.mode,
  });

  // ─── Named constructors / presets ───────────────────────────────────────────

  /// Speedometer preset: 0–[max] km/h, danger above 80%.
  factory RadialGauge.speedometer({
    Key? key,
    required GaugeController controller,
    double max = 200,
    GaugeStyle? style,
    GaugeMode? mode,
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
        GaugeRange(min: max * 0.6, max: max * 0.8, color: const Color(0xFFEE7733)),
        GaugeRange(min: max * 0.8, max: max, color: const Color(0xFFCC3311)),
      ],
      style: style,
      mode: mode,
    );
  }

  /// Tachometer preset: 0–[maxRpm] RPM, redline above [redlineRpm].
  factory RadialGauge.tachometer({
    Key? key,
    required GaugeController controller,
    double redlineRpm = 6500,
    double maxRpm = 8000,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return RadialGauge(
      key: key,
      controller: controller,
      min: 0,
      max: maxRpm,
      majorDivisions: 8,
      minorDivisions: 5,
      ranges: [
        GaugeRange(min: redlineRpm, max: maxRpm, color: const Color(0xFFCC3311)),
      ],
      style: style,
      mode: mode,
    );
  }

  /// Fuel gauge preset: 0–100%.
  factory RadialGauge.fuel({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
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
      style: style,
      mode: mode,
    );
  }

  /// Compass preset: 0–360°.
  factory RadialGauge.compass({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
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
      style: style,
      mode: mode,
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
  final GaugeStyle? style;
  final GaugeMode? mode;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  RadialGaugeRenderBox createRenderObject(BuildContext context) {
    return RadialGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
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
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RadialGaugeRenderBox renderObject) {
    final tokens = _resolve(context);
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
      ..onChanged = onChanged;
  }
}
