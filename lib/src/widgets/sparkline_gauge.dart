import 'package:flutter/material.dart';

import '../core/gauge_mode.dart';
import '../core/sparkline_controller.dart';
import '../engine/sparkline_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A compact trend-line gauge showing a rolling window of sample history.
///
/// Unlike the other gauges, which render a single live [GaugeController]
/// value, [SparklineGauge] is driven by a [SparklineController] and plots
/// its recent sample history as a line — the shape a "sparkline" takes in
/// a dashboard next to a big live number.
///
/// ```dart
/// final trend = SparklineController(capacity: 30);
/// Timer.periodic(const Duration(seconds: 1), (_) {
///   trend.addSample(currentCpuLoad());
/// });
///
/// SizedBox(
///   width: 120,
///   height: 32,
///   child: SparklineGauge(controller: trend),
/// )
/// ```
class SparklineGauge extends LeafRenderObjectWidget {
  const SparklineGauge({
    super.key,
    required this.controller,
    this.min,
    this.max,
    this.lineWidth = 2.0,
    this.showFill = true,
    this.showLastPointMarker = true,
    this.markerRadius = 3.0,
    this.style,
    this.mode,
    this.semanticsLabel,
  });

  /// Supplies the rolling sample history to plot.
  final SparklineController controller;

  /// Lower bound of the y-axis. When `null`, auto-scales to the minimum of
  /// the current sample window.
  final double? min;

  /// Upper bound of the y-axis. When `null`, auto-scales to the maximum of
  /// the current sample window.
  final double? max;

  /// Stroke width of the trend line in logical pixels.
  final double lineWidth;

  /// Whether to fill the area under the trend line.
  final bool showFill;

  /// Whether to draw a marker dot at the most recent sample.
  final bool showLastPointMarker;

  /// Radius of the last-point marker, in logical pixels.
  final double markerRadius;

  /// Visual style; falls back to the ambient [GaugeThemeExtension].
  final GaugeStyle? style;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  /// Accessibility label for screen readers.
  final String? semanticsLabel;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  SparklineGaugeRenderBox createRenderObject(BuildContext context) {
    return SparklineGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      lineWidth: lineWidth,
      showFill: showFill,
      showLastPointMarker: showLastPointMarker,
      markerRadius: markerRadius,
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, SparklineGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..min = min
      ..max = max
      ..lineWidth = lineWidth
      ..showFill = showFill
      ..showLastPointMarker = showLastPointMarker
      ..markerRadius = markerRadius
      ..semanticsLabel = semanticsLabel;
  }
}
