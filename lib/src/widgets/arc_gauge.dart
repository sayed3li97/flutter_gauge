import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_mode.dart';
import '../core/gauge_range.dart';
import '../engine/arc_render.dart';
import '../styles/extensions/gauge_theme_extension.dart';
import '../styles/gauge_style.dart';
import '../styles/gauge_tokens.dart';

/// A partial-arc progress gauge with rich overlay and layout support.
///
/// Place a [child] widget at the centre, attach [header] / [footer] labels,
/// or use a [widgetIndicator] that moves with the arc tip. The [reverse] flag
/// fills the arc from the far end, [fillColor] colours the inner circle, and
/// [unitText] appends a unit suffix to the auto-formatted centre value.
///
/// ```dart
/// ArcGauge(
///   controller: cpuCtrl,
///   unitText: '%',
///   fillColor: Colors.black12,
///   header: const Text('CPU', style: TextStyle(fontWeight: FontWeight.bold)),
///   footer: const Text('utilisation'),
/// )
/// ```
class ArcGauge extends StatelessWidget {
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
    this.child,
    this.header,
    this.footer,
    this.fillColor,
    this.reverse = false,
    this.showValue = true,
    this.unitText,
    this.widgetIndicator,
    this.backgroundWidth,
  });

  /// Download/upload speed preset (0–[maxMbps] Mbps).
  factory ArcGauge.networkSpeed({
    Key? key,
    required GaugeController controller,
    double maxMbps = 100,
    GaugeStyle? style,
    GaugeMode? mode,
    Widget? child,
    Widget? header,
    Widget? footer,
    String? unitText,
    Widget? widgetIndicator,
    String? semanticsLabel,
  }) {
    return ArcGauge(
      key: key,
      controller: controller,
      min: 0,
      max: maxMbps,
      style: style,
      mode: mode,
      header: header,
      footer: footer,
      unitText: unitText ?? 'Mbps',
      widgetIndicator: widgetIndicator,
      semanticsLabel: semanticsLabel,
      child: child,
    );
  }

  /// CPU usage preset (0–100 %).
  factory ArcGauge.cpuUsage({
    Key? key,
    required GaugeController controller,
    GaugeStyle? style,
    GaugeMode? mode,
    Widget? child,
    Widget? header,
    Widget? footer,
    Widget? widgetIndicator,
    String? semanticsLabel,
  }) {
    return ArcGauge(
      key: key,
      controller: controller,
      min: 0,
      max: 100,
      startAngleDeg: 150,
      sweepAngleDeg: 240,
      unitText: '%',
      style: style,
      mode: mode,
      header: header,
      footer: footer,
      widgetIndicator: widgetIndicator,
      semanticsLabel: semanticsLabel,
      child: child,
    );
  }

  // ─── Core params ────────────────────────────────────────────────────────────
  final GaugeController controller;
  final double min;
  final double max;
  final double startAngleDeg;
  final double sweepAngleDeg;

  /// Overrides the auto-formatted centre value label.
  final String? centerLabel;

  /// Text style for the centre label.
  final TextStyle? centerLabelStyle;

  /// Coloured band segments drawn over the background track.
  final List<GaugeRange> ranges;

  /// Visual style. Falls back to [GaugeThemeExtension] then [DefaultGaugeStyle].
  final GaugeStyle? style;

  /// Ambient / instrument rendering mode.
  final GaugeMode? mode;

  /// Accessibility label announced by screen readers.
  final String? semanticsLabel;

  // ─── New overlay / layout params ────────────────────────────────────────────

  /// Widget shown at the centre of the gauge (replaces the canvas value label
  /// when provided).
  final Widget? child;

  /// Widget shown directly above the gauge.
  final Widget? header;

  /// Widget shown directly below the gauge.
  final Widget? footer;

  /// Solid fill colour for the circle inside the arc track.
  final Color? fillColor;

  /// When `true`, fills the arc from the far (clockwise) end of the track
  /// rather than from the start.
  final bool reverse;

  /// Whether to render the auto-formatted value in the centre.
  ///
  /// Ignored when [child] is provided. Defaults to `true`.
  final bool showValue;

  /// Unit suffix appended to the auto-formatted centre label (e.g. `'%'`).
  final String? unitText;

  /// Widget that tracks the current arc tip position.
  ///
  /// Use a small icon or dot to create a moving indicator. The widget is
  /// centred on the precise arc endpoint calculated from [controller.value].
  final Widget? widgetIndicator;

  /// Override for the background track stroke width (logical pixels).
  ///
  /// When `null`, falls back to [GaugeTokens.trackStrokeWidth].
  final double? backgroundWidth;

  // ─── Internal ───────────────────────────────────────────────────────────────

  GaugeTokens _resolve(BuildContext context) {
    final ext = Theme.of(context).extension<GaugeThemeExtension>();
    final resolvedStyle = style ?? ext?.style ?? const DefaultGaugeStyle();
    final resolvedMode = mode ?? ext?.defaultMode ?? GaugeMode.ambient;
    return resolvedStyle.resolve(context, resolvedMode);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _resolve(context);
    final effectiveTrackW = backgroundWidth ?? tokens.trackStrokeWidth;

    Widget gaugeArea = Stack(
      children: [
        _ArcGaugeLeaf(
          controller: controller,
          tokens: tokens,
          min: min,
          max: max,
          startAngleDeg: startAngleDeg,
          sweepAngleDeg: sweepAngleDeg,
          centerLabel: centerLabel,
          centerLabelStyle: centerLabelStyle,
          ranges: ranges,
          semanticsLabel: semanticsLabel,
          fillColor: fillColor,
          reverse: reverse,
          showValue: child == null && showValue,
          unitText: unitText,
          backgroundWidth: backgroundWidth,
        ),
        if (child != null)
          Positioned.fill(
            child: Align(alignment: Alignment.center, child: child!),
          ),
        if (widgetIndicator != null)
          LayoutBuilder(builder: (ctx, constraints) {
            return ListenableBuilder(
              listenable: controller,
              builder: (ctx2, _) {
                final side =
                    math.min(constraints.maxWidth, constraints.maxHeight);
                if (side == 0) return const SizedBox.shrink();
                final cx = side / 2;
                final cy = side / 2;
                final radius = side / 2 - effectiveTrackW / 2 - 4;
                final frac =
                    ((controller.value - min) / (max - min)).clamp(0.0, 1.0);
                final startRad = startAngleDeg * math.pi / 180;
                final sweepRad = sweepAngleDeg * math.pi / 180;
                final angle = reverse
                    ? startRad + sweepRad - frac * sweepRad
                    : startRad + frac * sweepRad;
                final x = cx + math.cos(angle) * radius;
                final y = cy + math.sin(angle) * radius;
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
              },
            );
          }),
      ],
    );

    if (header == null && footer == null) return gaugeArea;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) header!,
        gaugeArea,
        if (footer != null) footer!,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private leaf widget — pure canvas, no Flutter child support.
