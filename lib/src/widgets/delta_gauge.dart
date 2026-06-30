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
    this.lowerIsBetter = false,
  });

  final GaugeController controller;
  final double baseline;
  final double min;
  final double max;
  final String? unit;
  final GaugeStyle? style;
  final GaugeMode? mode;

  /// Whether a lower value represents an improvement over the baseline.
  ///
  /// Set to `true` for metrics where smaller is better, such as loss
  /// functions, error rates, latency, or defect counts. When `true`, a
  /// negative delta is coloured with [GaugeTokens.zoneNormal] (good) and a
  /// positive delta with [GaugeTokens.zoneDanger] (bad). The default value
  /// of `false` is appropriate for metrics where higher is better, such as
  /// accuracy, throughput, or scores.
  final bool lowerIsBetter;

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
      lowerIsBetter: lowerIsBetter,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, DeltaGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..baseline = baseline
      ..min = min
      ..max = max
      ..lowerIsBetter = lowerIsBetter;
  }
}
