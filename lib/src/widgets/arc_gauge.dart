import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../core/gauge_range.dart';
import '../engine/arc_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A partial-arc progress gauge with an optional center label.
class ArcGauge extends LeafRenderObjectWidget {
  const ArcGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 100,
    this.startAngleDeg = 135,
    this.sweepAngleDeg = 270,
    this.centerLabel,
    this.centerLabelStyle,
    this.ranges = const [],
    this.style,
    this.mode,
    this.semanticsLabel,
  });

  /// Download/upload speed preset (0–100 Mbps).
  factory ArcGauge.networkSpeed({
    Key? key,
    required GaugeController controller,
    double maxMbps = 100,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return ArcGauge(
      key: key,
      controller: controller,
      min: 0,
      max: maxMbps,
      centerLabel: null,
      style: style,
      mode: mode,
    );
  }

  /// CPU usage preset (0–100%).
  factory ArcGauge.cpuUsage({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return ArcGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      startAngleDeg: 150,
      sweepAngleDeg: 240,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double min;
  final double max;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final String? centerLabel;
  final TextStyle? centerLabelStyle;
  final List<GaugeRange> ranges;
  final GaugeStyle? style;
  final GaugeMode? mode;
  final String? semanticsLabel;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  ArcGaugeRenderBox createRenderObject(BuildContext context) {
    return ArcGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      startAngleDeg: startAngleDeg,
      sweepAngleDeg: sweepAngleDeg,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      ranges: ranges,
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(BuildContext context, ArcGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..centerLabel = centerLabel
      ..ranges = ranges
      ..min = min
      ..max = max
      ..semanticsLabel = semanticsLabel;
  }
}
