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
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _startAngleDeg = startAngleDeg,
        _sweepAngleDeg = sweepAngleDeg,
        _centerLabel = centerLabel,
        _centerLabelStyle = centerLabelStyle,
        _ranges = ranges {
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

  ui.Picture? _staticPicture;
  Size _staticSize = Size.zero;

  @override
  bool get isRepaintBoundary => true;

  void _onValueChanged() => markNeedsPaint();

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

  @override
  void performLayout() {
    final side = constraints.biggest.shortestSide;
    size = constraints.constrain(Size(side, side));
  }

  void _rebuildStaticPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _tokens.trackStrokeWidth / 2 - 4;
    final startRad = degToRad(_startAngleDeg);
    final sweepRad = degToRad(_sweepAngleDeg);

    final trackPaint = Paint()
      ..color = _tokens.trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _tokens.trackStrokeWidth
      ..strokeCap = _tokens.trackStrokeCap;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepRad,
      false,
      trackPaint,
    );

    // Colored ranges over track
    for (final range in _ranges) {
      final rStart = valueToAngle(range.min, _min, _max, startRad, sweepRad);
      final rSweep = valueToAngle(range.max, _min, _max, startRad, sweepRad) - rStart;
      final rangePaint = Paint()
        ..color = range.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _tokens.trackStrokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        rStart,
        rSweep,
        false,
        rangePaint,
      );
    }

    _staticPicture = recorder.endRecording();
    _staticSize = size;
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
    final radius = size.shortestSide / 2 - _tokens.trackStrokeWidth / 2 - 4;
    final startRad = degToRad(_startAngleDeg);
    final sweepRad = degToRad(_sweepAngleDeg);
    final valueAngle = valueToAngle(_controller.value, _min, _max, startRad, sweepRad);
    final valueSweep = valueAngle - startRad;

    if (valueSweep > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      if (_tokens.valueGradient != null) {
        final vPaint = Paint()
          ..shader = _tokens.valueGradient!.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _tokens.valueStrokeWidth
          ..strokeCap = _tokens.trackStrokeCap;
        canvas.drawArc(rect, startRad, valueSweep, false, vPaint);
      } else {
        final vPaint = Paint()
          ..color = _tokens.valueColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _tokens.valueStrokeWidth
          ..strokeCap = _tokens.trackStrokeCap;
        canvas.drawArc(rect, startRad, valueSweep, false, vPaint);
      }

      // End cap dot
      final endAngle = startRad + valueSweep;
      final capCenter = Offset(
        center.dx + math.cos(endAngle) * radius,
        center.dy + math.sin(endAngle) * radius,
      );
      canvas.drawCircle(
        capCenter,
        _tokens.valueStrokeWidth / 2,
        Paint()..color = _tokens.valueColor,
      );
    }

    // Center label — painted via PictureRecorder so text renders correctly in CanvasKit
    final labelText = _centerLabel ?? _fmt(_controller.value);
    final tp = TextPainter(
      text: TextSpan(
        text: labelText,
        style: _centerLabelStyle ??
            _tokens.labelStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textRecorder = ui.PictureRecorder();
    tp.paint(Canvas(textRecorder), Offset.zero);
    final textPic = textRecorder.endRecording();
    canvas.save();
    canvas.translate(center.dx - tp.width / 2, center.dy - tp.height / 2);
    canvas.drawPicture(textPic);
    canvas.restore();

    canvas.restore();
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
