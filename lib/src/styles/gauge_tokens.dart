import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../core/gauge_tick_style.dart';

/// Immutable set of resolved design tokens consumed by every render engine.
///
/// [GaugeTokens] is the single source of truth for all visual properties used
/// by the gauge painting layer. Every parameter is optional and ships with a
/// sensible const default, so developers only need to supply the values they
/// want to customise:
///
/// ```dart
/// // Use all defaults:
/// const GaugeTokens()
///
/// // Override just the accent colour:
/// const GaugeTokens(valueColor: Color(0xFFE91E63))
/// ```
///
/// The class is designed to be composed through [copyWith] and animated
/// through [lerp]; the render engine has no knowledge of where the values
/// came from.
class GaugeTokens {
  /// Creates a fully-resolved token set.
  ///
  /// All parameters are optional. Omitted parameters fall back to the
  /// opinionated defaults documented on each field.
  const GaugeTokens({
    this.trackColor = const Color(0xFF3D3D3D),
    this.trackStrokeWidth = 8.0,
    this.trackStrokeCap = StrokeCap.round,
    this.trackBorderRadius = 4.0,
    this.valueColor = const Color(0xFF6750A4),
    this.valueStrokeWidth = 10.0,
    this.valueGradient,
    this.valueGlowRadius = 0.0,
    this.valueGlowColor,
    this.needleColor = const Color(0xFF6750A4),
    this.needleWidth = 3.0,
    this.needleTipStyle = NeedleTipStyle.sharp,
    this.needleDropShadow = false,
    this.knobColor = const Color(0xFF6750A4),
    this.knobRadius = 8.0,
    this.knobBorderColor,
    this.knobBorderWidth = 2.0,
    this.majorTick = const GaugeTickStyle(
      color: Color(0xFF9E9E9E),
      strokeWidth: 1.5,
      length: 12,
    ),
    this.minorTick = const GaugeTickStyle(
      color: Color(0xFFBDBDBD),
      strokeWidth: 1.0,
      length: 6,
    ),
    this.labelStyle = const TextStyle(
      color: Color(0xFF9E9E9E),
      fontSize: 10,
    ),
    this.labelOffset = 16.0,
    this.zoneNormal = const Color(0xFF0077BB),
    this.zoneWarning = const Color(0xFFEE7733),
    this.zoneDanger = const Color(0xFFCC3311),
    this.annotationTextStyle = const TextStyle(
      color: Color(0xFF9E9E9E),
      fontSize: 10,
    ),
    this.dragOverlayColor = const Color(0x336750A4),
    this.dragOverlayRadius = 20.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeInOut,
  });

  // -------------------------------------------------------------------------
  // Track
  // -------------------------------------------------------------------------

  /// Background track colour.
  ///
  /// Defaults to `Color(0xFF3D3D3D)` — a dark charcoal that works on both
  /// light and dark backgrounds.
  final Color trackColor;

  /// Stroke width of the background track arc, in logical pixels.
  ///
  /// Defaults to `8.0`.
  final double trackStrokeWidth;

  /// Cap style applied to both ends of the background track arc.
  ///
  /// Defaults to [StrokeCap.round].
  final StrokeCap trackStrokeCap;

  /// Corner radius used when the gauge renders a linear / bar track.
  ///
  /// Defaults to `4.0`.
  final double trackBorderRadius;

  // -------------------------------------------------------------------------
  // Value arc / bar
  // -------------------------------------------------------------------------

  /// Solid fill colour of the value indicator arc.
  ///
  /// Ignored when [valueGradient] is non-null.
  /// Defaults to Material Design's `Color(0xFF6750A4)` (deep purple).
  final Color valueColor;

  /// Stroke width of the value indicator arc, in logical pixels.
  ///
  /// Typically a couple of pixels wider than [trackStrokeWidth] so the value
  /// arc appears raised.
  /// Defaults to `10.0`.
  final double valueStrokeWidth;

  /// Optional gradient applied along the value indicator arc.
  ///
  /// When non-null this overrides [valueColor].
  /// Defaults to `null`.
  final Gradient? valueGradient;

  /// Blur radius of the outer glow painted behind the value arc or bar.
  ///
  /// Set to `0.0` (the default) to disable the glow effect.
  /// Typical values: 6–20 logical pixels.
  final double valueGlowRadius;

