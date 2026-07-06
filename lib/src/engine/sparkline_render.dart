import 'package:flutter/rendering.dart';

import '../core/sparkline_controller.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [SparklineGauge] — a compact trend line over a rolling
/// sample window.
class SparklineGaugeRenderBox extends RenderBox {
  SparklineGaugeRenderBox({
    required SparklineController controller,
    required GaugeTokens tokens,
    double? min,
    double? max,
    required double lineWidth,
    required bool showFill,
    required bool showLastPointMarker,
    required double markerRadius,
    String? semanticsLabel,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _lineWidth = lineWidth,
        _showFill = showFill,
        _showLastPointMarker = showLastPointMarker,
        _markerRadius = markerRadius,
        _semanticsLabel = semanticsLabel {
    _controller.addListener(_onChanged);
  }

  final SparklineController _controller;
  GaugeTokens _tokens;
  double? _min;
  double? _max;
  double _lineWidth;
  bool _showFill;
  bool _showLastPointMarker;
  double _markerRadius;
  String? _semanticsLabel;

  @override
  bool get isRepaintBoundary => true;

  void _onChanged() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  set tokens(GaugeTokens v) {
    if (_tokens == v) return;
    _tokens = v;
    markNeedsPaint();
  }

  set min(double? v) {
    if (_min == v) return;
    _min = v;
    markNeedsPaint();
  }

  set max(double? v) {
    if (_max == v) return;
    _max = v;
    markNeedsPaint();
  }

  set lineWidth(double v) {
    if (_lineWidth == v) return;
    _lineWidth = v;
    markNeedsPaint();
  }

  set showFill(bool v) {
    if (_showFill == v) return;
    _showFill = v;
    markNeedsPaint();
  }

  set showLastPointMarker(bool v) {
    if (_showLastPointMarker == v) return;
    _showLastPointMarker = v;
    markNeedsPaint();
  }

  set markerRadius(double v) {
    if (_markerRadius == v) return;
    _markerRadius = v;
    markNeedsPaint();
  }

  set semanticsLabel(String? v) {
    _semanticsLabel = v;
    markNeedsSemanticsUpdate();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  String _trendDescription(List<double> samples) {
    if (samples.length < 2) return 'not enough data';
    final delta = samples.last - samples.first;
    if (delta.abs() < 1e-9) return 'stable';
    return delta > 0 ? 'increasing' : 'decreasing';
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    final samples = _controller.samples;
    config
      ..label = _semanticsLabel ?? 'Sparkline'
      ..value = samples.isEmpty
          ? 'no data'
          : '${samples.last.toStringAsFixed(1)}, ${_trendDescription(samples)}'
      ..textDirection = TextDirection.ltr;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final samples = _controller.samples;
    if (samples.length < 2 || size.isEmpty) return;

    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    var lo = _min ?? samples.reduce((a, b) => a < b ? a : b);
    var hi = _max ?? samples.reduce((a, b) => a > b ? a : b);
    if ((hi - lo).abs() < 1e-9) {
      lo -= 1;
      hi += 1;
    }

    final n = samples.length;
    final dx = size.width / (n - 1);
    Offset pointAt(int i) {
      final frac = ((samples[i] - lo) / (hi - lo)).clamp(0.0, 1.0);
      return Offset(i * dx, size.height - frac * size.height);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < n; i++) {
      final p = pointAt(i);
      path.lineTo(p.dx, p.dy);
    }

    if (_showFill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()..color = _tokens.valueColor.withValues(alpha: 0.15),
      );
    }

    final glowR = _tokens.valueGlowRadius;
    if (glowR > 0) {
      final glowColor =
          _tokens.valueGlowColor ?? _tokens.valueColor.withValues(alpha: 0.5);
      canvas.drawPath(
        path,
        Paint()
          ..color = glowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowR),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = _tokens.valueColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (_showLastPointMarker) {
      canvas.drawCircle(
        pointAt(n - 1),
        _markerRadius,
        Paint()..color = _tokens.knobColor,
      );
    }

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }
}
