import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_value_host.dart';
import '../core/gauge_mode.dart';
import '../core/gauge_range.dart';
import '../engine/linear_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

export '../engine/linear_render.dart' show LinearGaugeOrientation;

/// A horizontal or vertical linear progress gauge with overlay and layout
/// support.
///
/// Add [leading] / [trailing] widgets to the ends of the bar, a [center]
/// overlay, or a [widgetIndicator] that tracks the live bar tip. Use [reverse]
/// to fill from the far end, [showValue] to display the value at the tip, and
/// [labelFormatter] for custom tick-label text.
///
/// Pass a plain [value] for a static or simply-bound bar (no controller, no
/// `dispose()`, animates on change), or a [controller] for full control:
///
/// ```dart
/// LinearGauge(value: 0.7 * 100, showValue: true)   // value-only
///
/// LinearGauge(
///   controller: downloadCtrl,                       // controller-driven
///   max: 100,
///   unitText: 'MB/s',
///   showValue: true,
///   barRadius: 6,
///   trailing: const Icon(Icons.download),
/// )
/// ```
///
/// Provide exactly one of [controller] or [value].
class LinearGauge extends StatelessWidget {
  const LinearGauge({
    super.key,
    this.controller,
    this.value,
    this.min = 0,
    this.max = 100,
    this.orientation = LinearGaugeOrientation.horizontal,
    this.ranges = const [],
    this.majorDivisions = 5,
    this.showLabels = true,
    this.showTicks = true,
    this.style,
    this.mode,
    this.semanticsLabel,
    this.leading,
    this.trailing,
    this.center,
    this.widgetIndicator,
    this.reverse = false,
    this.showValue = false,
    this.unitText,
    this.labelFormatter,
    this.barRadius,
  }) : assert(
          (controller == null) != (value == null),
          'LinearGauge requires exactly one of controller or value.',
        );

