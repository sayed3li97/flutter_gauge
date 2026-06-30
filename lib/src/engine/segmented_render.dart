import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [SegmentedGauge] — a row/column of discrete LED-style segments.
class SegmentedGaugeRenderBox extends RenderBox {
  SegmentedGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required int segmentCount,
    required bool horizontal,
    required double gap,
    String? semanticsLabel,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _segmentCount = segmentCount,
        _horizontal = horizontal,
        _gap = gap,
        _semanticsLabel = semanticsLabel {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  int _segmentCount;
  final bool _horizontal;
  final double _gap;
  String? _semanticsLabel;

  @override
  bool get isRepaintBoundary => true;

  void _onValueChanged() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  set semanticsLabel(String? v) {
    _semanticsLabel = v;
    markNeedsSemanticsUpdate();
  }

  set tokens(GaugeTokens v) {
    if (_tokens == v) return;
    _tokens = v;
    markNeedsPaint();
  }

  set segmentCount(int v) {
    if (_segmentCount == v) return;
    _segmentCount = v;
    markNeedsPaint();
  }

  set min(double v) {
    if (_min == v) return;
    _min = v;
    markNeedsPaint();
  }

  set max(double v) {
    if (_max == v) return;
    _max = v;
    markNeedsPaint();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? 'Segmented gauge'
      ..value = _controller.value.toStringAsFixed(0)
      ..textDirection = TextDirection.ltr;
  }

  @override
  void performLayout() {
    if (_horizontal) {
      size = constraints.constrain(Size(constraints.maxWidth, 28));
    } else {
      size = constraints.constrain(Size(28, constraints.maxHeight));
    }
  }

  Color _colorForFraction(double segFrac) {
    if (segFrac >= 0.8) return _tokens.zoneDanger;
    if (segFrac >= 0.6) return _tokens.zoneWarning;
    return _tokens.zoneNormal;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final frac = valueToFraction(_controller.value, _min, _max);
    final litCount = (frac * _segmentCount).round();

    final rr = Radius.circular(_tokens.trackBorderRadius);

    if (_horizontal) {
      final totalGap = _gap * (_segmentCount - 1);
      final segW = (size.width - totalGap) / _segmentCount;
      final segH = size.height;
      for (var i = 0; i < _segmentCount; i++) {
        final x = i * (segW + _gap);
        final segFrac = (i + 1) / _segmentCount;
        final active = i < litCount;
        final color =
            active ? _colorForFraction(segFrac) : _tokens.trackColor;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, segW, segH), rr),
          Paint()..color = color,
        );
      }
    } else {
      final totalGap = _gap * (_segmentCount - 1);
      final segH = (size.height - totalGap) / _segmentCount;
      final segW = size.width;
      for (var i = 0; i < _segmentCount; i++) {
        final idx = _segmentCount - 1 - i; // bottom → top
        final y = i * (segH + _gap);
        final segFrac = (idx + 1) / _segmentCount;
        final active = idx < litCount;
        final color =
            active ? _colorForFraction(segFrac) : _tokens.trackColor;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(0, y, segW, segH), rr),
          Paint()..color = color,
        );
      }
    }

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
