import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/tank_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A liquid-tank fill gauge.
class TankGauge extends LeafRenderObjectWidget {
  const TankGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 100,
    this.vertical = true,
    this.showWave = false,
    this.style,
    this.mode,
  });

  /// Water level preset.
  factory TankGauge.water({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return TankGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      vertical: true,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double min;
  final double max;
  final bool vertical;
  final bool showWave;
  final GaugeStyle? style;
  final GaugeMode? mode;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  TankGaugeRenderBox createRenderObject(BuildContext context) {
    return TankGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      vertical: vertical,
      showWave: showWave,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, TankGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..min = min
      ..max = max;
  }
}
