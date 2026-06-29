import 'package:flutter/widgets.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/status_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A simple status indicator. [controller.value]: 0=normal, 1=warning, 2=danger.
class StatusGauge extends LeafRenderObjectWidget {
  const StatusGauge({
    super.key,
    required this.controller,
    this.radius = 12,
    this.label,
    this.style,
    this.mode,
  });

  final GaugeController controller;
  final double radius;
  final String? label;
  final GaugeStyle? style;
  final GaugeMode? mode;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  StatusGaugeRenderBox createRenderObject(BuildContext context) {
    return StatusGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      radius: radius,
      label: label,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, StatusGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..radius = radius
      ..label = label;
  }
}
