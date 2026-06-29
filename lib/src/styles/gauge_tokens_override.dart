import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../core/gauge_tick_style.dart';
import 'gauge_tokens.dart';

/// Partial override applied on top of a resolved [GaugeTokens].
class GaugeTokensOverride {
  const GaugeTokensOverride({
    this.trackColor,
    this.trackStrokeWidth,
    this.trackStrokeCap,
    this.trackBorderRadius,
    this.valueColor,
    this.valueStrokeWidth,
    this.valueGradient,
    this.needleColor,
    this.needleWidth,
    this.needleTipStyle,
    this.needleDropShadow,
    this.knobColor,
    this.knobRadius,
    this.knobBorderColor,
    this.knobBorderWidth,
    this.majorTick,
    this.minorTick,
    this.labelStyle,
    this.labelOffset,
    this.zoneNormal,
    this.zoneWarning,
    this.zoneDanger,
    this.annotationTextStyle,
    this.dragOverlayColor,
    this.dragOverlayRadius,
    this.animationDuration,
    this.animationCurve,
  });

  final Color? trackColor;
  final double? trackStrokeWidth;
  final StrokeCap? trackStrokeCap;
  final double? trackBorderRadius;
  final Color? valueColor;
  final double? valueStrokeWidth;
  final Gradient? valueGradient;
  final Color? needleColor;
  final double? needleWidth;
  final NeedleTipStyle? needleTipStyle;
  final bool? needleDropShadow;
  final Color? knobColor;
  final double? knobRadius;
  final Color? knobBorderColor;
  final double? knobBorderWidth;
  final GaugeTickStyle? majorTick;
  final GaugeTickStyle? minorTick;
  final TextStyle? labelStyle;
  final double? labelOffset;
  final Color? zoneNormal;
  final Color? zoneWarning;
  final Color? zoneDanger;
  final TextStyle? annotationTextStyle;
  final Color? dragOverlayColor;
  final double? dragOverlayRadius;
  final Duration? animationDuration;
  final Curve? animationCurve;

  GaugeTokens apply(GaugeTokens base) => base.copyWith(
        trackColor: trackColor,
        trackStrokeWidth: trackStrokeWidth,
        trackStrokeCap: trackStrokeCap,
        trackBorderRadius: trackBorderRadius,
        valueColor: valueColor,
        valueStrokeWidth: valueStrokeWidth,
        valueGradient: valueGradient,
        needleColor: needleColor,
        needleWidth: needleWidth,
        needleTipStyle: needleTipStyle,
        needleDropShadow: needleDropShadow,
        knobColor: knobColor,
        knobRadius: knobRadius,
        knobBorderColor: knobBorderColor,
        knobBorderWidth: knobBorderWidth,
        majorTick: majorTick,
        minorTick: minorTick,
        labelStyle: labelStyle,
        labelOffset: labelOffset,
        zoneNormal: zoneNormal,
        zoneWarning: zoneWarning,
        zoneDanger: zoneDanger,
        annotationTextStyle: annotationTextStyle,
        dragOverlayColor: dragOverlayColor,
        dragOverlayRadius: dragOverlayRadius,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
      );
}
