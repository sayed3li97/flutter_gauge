import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../core/gauge_tick_style.dart';

/// Immutable set of resolved design tokens consumed by every render engine.
/// The engine has zero knowledge of where these values came from.
class GaugeTokens {
  const GaugeTokens({
    required this.trackColor,
    required this.trackStrokeWidth,
    required this.trackStrokeCap,
    required this.trackBorderRadius,
    required this.valueColor,
    required this.valueStrokeWidth,
    this.valueGradient,
    required this.needleColor,
    required this.needleWidth,
    required this.needleTipStyle,
    required this.needleDropShadow,
    required this.knobColor,
    required this.knobRadius,
    this.knobBorderColor,
    required this.knobBorderWidth,
    required this.majorTick,
    required this.minorTick,
    required this.labelStyle,
    required this.labelOffset,
    required this.zoneNormal,
    required this.zoneWarning,
    required this.zoneDanger,
    required this.annotationTextStyle,
    required this.dragOverlayColor,
    required this.dragOverlayRadius,
    required this.animationDuration,
    required this.animationCurve,
  });

  final Color trackColor;
  final double trackStrokeWidth;
  final StrokeCap trackStrokeCap;
  final double trackBorderRadius;

  final Color valueColor;
  final double valueStrokeWidth;
  final Gradient? valueGradient;

  final Color needleColor;
  final double needleWidth;
  final NeedleTipStyle needleTipStyle;
  final bool needleDropShadow;

  final Color knobColor;
  final double knobRadius;
  final Color? knobBorderColor;
  final double knobBorderWidth;

  final GaugeTickStyle majorTick;
  final GaugeTickStyle minorTick;

  final TextStyle labelStyle;
  final double labelOffset;

  final Color zoneNormal;
  final Color zoneWarning;
  final Color zoneDanger;

  final TextStyle annotationTextStyle;
  final Color dragOverlayColor;
  final double dragOverlayRadius;

  final Duration animationDuration;
  final Curve animationCurve;

  GaugeTokens copyWith({
    Color? trackColor,
    double? trackStrokeWidth,
    StrokeCap? trackStrokeCap,
    double? trackBorderRadius,
    Color? valueColor,
    double? valueStrokeWidth,
    Gradient? valueGradient,
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
      dragOverlayColor:
          Color.lerp(a.dragOverlayColor, b.dragOverlayColor, t)!,
      dragOverlayRadius:
          _lerpDouble(a.dragOverlayRadius, b.dragOverlayRadius, t),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      animationCurve: t < 0.5 ? a.animationCurve : b.animationCurve,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Style of the needle tip.
enum NeedleTipStyle {
  /// Pointed (default for most gauges).
  sharp,

  /// Flat end — used in speedometers and heavy-industrial styles.
  flat,

  /// Circular blob at the tip.
  circle,
}

/// Extended token set for the ArtificialHorizonGauge.
class HorizonGaugeTokens extends GaugeTokens {
  const HorizonGaugeTokens({
    required super.trackColor,
    required super.trackStrokeWidth,
    required super.trackStrokeCap,
    required super.trackBorderRadius,
    required super.valueColor,
    required super.valueStrokeWidth,
    super.valueGradient,
    required super.needleColor,
    required super.needleWidth,
    required super.needleTipStyle,
    required super.needleDropShadow,
    required super.knobColor,
    required super.knobRadius,
    super.knobBorderColor,
    required super.knobBorderWidth,
    required super.majorTick,
    required super.minorTick,
    required super.labelStyle,
    required super.labelOffset,
    required super.zoneNormal,
    required super.zoneWarning,
    required super.zoneDanger,
    required super.annotationTextStyle,
    required super.dragOverlayColor,
    required super.dragOverlayRadius,
    required super.animationDuration,
    required super.animationCurve,
    required this.skyColor,
    required this.groundColor,
    required this.horizonLineColor,
    required this.horizonLineWidth,
    required this.aircraftSymbolColor,
    required this.pitchLadderColor,
    required this.rollArcColor,
  });

  final Color skyColor;
  final Color groundColor;
  final Color horizonLineColor;
  final double horizonLineWidth;
  final Color aircraftSymbolColor;
  final Color pitchLadderColor;
  final Color rollArcColor;
}
