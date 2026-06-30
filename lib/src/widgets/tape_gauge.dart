import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/tape_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A scrolling tape gauge (altimeter / airspeed indicator style).
class TapeGauge extends LeafRenderObjectWidget {
  const TapeGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 1000,
    this.tickInterval = 10,
    this.unit,
    this.vertical = true,
    this.style,
    this.mode,
    this.semanticsLabel,
  });

  /// Altimeter preset (0–10000 ft).
  factory TapeGauge.altimeter({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return TapeGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 10000,
      tickInterval: 100,
      unit: 'ft',
      vertical: true,
      style: style,
      mode: mode,
    );
  }

  /// Airspeed indicator preset (0–300 kts).
  factory TapeGauge.airspeed({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return TapeGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 300,
      tickInterval: 10,
      unit: 'kts',
      vertical: true,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double min;
  final double max;
  final double tickInterval;
  final String? unit;
  final bool vertical;
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
  TapeGaugeRenderBox createRenderObject(BuildContext context) {
    return TapeGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      tickInterval: tickInterval,
      unit: unit,
      vertical: vertical,
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, TapeGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..min = min
      ..max = max
      ..tickInterval = tickInterval
      ..semanticsLabel = semanticsLabel;
  }
}
