import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/inclinometer_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A spirit-level / inclinometer gauge. [controller.value] is tilt in degrees.
class InclinometerGauge extends LeafRenderObjectWidget {
  const InclinometerGauge({
    super.key,
    required this.controller,
    this.maxAngle = 45,
    this.style,
    this.mode,
    this.semanticsLabel,
  });

  final GaugeController controller;
  final double maxAngle;
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
  InclinometerGaugeRenderBox createRenderObject(BuildContext context) {
    return InclinometerGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      maxAngle: maxAngle,
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, InclinometerGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..maxAngle = maxAngle
      ..semanticsLabel = semanticsLabel;
  }
}
