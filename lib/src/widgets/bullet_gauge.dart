import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/bullet_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A Stephen Few-style bullet chart.
class BulletGauge extends LeafRenderObjectWidget {
  const BulletGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 100,
    this.targetValue,
    this.poorThreshold = 30,
    this.satisfactoryThreshold = 70,
    this.label,
    this.style,
    this.mode,
    this.semanticsLabel,
  });

  /// KPI preset: target line at 80% of max.
  factory BulletGauge.kpi({
    Key? key,
    required GaugeController controller,
    double max = 100,
    String? label,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return BulletGauge(
      key: key,
      controller: controller,
      min: 0,
      max: max,
      targetValue: max * 0.8,
      poorThreshold: max * 0.4,
      satisfactoryThreshold: max * 0.7,
      label: label,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double min;
  final double max;
  final double? targetValue;
  final double poorThreshold;
  final double satisfactoryThreshold;
  final String? label;
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
  BulletGaugeRenderBox createRenderObject(BuildContext context) {
    return BulletGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      targetValue: targetValue,
      poorThreshold: poorThreshold,
      satisfactoryThreshold: satisfactoryThreshold,
      label: label,
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, BulletGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..targetValue = targetValue
      ..min = min
      ..max = max
      ..semanticsLabel = semanticsLabel;
  }
}