  /// Colour of the outer glow. Falls back to [valueColor] at 50 % opacity
  /// when `null` and [valueGlowRadius] is positive.
  final Color? valueGlowColor;

  // -------------------------------------------------------------------------
  // Needle
  // -------------------------------------------------------------------------

  /// Colour of the needle body.
  ///
  /// Defaults to `Color(0xFF6750A4)`.
  final Color needleColor;

  /// Width of the needle at its widest point, in logical pixels.
  ///
  /// Defaults to `3.0`.
  final double needleWidth;

  /// Shape drawn at the tip of the needle.
  ///
  /// Defaults to [NeedleTipStyle.sharp].
  final NeedleTipStyle needleTipStyle;

  /// Whether the needle casts a drop shadow.
  ///
  /// Defaults to `false`.
  final bool needleDropShadow;

  // -------------------------------------------------------------------------
  // Centre knob
  // -------------------------------------------------------------------------

  /// Fill colour of the centre knob.
  ///
  /// Defaults to `Color(0xFF6750A4)`.
  final Color knobColor;

  /// Radius of the centre knob circle, in logical pixels.
  ///
  /// Defaults to `8.0`.
  final double knobRadius;

  /// Optional colour of the ring drawn around the centre knob.
  ///
  /// When `null` no border ring is painted.
  /// Defaults to `null`.
  final Color? knobBorderColor;

  /// Stroke width of the optional knob border ring, in logical pixels.
  ///
  /// Has no visual effect when [knobBorderColor] is `null`.
  /// Defaults to `2.0`.
  final double knobBorderWidth;

  // -------------------------------------------------------------------------
  // Tick marks
  // -------------------------------------------------------------------------

  /// Style applied to major (primary) tick marks.
  ///
  /// Defaults to grey (`Color(0xFF9E9E9E)`), 1.5 px wide, 12 px long.
  final GaugeTickStyle majorTick;

  /// Style applied to minor (secondary) tick marks.
  ///
  /// Defaults to light grey (`Color(0xFFBDBDBD)`), 1.0 px wide, 6 px long.
  final GaugeTickStyle minorTick;

  // -------------------------------------------------------------------------
  // Labels
  // -------------------------------------------------------------------------

  /// [TextStyle] used for the numeric scale labels around the gauge.
  ///
  /// Defaults to 10 sp grey text (`Color(0xFF9E9E9E)`).
  final TextStyle labelStyle;

  /// Radial distance between the outer tick edge and the nearest label edge,
  /// in logical pixels.
  ///
  /// Defaults to `16.0`.
  final double labelOffset;

  // -------------------------------------------------------------------------
  // Zones
  // -------------------------------------------------------------------------

  /// Colour used for the "normal / safe" zone arc segment.
  ///
  /// Defaults to `Color(0xFF0077BB)` (accessible blue).
  final Color zoneNormal;

  /// Colour used for the "warning / caution" zone arc segment.
  ///
  /// Defaults to `Color(0xFFEE7733)` (accessible orange).
  final Color zoneWarning;

  /// Colour used for the "danger / critical" zone arc segment.
  ///
  /// Defaults to `Color(0xFFCC3311)` (accessible red).
  final Color zoneDanger;

  // -------------------------------------------------------------------------
  // Annotations
  // -------------------------------------------------------------------------

  /// [TextStyle] used for freeform annotation labels painted onto the gauge
  /// face.
  ///
  /// Defaults to 10 sp grey text (`Color(0xFF9E9E9E)`).
  final TextStyle annotationTextStyle;

  // -------------------------------------------------------------------------
  // Drag interaction
  // -------------------------------------------------------------------------

  /// Colour of the semi-transparent circular overlay shown at the drag contact
  /// point while the user is adjusting the gauge value.
  ///
  /// Defaults to `Color(0x336750A4)` — 20 % opaque purple.
  final Color dragOverlayColor;

  /// Radius of the drag overlay circle, in logical pixels.
  ///
  /// Defaults to `20.0`.
  final double dragOverlayRadius;

  // -------------------------------------------------------------------------
  // Animation
  // -------------------------------------------------------------------------

  /// Duration of the implicit value-change animation.
  ///
  /// Defaults to `Duration(milliseconds: 600)`.
  final Duration animationDuration;

