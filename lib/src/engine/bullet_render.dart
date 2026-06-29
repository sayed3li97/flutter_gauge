import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';
import 'paint_utils.dart';

/// Render engine for [BulletGauge] — a Stephen Few-style bullet chart.
class BulletGaugeRenderBox extends RenderBox {
  BulletGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required double? targetValue,
    required double poorThreshold,
    required double satisfactoryThreshold,
    required String? label,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _targetValue = targetValue,
        _poorThreshold = poorThreshold,
        _satisfactoryThreshold = satisfactoryThreshold,
        _label = label {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  double? _targetValue;
  final double _poorThreshold;
  final double _satisfactoryThreshold;
  final String? _label;

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

  set targetValue(double? v) {
    _targetValue = v;
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
    size = constraints.constrain(Size(constraints.maxWidth, 36));
  }

  void _rebuildStaticPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final trackH = size.height * 0.4;
    final trackY = (size.height - trackH) / 2;
    final trackW = size.width;

    // Poor zone (full width background)
    canvas.drawRect(
      Rect.fromLTWH(0, trackY, trackW, trackH),
      Paint()..color = _tokens.zoneDanger.withValues(alpha: 0.3),
    );

    // Satisfactory zone
    final satW = valueToFraction(_satisfactoryThreshold, _min, _max) * trackW;
    canvas.drawRect(
      Rect.fromLTWH(0, trackY, satW, trackH),
      Paint()..color = _tokens.zoneWarning.withValues(alpha: 0.3),
    );

    // Good zone (poorThreshold and below)
    final goodW = valueToFraction(_poorThreshold, _min, _max) * trackW;
    canvas.drawRect(
      Rect.fromLTWH(0, trackY, goodW, trackH),
      Paint()..color = _tokens.zoneNormal.withValues(alpha: 0.3),
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

    final trackW = size.width;
    final barH = size.height * 0.25;
    final barY = (size.height - barH) / 2;
    final frac = valueToFraction(_controller.value, _min, _max);

    // Value bar
    canvas.drawRect(
      Rect.fromLTWH(0, barY, frac * trackW, barH),
      Paint()..color = _tokens.valueColor,
    );

    // Target marker
    if (_targetValue != null) {
      final tFrac = valueToFraction(_targetValue!, _min, _max);
      final tx = tFrac * trackW;
      final markerH = size.height * 0.6;
      final markerY = (size.height - markerH) / 2;
      canvas.drawLine(
        Offset(tx, markerY),
        Offset(tx, markerY + markerH),
        Paint()
          ..color = _tokens.needleColor
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Label
    if (_label != null) {
      final tp = TextPainter(
        text: TextSpan(text: _label, style: _tokens.labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      paintTextOnCanvas(canvas, tp, Offset(4, size.height / 2 - tp.height / 2));
    }

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
