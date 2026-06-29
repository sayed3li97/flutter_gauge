import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/odometer_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A rolling-digit odometer display.
class OdometerGauge extends LeafRenderObjectWidget {
  const OdometerGauge({
    super.key,
    required this.controller,
    this.digitCount = 6,
    this.decimalDigits = 1,
    this.unit,
    this.style,
    this.mode,
  });

  /// Mileage / distance preset.
  factory OdometerGauge.mileage({
    Key? key,
    required GaugeController controller,
    String unit = 'km',
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return OdometerGauge(
      key: key,
      controller: controller,
      digitCount: 6,
      decimalDigits: 1,
      unit: unit,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final int digitCount;
  final int decimalDigits;
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
  OdometerGaugeRenderBox createRenderObject(BuildContext context) {
    return OdometerGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      digitCount: digitCount,
      decimalDigits: decimalDigits,
      unit: unit,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, OdometerGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..digitCount = digitCount
      ..decimalDigits = decimalDigits
      ..unit = unit;
  }
}
