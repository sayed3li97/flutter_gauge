import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../core/gauge_pointer.dart';
import '../core/gauge_range.dart';
import '../engine/radial_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A radial (circular) gauge with optional needle, ticks, labels, ranges,
/// extra pointers, and full accessibility support.
///
/// The gauge resolves its visual tokens from [style] if provided, falling back
/// to any [GaugeThemeExtension] registered on the ambient [Theme], and finally
/// to the built-in [DefaultGaugeStyle].
///
/// Example:
/// ```dart
/// RadialGauge(
///   controller: GaugeController(initialValue: 60),
///   min: 0,
///   max: 100,
/// )
/// ```
///
/// With an extra pointer (e.g. a speed-limit marker):
/// ```dart
/// RadialGauge(
///   controller: speedCtrl,
///   min: 0,
///   max: 200,
///   extraPointers: [
///     GaugePointer(
///       controller: limitCtrl,
///       color: Colors.red,
///       label: 'Speed limit',
///     ),
///   ],
/// )
/// ```
class RadialGauge extends LeafRenderObjectWidget {
  /// Creates a [RadialGauge].
  ///
  /// [controller] is required; all other parameters have sensible defaults.
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
  });

  // ─── Named constructors / presets ───────────────────────────────────────────

  /// Speedometer preset: 0–[max] km/h, danger above 80%.
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
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      style: style,
      mode: mode,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
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
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      style: style,
      mode: mode,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Fuel gauge preset: 0–100%.
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
    );
  }

  // ─── Properties ─────────────────────────────────────────────────────────────

  /// The controller that drives the primary needle position.
  final GaugeController controller;

  /// Minimum value on the scale. Defaults to `0`.
  final double min;

  /// Maximum value on the scale. Defaults to `100`.
  final double max;

  /// Angle in degrees at which the arc begins, measured clockwise from the
  /// positive x-axis (3 o'clock). Defaults to `225` (roughly 7 o'clock).
  final double startAngleDeg;

  /// Total sweep of the arc in degrees. Defaults to `270`.
  final double sweepAngleDeg;

  /// Coloured bands painted over the track to highlight value zones.
  final List<GaugeRange> ranges;

  /// Number of major tick marks (and label positions) drawn on the track.
  /// Defaults to `5`.
  final int majorDivisions;

  /// Number of minor tick intervals between each pair of major ticks.
  /// Set to `0` to disable minor ticks. Defaults to `5`.
  final int minorDivisions;

  /// Whether to render numeric labels at each major tick. Defaults to `true`.
  final bool showLabels;

  /// Whether to render the main needle. Defaults to `true`.
  final bool showNeedle;

  /// Whether the gauge responds to pointer/touch events. When `true`, dragging
  /// updates [onChanged]. Defaults to `false`.
  final bool interactive;

  /// Called whenever the user drags the gauge while [interactive] is `true`.
  final ValueChanged<double>? onChanged;

  /// Whether to render a numeric label at the centre of the gauge. The label
  /// defaults to the formatted [controller] value unless [centerLabel] is set.
  final bool showCenterLabel;

  /// Overrides the auto-formatted value shown when [showCenterLabel] is `true`.
  final String? centerLabel;

  /// Text style for the centre label. Falls back to a bold version of the
  /// gauge's [GaugeTokens.labelStyle] when `null`.
  final TextStyle? centerLabelStyle;

  /// Visual style overrides. When `null` the gauge inherits from
  /// [GaugeThemeExtension] or uses [DefaultGaugeStyle].
  final GaugeStyle? style;

  /// Light/dark rendering mode. Falls back to the theme extension, then
  /// [GaugeMode.ambient].
  final GaugeMode? mode;

  /// Additional needles overlaid on the gauge face.
  ///
  /// Each [GaugePointer] has its own [GaugeController] and optional colour,
  /// stroke width, and length fraction, making it easy to display a target
  /// value, a speed limit, or a historical maximum alongside the primary
  /// needle.
  ///
  /// Defaults to an empty list (no extra needles).
  final List<GaugePointer> extraPointers;

  /// Accessibility label announced by screen readers instead of the default
  /// `'Radial gauge'` string.
  ///
  /// When `null` the render object uses `'Radial gauge'` as the label and
  /// the formatted [controller] value as the semantic value.
  final String? semanticsLabel;

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
      showCenterLabel: showCenterLabel,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      extraPointers: extraPointers,
      semanticsLabel: semanticsLabel,
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
      ..onChanged = onChanged
      ..showCenterLabel = showCenterLabel
      ..centerLabel = centerLabel
      ..centerLabelStyle = centerLabelStyle
      ..extraPointers = extraPointers
      ..semanticsLabel = semanticsLabel;
  }
}