  /// Easing curve applied to the implicit value-change animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  // -------------------------------------------------------------------------
  // Utilities
  // -------------------------------------------------------------------------

  /// Returns a copy of this token set with the given fields replaced.
  ///
  /// Only pass the fields you want to change; all others are preserved.
  GaugeTokens copyWith({
    Color? trackColor,
    double? trackStrokeWidth,
    StrokeCap? trackStrokeCap,
    double? trackBorderRadius,
    Color? valueColor,
    double? valueStrokeWidth,
    Gradient? valueGradient,
    double? valueGlowRadius,
    Color? valueGlowColor,
    Color? needleColor,
    double? needleWidth,
    NeedleTipStyle? needleTipStyle,
    bool? needleDropShadow,
    Color? knobColor,
    double? knobRadius,
    Color? knobBorderColor,
    double? knobBorderWidth,
    GaugeTickStyle? majorTick,
    GaugeTickStyle? minorTick,
    TextStyle? labelStyle,
    double? labelOffset,
    Color? zoneNormal,
    Color? zoneWarning,
    Color? zoneDanger,
    TextStyle? annotationTextStyle,
    Color? dragOverlayColor,
    double? dragOverlayRadius,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return GaugeTokens(
      trackColor: trackColor ?? this.trackColor,
      trackStrokeWidth: trackStrokeWidth ?? this.trackStrokeWidth,
      trackStrokeCap: trackStrokeCap ?? this.trackStrokeCap,
      trackBorderRadius: trackBorderRadius ?? this.trackBorderRadius,
      valueColor: valueColor ?? this.valueColor,
      valueStrokeWidth: valueStrokeWidth ?? this.valueStrokeWidth,
      valueGradient: valueGradient ?? this.valueGradient,
      valueGlowRadius: valueGlowRadius ?? this.valueGlowRadius,
      valueGlowColor: valueGlowColor ?? this.valueGlowColor,
      needleColor: needleColor ?? this.needleColor,
      needleWidth: needleWidth ?? this.needleWidth,
      needleTipStyle: needleTipStyle ?? this.needleTipStyle,
      needleDropShadow: needleDropShadow ?? this.needleDropShadow,
      knobColor: knobColor ?? this.knobColor,
      knobRadius: knobRadius ?? this.knobRadius,
      knobBorderColor: knobBorderColor ?? this.knobBorderColor,
      knobBorderWidth: knobBorderWidth ?? this.knobBorderWidth,
      majorTick: majorTick ?? this.majorTick,
      minorTick: minorTick ?? this.minorTick,
      labelStyle: labelStyle ?? this.labelStyle,
      labelOffset: labelOffset ?? this.labelOffset,
      zoneNormal: zoneNormal ?? this.zoneNormal,
      zoneWarning: zoneWarning ?? this.zoneWarning,
      zoneDanger: zoneDanger ?? this.zoneDanger,
      annotationTextStyle: annotationTextStyle ?? this.annotationTextStyle,
      dragOverlayColor: dragOverlayColor ?? this.dragOverlayColor,
      dragOverlayRadius: dragOverlayRadius ?? this.dragOverlayRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  /// Linearly interpolates between two [GaugeTokens] instances.
  ///
  /// Discrete (non-numeric) properties snap at `t == 0.5`.
  static GaugeTokens lerp(GaugeTokens a, GaugeTokens b, double t) {
    return GaugeTokens(
      trackColor: Color.lerp(a.trackColor, b.trackColor, t)!,
      trackStrokeWidth: _lerpDouble(a.trackStrokeWidth, b.trackStrokeWidth, t),
      trackStrokeCap: t < 0.5 ? a.trackStrokeCap : b.trackStrokeCap,
      trackBorderRadius:
          _lerpDouble(a.trackBorderRadius, b.trackBorderRadius, t),
      valueColor: Color.lerp(a.valueColor, b.valueColor, t)!,
      valueStrokeWidth: _lerpDouble(a.valueStrokeWidth, b.valueStrokeWidth, t),
      valueGradient: t < 0.5 ? a.valueGradient : b.valueGradient,
      valueGlowRadius: _lerpDouble(a.valueGlowRadius, b.valueGlowRadius, t),
      valueGlowColor: Color.lerp(a.valueGlowColor, b.valueGlowColor, t),
      needleColor: Color.lerp(a.needleColor, b.needleColor, t)!,
      needleWidth: _lerpDouble(a.needleWidth, b.needleWidth, t),
      needleTipStyle: t < 0.5 ? a.needleTipStyle : b.needleTipStyle,
      needleDropShadow: t < 0.5 ? a.needleDropShadow : b.needleDropShadow,
      knobColor: Color.lerp(a.knobColor, b.knobColor, t)!,
      knobRadius: _lerpDouble(a.knobRadius, b.knobRadius, t),
      knobBorderColor: Color.lerp(a.knobBorderColor, b.knobBorderColor, t),
      knobBorderWidth: _lerpDouble(a.knobBorderWidth, b.knobBorderWidth, t),
      majorTick: GaugeTickStyle.lerp(a.majorTick, b.majorTick, t),
      minorTick: GaugeTickStyle.lerp(a.minorTick, b.minorTick, t),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t)!,
      labelOffset: _lerpDouble(a.labelOffset, b.labelOffset, t),
      zoneNormal: Color.lerp(a.zoneNormal, b.zoneNormal, t)!,
      zoneWarning: Color.lerp(a.zoneWarning, b.zoneWarning, t)!,
      zoneDanger: Color.lerp(a.zoneDanger, b.zoneDanger, t)!,
      annotationTextStyle:
          TextStyle.lerp(a.annotationTextStyle, b.annotationTextStyle, t)!,
      dragOverlayColor: Color.lerp(a.dragOverlayColor, b.dragOverlayColor, t)!,
      dragOverlayRadius:
          _lerpDouble(a.dragOverlayRadius, b.dragOverlayRadius, t),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      animationCurve: t < 0.5 ? a.animationCurve : b.animationCurve,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Shape drawn at the tip of the gauge needle.
enum NeedleTipStyle {
  /// Pointed tip — the default for most gauge styles.
  sharp,

  /// Flat (blunt) end — common in speedometers and heavy-industrial designs.
  flat,

  /// Circular blob at the tip.
  circle,
}

/// Extended token set for the ArtificialHorizonGauge.
///
/// Inherits all [GaugeTokens] defaults and adds horizon-specific colours.
class HorizonGaugeTokens extends GaugeTokens {
  /// Creates horizon gauge tokens.
  ///
  /// All [GaugeTokens] parameters are optional and inherit the same defaults.
  /// The horizon-specific parameters ([skyColor], [groundColor], etc.) are
  /// required because there is no universally sensible default for them.
  const HorizonGaugeTokens({
    super.trackColor,
    super.trackStrokeWidth,
    super.trackStrokeCap,
    super.trackBorderRadius,
    super.valueColor,
    super.valueStrokeWidth,
    super.valueGradient,
    super.valueGlowRadius,
    super.valueGlowColor,
    super.needleColor,
    super.needleWidth,
    super.needleTipStyle,
    super.needleDropShadow,
    super.knobColor,
    super.knobRadius,
    super.knobBorderColor,
    super.knobBorderWidth,
    super.majorTick,
    super.minorTick,
    super.labelStyle,
    super.labelOffset,
    super.zoneNormal,
    super.zoneWarning,
    super.zoneDanger,
    super.annotationTextStyle,
    super.dragOverlayColor,
    super.dragOverlayRadius,
    super.animationDuration,
    super.animationCurve,
    required this.skyColor,
    required this.groundColor,
    required this.horizonLineColor,
    required this.horizonLineWidth,
    required this.aircraftSymbolColor,
    required this.pitchLadderColor,
    required this.rollArcColor,
  });

  /// Colour filling the sky (upper) half of the artificial horizon.
  final Color skyColor;

  /// Colour filling the ground (lower) half of the artificial horizon.
  final Color groundColor;

  /// Colour of the line that separates sky from ground.
  final Color horizonLineColor;

  /// Stroke width of the horizon dividing line, in logical pixels.
  final double horizonLineWidth;

  /// Colour of the fixed aircraft symbol overlay.
  final Color aircraftSymbolColor;

  /// Colour of the pitch-ladder lines and labels.
  final Color pitchLadderColor;

  /// Colour of the roll-angle arc drawn around the horizon bezel.
  final Color rollArcColor;
}
