import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../engine/level_meter_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A vertical level meter (VU meter / audio level).
class LevelMeterGauge extends LeafRenderObjectWidget {
  const LevelMeterGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 100,
    this.channelCount = 2,
    this.gap = 4,
    this.style,
    this.mode,
    this.semanticsLabel,
  });

  /// Stereo VU meter preset.
  factory LevelMeterGauge.stereo({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return LevelMeterGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      channelCount: 2,
      gap: 4,
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double min;
  final double max;
  final int channelCount;
  final double gap;
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
  LevelMeterGaugeRenderBox createRenderObject(BuildContext context) {
    return LevelMeterGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      channelCount: channelCount,
      gap: gap,
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, LevelMeterGaugeRenderBox renderObject) {
    renderObject
      ..tokens = _resolve(context)
      ..channelCount = channelCount
      ..min = min
      ..max = max
      ..semanticsLabel = semanticsLabel;
  }
}
