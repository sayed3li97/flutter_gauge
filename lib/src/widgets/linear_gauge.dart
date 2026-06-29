import 'package:flutter/widgets.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../core/gauge_range.dart';
import '../engine/linear_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A horizontal or vertical linear progress gauge.
class LinearGauge extends LeafRenderObjectWidget {
  const LinearGauge({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 100,
    this.orientation = LinearGaugeOrientation.horizontal,
    this.ranges = const [],
    this.majorDivisions = 5,
    this.showLabels = true,
    this.showTicks = true,
    this.style,
    this.mode,
  });

  /// Horizontal progress bar preset.
  factory LinearGauge.progress({
    Key? key,
    required GaugeController controller,
    double min = 0,
    double max = 100,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return LinearGauge(
      key: key,
      controller: controller,
      min: min,
      max: max,
      showLabels: false,
      showTicks: false,
      majorDivisions: 0,
      style: style,
      mode: mode,
    );
  }

  /// Volume slider preset (horizontal with ticks).
  factory LinearGauge.volume({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
  }) {
    return LinearGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      majorDivisions: 10,
      ranges: [
        GaugeRange(min: 80, max: 100, color: const Color(0xFFEE7733)),
      ],
      style: style,
      mode: mode,
    );
  }

  final GaugeController controller;
  final double min;
  final double max;
  final LinearGaugeOrientation orientation;
  final List<GaugeRange> ranges;
  final int majorDivisions;
  final bool showLabels;
  final bool showTicks;
  final GaugeStyle? style;
  final GaugeMode? mode;

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  LinearGaugeRenderBox createRenderObject(BuildContext context) {
    return LinearGaugeRenderBox(
      controller: controller,
      tokens: _resolve(context),
      min: min,
      max: max,
      orientation: orientation,
      ranges: ranges,
      majorDivisions: majorDivisions,
      showLabels: showLabels,
      showTicks: showTicks,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, LinearGaugeRenderBox renderObject) {
    final tokens = _resolve(context);
    renderObject
      ..tokens = tokens
      ..min = min
      ..max = max
      ..orientation = orientation
      ..ranges = ranges
      ..majorDivisions = majorDivisions
      ..showLabels = showLabels
      ..showTicks = showTicks;
  }
}
