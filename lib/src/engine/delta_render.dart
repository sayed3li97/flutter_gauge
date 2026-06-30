import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';
import 'paint_utils.dart';

/// Render engine for [DeltaGauge] — shows change from a baseline value.
/// [controller.value] is the current value; delta = value - baseline.
class DeltaGaugeRenderBox extends RenderBox {
  DeltaGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double baseline,
    required double min,
    required double max,
    required String? unit,
    required bool lowerIsBetter,
  })  : _controller = controller,
        _tokens = tokens,
        _baseline = baseline,
        _min = min,
        _max = max,
        _unit = unit,
        _lowerIsBetter = lowerIsBetter {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _baseline;
  double _min;
  double _max;
  final String? _unit;
  bool _lowerIsBetter;

  ui.Picture? _staticPicture;
  Size _staticSize = Size.zero;

  @override
  bool get isRepaintBoundary => true;

  void _onValueChanged() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  set tokens(GaugeTokens v) {
    if (_tokens == v) return;
    _tokens = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set baseline(double v) {
    if (_baseline == v) return;
    _baseline = v;
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

  set lowerIsBetter(bool v) {
    if (_lowerIsBetter == v) return;
    _lowerIsBetter = v;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, 48));
  }

  void _rebuildStaticPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final cy = size.height / 2;
    final trackPaint = Paint()
      ..color = _tokens.trackColor
      ..strokeWidth = _tokens.trackStrokeWidth
      ..strokeCap = _tokens.trackStrokeCap;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), trackPaint);

    // Baseline marker
    final baseFrac = valueToFraction(_baseline, _min, _max);
    final bx = baseFrac * size.width;
    canvas.drawLine(
      Offset(bx, cy - _tokens.majorTick.length),
      Offset(bx, cy + _tokens.majorTick.length),
      Paint()
        ..color = _tokens.majorTick.color
        ..strokeWidth = _tokens.majorTick.strokeWidth * 2,
    );

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

    final cy = size.height / 2;
    final baseFrac = valueToFraction(_baseline, _min, _max);
    final valFrac = valueToFraction(_controller.value, _min, _max);
    final bx = baseFrac * size.width;
    final vx = valFrac * size.width;

    // Delta bar
    final delta = _controller.value - _baseline;
    final isImprovement = _lowerIsBetter ? delta <= 0 : delta >= 0;
    final barColor = isImprovement ? _tokens.zoneNormal : _tokens.zoneDanger;
    canvas.drawLine(
      Offset(bx, cy),
      Offset(vx, cy),
      Paint()
        ..color = barColor
        ..strokeWidth = _tokens.valueStrokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Value dot
    canvas.drawCircle(
      Offset(vx, cy),
      _tokens.knobRadius * 0.7,
      Paint()..color = barColor,
    );

    // Delta label
    final sign = delta >= 0 ? '+' : '';
    final label = '$sign${_fmt(delta)}${_unit != null ? ' $_unit' : ''}';
    final tp = TextPainter(
      text: TextSpan(
          text: label,
          style: _tokens.labelStyle.copyWith(color: barColor)),
      textDirection: TextDirection.ltr,
    )..layout();
    paintTextOnCanvas(canvas, tp,
        Offset(vx - tp.width / 2, cy - _tokens.trackStrokeWidth / 2 - tp.height - 4));

    canvas.restore();
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v.toStringAsFixed(1);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    final delta = _controller.value - _baseline;
    final sign = delta >= 0 ? '+' : '';
    config
      ..label = 'Delta gauge'
      ..value = '$sign${delta.toStringAsFixed(1)}${_unit != null ? " $_unit" : ""}'
      ..textDirection = TextDirection.ltr;
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
