import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/segmented_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A discrete LED-segment gauge.
class SegmentedGauge extends LeafRenderObjectWidget {
  const SegmentedGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 100,
    this.segmentCount = 20,
    this.horizontal = true,
    this.gap = 2,
    this.style,
    this.mode,
  });

  /// Signal-strength preset (5 bars).
  factory SegmentedGauge.signalStrength({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return SegmentedGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      segmentCount: 5,
      horizontal: true,
      gap: 3,
      style: style,
      mode: mode,
    );
  }

  /// Battery level preset (10 segments).
  factory SegmentedGauge.battery({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return SegmentedGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      segmentCount: 10,
      horizontal: true,
      gap: 2,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double min;
  final double max;
  final int segmentCount;
  final bool horizontal;
  final double gap;
  final GaugeStyle? style;
  final GaugeMode? mode;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  SegmentedGaugeRenderBox createRenderObject(BuildContext context) {
    return SegmentedGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      segmentCount: segmentCount,
      horizontal: horizontal,
      gap: gap,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, SegmentedGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..segmentCount = segmentCount
      ..min = min
      ..max = max;
  }
}
