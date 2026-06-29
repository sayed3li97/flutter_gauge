import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/delta_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A delta / change-from-baseline gauge.
class DeltaGauge extends LeafRenderObjectWidget {
  const DeltaGauge({
    super.key,
    required this.controller,
    this.baseline = 0,
    this.min = -100,
    this.max = 100,
    this.unit,
    this.style,
    this.mode,
  });

  final GaugeController controller;
  final double baseline;
  final double min;
  final double max;
  final String? unit;
  final GaugeStyle? style;
  final GaugeMode? mode;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  DeltaGaugeRenderBox createRenderObject(BuildContext context) {
    return DeltaGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      baseline: baseline,
      min: min,
      max: max,
      unit: unit,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, DeltaGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..baseline = baseline
      ..min = min
      ..max = max;
  }
}
