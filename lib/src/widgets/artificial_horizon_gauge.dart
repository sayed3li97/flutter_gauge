import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/horizon_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// An artificial horizon / attitude indicator for avionics UIs.
/// Uses two controllers: [pitchController] (degrees up/down) and
/// [rollController] (degrees left/right).
class ArtificialHorizonGauge extends LeafRenderObjectWidget {
  const ArtificialHorizonGauge({
    super.key,
    required this.pitchController,
    required this.rollController,
    this.style,
    this.mode,
    this.semanticsLabel,
  });

  final GaugeController pitchController;
  final GaugeController rollController;
  final GaugeStyle? style;
  final GaugeMode? mode;
  final String? semanticsLabel;

  HorizonGaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    final base = resolvedStyle.resolve(context, resolvedMode);
    return HorizonGaugeTokens(
      trackColor: base.trackColor,
      trackStrokeWidth: base.trackStrokeWidth,
      trackStrokeCap: base.trackStrokeCap,
      trackBorderRadius: base.trackBorderRadius,
      valueColor: base.valueColor,
      valueStrokeWidth: base.valueStrokeWidth,
      needleColor: base.needleColor,
      needleWidth: base.needleWidth,
      needleTipStyle: base.needleTipStyle,
      needleDropShadow: base.needleDropShadow,
      knobColor: base.knobColor,
      knobRadius: base.knobRadius,
      knobBorderColor: base.knobBorderColor,
      knobBorderWidth: base.knobBorderWidth,
      majorTick: base.majorTick,
      minorTick: base.minorTick,
      labelStyle: base.labelStyle,
      labelOffset: base.labelOffset,
      zoneNormal: base.zoneNormal,
      zoneWarning: base.zoneWarning,
      zoneDanger: base.zoneDanger,
      annotationTextStyle: base.annotationTextStyle,
      dragOverlayColor: base.dragOverlayColor,
      dragOverlayRadius: base.dragOverlayRadius,
      animationDuration: base.animationDuration,
      animationCurve: base.animationCurve,
      skyColor: const Color(0xFF1565C0),
      groundColor: const Color(0xFF6D4C41),
      horizonLineColor: const Color(0xFFFFFFFF),
      horizonLineWidth: 2,
      aircraftSymbolColor: const Color(0xFFFFEB3B),
      pitchLadderColor: const Color(0xFFFFFFFF),
      rollArcColor: const Color(0xFFFFFFFF),
    );
  }

  @override
  HorizonGaugeRenderBox createRenderObject(BuildContext context) {
    return HorizonGaugeRenderBox(
      pitchController: pitchController,
      rollController: rollController,
      tokens: _resolve(context),
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, HorizonGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..semanticsLabel = semanticsLabel;
  }
}
