import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_range.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [ArcGauge] — a partial-circle progress indicator.
class ArcGaugeRenderBox extends RenderBox {
  ArcGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required double startAngleDeg,
    required double sweepAngleDeg,
    required String? centerLabel,
    required TextStyle? centerLabelStyle,
    List<GaugeRange> ranges = const [],
    String? semanticsLabel,
    Color? fillColor,
    bool reverse = false,
    bool showValue = true,
    String? unitText,
    double? backgroundWidth,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _startAngleDeg = startAngleDeg,
        _sweepAngleDeg = sweepAngleDeg,
        _centerLabel = centerLabel,
        _centerLabelStyle = centerLabelStyle,
        _ranges = ranges,
        _semanticsLabel = semanticsLabel,
        _fillColor = fillColor,
        _reverse = reverse,
        _showValue = showValue,
        _unitText = unitText,
        _backgroundWidth = backgroundWidth {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  final double _startAngleDeg;
  final double _sweepAngleDeg;
  String? _centerLabel;
  final TextStyle? _centerLabelStyle;
  List<GaugeRange> _ranges;
  String? _semanticsLabel;
  Color? _fillColor;
  bool _reverse;
  bool _showValue;
  String? _unitText;
  double? _backgroundWidth;

  ui.Picture? _staticPicture;
  Size _staticSize = Size.zero;

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
    _staticPicture = null;
    markNeedsPaint();
  }

  set centerLabel(String? v) {
    _centerLabel = v;
    markNeedsPaint();
  }

  set ranges(List<GaugeRange> v) {
    _ranges = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set min(double v) {
    if (_min == v) return;
    _min = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set max(double v) {
    if (_max == v) return;
    _max = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set fillColor(Color? v) {
    if (_fillColor == v) return;
    _fillColor = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set reverse(bool v) {
    if (_reverse == v) return;
    _reverse = v;
    markNeedsPaint();
  }

  set showValue(bool v) {
    if (_showValue == v) return;
    _showValue = v;
    markNeedsPaint();
  }

  set unitText(String? v) {
    if (_unitText == v) return;
    _unitText = v;
    markNeedsPaint();
  }

  set backgroundWidth(double? v) {
    if (_backgroundWidth == v) return;
    _backgroundWidth = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? 'Arc gauge'
      ..value = _fmtWithUnit(_controller.value)
      ..textDirection = TextDirection.ltr;
  }

  @override
  void performLayout() {
    final side = constraints.biggest.shortestSide;
    size = constraints.constrain(Size(side, side));
  }

  double get _effectiveTrackWidth =>
      _backgroundWidth ?? _tokens.trackStrokeWidth;

  void _rebuildStaticPicture(Size sz) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = sz.center(Offset.zero);
    final radius = sz.shortestSide / 2 - _effectiveTrackWidth / 2 - 4;
    final startRad = degToRad(_startAngleDeg);
    final sweepRad = degToRad(_sweepAngleDeg);

    if (_fillColor != null) {
      canvas.drawCircle(
          center, radius - _effectiveTrackWidth / 2, Paint()..color = _fillColor!);
    }

    final trackPaint = Paint()
      ..color = _tokens.trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _effectiveTrackWidth
      ..strokeCap = _tokens.trackStrokeCap;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepRad,
      false,
      trackPaint,
    );

    for (final range in _ranges) {
      final rStart = valueToAngle(range.min, _min, _max, startRad, sweepRad);
      final rSweep =
          valueToAngle(range.max, _min, _max, startRad, sweepRad) - rStart;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        rStart,
        rSweep,
        false,
        Paint()
          ..color = range.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _effectiveTrackWidth
          ..strokeCap = StrokeCap.butt,
      );
    }

    _staticPicture = recorder.endRecording();
    _staticSize = sz;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (_staticPicture == null || _staticSize != size) {
      _rebuildStaticPicture(size);
    }
    canvas.drawPicture(_staticPicture!);

    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _effectiveTrackWidth / 2 - 4;
    final startRad = degToRad(_startAngleDeg);
    final sweepRad = degToRad(_sweepAngleDeg);

    final frac =
        ((_controller.value - _min) / (_max - _min)).clamp(0.0, 1.0);
    final valueSweep = frac * sweepRad;

    if (valueSweep > 0) {
      // Reverse: fill from far end of track backward
      final arcStart =
          _reverse ? startRad + sweepRad - valueSweep : startRad;
      final rect = Rect.fromCircle(center: center, radius: radius);

      // Glow pass
      final glowR = _tokens.valueGlowRadius;
      if (glowR > 0) {
        final glowColor = _tokens.valueGlowColor ??
            _tokens.valueColor.withValues(alpha: 0.5);
        canvas.drawArc(
          rect,
          arcStart,
          valueSweep,
          false,
          Paint()
            ..color = glowColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = _tokens.valueStrokeWidth
            ..strokeCap = _tokens.trackStrokeCap
            ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowR),
        );
      }

      if (_tokens.valueGradient != null) {
        canvas.drawArc(
          rect,
          arcStart,
          valueSweep,
          false,
          Paint()
            ..shader = _tokens.valueGradient!.createShader(rect)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _tokens.valueStrokeWidth
            ..strokeCap = _tokens.trackStrokeCap,
        );
      } else {
        canvas.drawArc(
          rect,
          arcStart,
          valueSweep,
          false,
          Paint()
            ..color = _tokens.valueColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = _tokens.valueStrokeWidth
            ..strokeCap = _tokens.trackStrokeCap,
        );
      }

      // End-cap dot at the value tip
      final endAngle = arcStart + valueSweep;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(endAngle) * radius,
          center.dy + math.sin(endAngle) * radius,
        ),
        _tokens.valueStrokeWidth / 2,
        Paint()..color = _tokens.valueColor,
      );
    }

    // Centre label via PictureRecorder (CanvasKit text workaround)
    if (_showValue) {
      final labelText = _centerLabel ?? _fmtWithUnit(_controller.value);
      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: _centerLabelStyle ??
              _tokens.labelStyle
                  .copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final rec = ui.PictureRecorder();
      tp.paint(Canvas(rec), Offset.zero);
      final pic = rec.endRecording();
      canvas.save();
      canvas.translate(center.dx - tp.width / 2, center.dy - tp.height / 2);
      canvas.drawPicture(pic);
      canvas.restore();
    }

    canvas.restore();
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v.toStringAsFixed(1);
  }

  String _fmtWithUnit(double v) {
    final s = _fmt(v);
    return _unitText != null ? '$s $_unitText' : s;
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
