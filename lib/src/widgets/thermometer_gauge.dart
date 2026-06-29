import 'package:flutter/widgets.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../core/unit_converter.dart';
import '../engine/thermometer_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A classic thermometer gauge. [controller.value] is in Celsius.
class ThermometerGauge extends LeafRenderObjectWidget {
  const ThermometerGauge({
    super.key,
    required this.controller,
    this.minCelsius = -20,
    this.maxCelsius = 50,
    this.scale = TemperatureScale.celsius,
    this.showScale = true,
    this.style,
    this.mode,
  });

  /// Oven / industrial temperature preset.
  factory ThermometerGauge.oven({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return ThermometerGauge(
      key: key,
      controller: controller,
      minCelsius: 0,
      maxCelsius: 300,
      scale: TemperatureScale.celsius,
      style: style,
      mode: mode,
    );
  }

  /// Body temperature preset (35–42°C).
  factory ThermometerGauge.bodyTemp({
    Key? key,
    required GaugeController controller,
    TemperatureScale scale = TemperatureScale.celsius,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return ThermometerGauge(
      key: key,
      controller: controller,
      minCelsius: 35,
      maxCelsius: 42,
      scale: scale,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double minCelsius;
  final double maxCelsius;
  final TemperatureScale scale;
  final bool showScale;
  final GaugeStyle? style;
  final GaugeMode? mode;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  ThermometerGaugeRenderBox createRenderObject(BuildContext context) {
    return ThermometerGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      minCelsius: minCelsius,
      maxCelsius: maxCelsius,
      scale: scale,
      showScale: showScale,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, ThermometerGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..scale = scale;
  }
}