// ---------------------------------------------------------------------------

class _ArcGaugeLeaf extends LeafRenderObjectWidget {
  const _ArcGaugeLeaf({
    required this.controller,
    required this.tokens,
    required this.min,
    required this.max,
    required this.startAngleDeg,
    required this.sweepAngleDeg,
    required this.centerLabel,
    required this.centerLabelStyle,
    required this.ranges,
    required this.semanticsLabel,
    required this.fillColor,
    required this.reverse,
    required this.showValue,
    required this.unitText,
    required this.backgroundWidth,
  });

  final GaugeController controller;
  final GaugeTokens tokens;
  final double min;
  final double max;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final String? centerLabel;
  final TextStyle? centerLabelStyle;
  final List<GaugeRange> ranges;
  final String? semanticsLabel;
  final Color? fillColor;
  final bool reverse;
  final bool showValue;
  final String? unitText;
  final double? backgroundWidth;

  @override
  ArcGaugeRenderBox createRenderObject(BuildContext context) {
    return ArcGaugeRenderBox(
      controller: controller,
      tokens: tokens,
      min: min,
      max: max,
      startAngleDeg: startAngleDeg,
      sweepAngleDeg: sweepAngleDeg,
      centerLabel: centerLabel,
      centerLabelStyle: centerLabelStyle,
      ranges: ranges,
      semanticsLabel: semanticsLabel,
      fillColor: fillColor,
      reverse: reverse,
      showValue: showValue,
      unitText: unitText,
      backgroundWidth: backgroundWidth,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, ArcGaugeRenderBox renderObject) {
    renderObject
      ..tokens = tokens
      ..centerLabel = centerLabel
      ..ranges = ranges
      ..min = min
      ..max = max
      ..semanticsLabel = semanticsLabel
      ..fillColor = fillColor
      ..reverse = reverse
      ..showValue = showValue
      ..unitText = unitText
      ..backgroundWidth = backgroundWidth;
  }
}