  /// Horizontal progress bar — no ticks or labels.
  factory LinearGauge.progress({
    Key? key,
    required GaugeController controller,
    double min = 0,
    double max = 100,
    GaugeStyle? style,
    GaugeMode? mode,
    Widget? leading,
    Widget? trailing,
    Widget? center,
    Widget? widgetIndicator,
    bool reverse = false,
    bool showValue = false,
    String? unitText,
    double? barRadius,
    String? semanticsLabel,
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
      leading: leading,
      trailing: trailing,
      center: center,
      widgetIndicator: widgetIndicator,
      reverse: reverse,
      showValue: showValue,
      unitText: unitText,
      barRadius: barRadius,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Volume slider preset (horizontal with coloured danger zone).
  factory LinearGauge.volume({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
    Widget? leading,
    Widget? trailing,
    String? semanticsLabel,
  }) {
    return LinearGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      majorDivisions: 10,
      ranges: [
        const GaugeRange(min: 80, max: 100, color: Color(0xFFEE7733)),
      ],
      style: style,
      mode: mode,
      leading: leading,
      trailing: trailing,
      semanticsLabel: semanticsLabel,
    );
  }

  // ─── Core params ────────────────────────────────────────────────────────────

  /// Drives the bar value. Provide this **or** [value], not both. Use a
  /// controller for imperative animation, interaction, or a shared value.
  final GaugeController? controller;

  /// A plain value to display. Provide this **or** [controller], not both.
  /// When set, the gauge manages its own controller internally (no `dispose()`
  /// needed) and animates whenever [value] changes.
  final double? value;

  final double min;
  final double max;
  final LinearGaugeOrientation orientation;
  final List<GaugeRange> ranges;
  final int majorDivisions;
  final bool showLabels;
  final bool showTicks;
  final GaugeStyle? style;
  final GaugeMode? mode;
  final String? semanticsLabel;

  // ─── New layout / customisation params ──────────────────────────────────────

  /// Widget shown before the bar (left on horizontal, top on vertical).
  final Widget? leading;

  /// Widget shown after the bar (right on horizontal, bottom on vertical).
  final Widget? trailing;

  /// Widget shown centred over the bar as a floating overlay.
  final Widget? center;

  /// Widget that tracks the current bar-tip position.
  final Widget? widgetIndicator;

  /// When `true`, fills the bar from the far end of the track.
  final bool reverse;

  /// When `true`, renders the current value above the bar tip on canvas.
  final bool showValue;

  /// Unit suffix appended to formatted values (e.g. `'%'`, `'°C'`).
  final String? unitText;

  /// Custom formatter for tick-mark labels.
  ///
  /// ```dart
  /// labelFormatter: (v) => '${v.toInt()}°',
  /// ```
  final String Function(double)? labelFormatter;

  /// Switches the bar to filled-RRect mode with this corner radius in logical
  /// pixels. When `null`, the default stroked-line mode is used.
  final double? barRadius;

  // ─── Internal ───────────────────────────────────────────────────────────────

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  bool get _isHorizontal => orientation == LinearGaugeOrientation.horizontal;

  @override
  Widget build(BuildContext context) {
    if (controller != null) return _buildWithController(context, controller!);
    // Value mode: host manages an internal controller (no dispose needed).
    return GaugeValueHost(value: value!, builder: _buildWithController);
  }

  Widget _buildWithController(
      BuildContext context, GaugeController controller) {
    final tokens = _resolve(context);
    final trackW = tokens.trackStrokeWidth;

    final leaf = _LinearGaugeLeaf(
      controller: controller,
      tokens: tokens,
      min: min,
      max: max,
      orientation: orientation,
      ranges: ranges,
      majorDivisions: majorDivisions,
      showLabels: showLabels,
      showTicks: showTicks,
      semanticsLabel: semanticsLabel,
      reverse: reverse,
      showValue: showValue,
      unitText: unitText,
      labelFormatter: labelFormatter,
      barRadius: barRadius,
    );

    Widget barArea = Stack(
      children: [
        leaf,
        if (center != null)
          Positioned.fill(
            child: Align(alignment: Alignment.center, child: center!),
          ),
        if (widgetIndicator != null)
          LayoutBuilder(builder: (ctx, constraints) {
            return ListenableBuilder(
              listenable: controller,
              builder: (ctx2, _) {
                final frac =
                    ((controller.value - min) / (max - min)).clamp(0.0, 1.0);
                if (_isHorizontal) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final left = trackW / 2 + 4;
                  final right = w - trackW / 2 - 4;
                  final trackLen = right - left;
                  final effectiveFrac = reverse ? 1.0 - frac : frac;
                  final x = left + effectiveFrac * trackLen;
                  final y = h / 2;
                  return Stack(
                    children: [
                      Positioned(
                        left: x,
                        top: y,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -0.5),
                          child: widgetIndicator!,
                        ),
                      ),
                    ],
                  );
                } else {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final top = trackW / 2 + 4;
                  final bottom = h - trackW / 2 - 4;
                  final trackLen = bottom - top;
                  final effectiveFrac = reverse ? 1.0 - frac : frac;
                  final y = top + effectiveFrac * trackLen;
                  final x = w / 2;
                  return Stack(
                    children: [
                      Positioned(
                        left: x,
                        top: y,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -0.5),
                          child: widgetIndicator!,
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          }),
      ],
    );

    if (leading == null && trailing == null) return barArea;

    if (_isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) leading!,
          Expanded(child: barArea),
          if (trailing != null) trailing!,
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) leading!,
          Expanded(child: barArea),
          if (trailing != null) trailing!,
        ],
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Private leaf — pure canvas rendering.
// ---------------------------------------------------------------------------

class _LinearGaugeLeaf extends LeafRenderObjectWidget {
  const _LinearGaugeLeaf({
    required this.controller,
    required this.tokens,
    required this.min,
    required this.max,
    required this.orientation,
    required this.ranges,
    required this.majorDivisions,
    required this.showLabels,
    required this.showTicks,
    required this.semanticsLabel,
    required this.reverse,
    required this.showValue,
    required this.unitText,
    required this.labelFormatter,
    required this.barRadius,
  });

  final GaugeController controller;
  final GaugeTokens tokens;
  final double min;
  final double max;
  final LinearGaugeOrientation orientation;
  final List<GaugeRange> ranges;
  final int majorDivisions;
  final bool showLabels;
  final bool showTicks;
  final String? semanticsLabel;
  final bool reverse;
  final bool showValue;
  final String? unitText;
  final String Function(double)? labelFormatter;
  final double? barRadius;

  @override
  LinearGaugeRenderBox createRenderObject(BuildContext context) {
    return LinearGaugeRenderBox(
      controller: controller,
      tokens: tokens,
      min: min,
      max: max,
      orientation: orientation,
      ranges: ranges,
      majorDivisions: majorDivisions,
      showLabels: showLabels,
      showTicks: showTicks,
      semanticsLabel: semanticsLabel,
      reverse: reverse,
      showValue: showValue,
      unitText: unitText,
      labelFormatter: labelFormatter,
      barRadius: barRadius,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, LinearGaugeRenderBox renderObject) {
    renderObject
      ..tokens = tokens
      ..min = min
      ..max = max
      ..orientation = orientation
      ..ranges = ranges
      ..majorDivisions = majorDivisions
      ..showLabels = showLabels
      ..showTicks = showTicks
      ..semanticsLabel = semanticsLabel
      ..reverse = reverse
      ..showValue = showValue
      ..unitText = unitText
      ..labelFormatter = labelFormatter
      ..barRadius = barRadius;
  }
}
