import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [InclinometerGauge].
/// [controller.value] is the tilt angle in degrees (negative = left, positive = right).
class InclinometerGaugeRenderBox extends RenderBox {
  InclinometerGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double maxAngle,
  })  : _controller = controller,
        _tokens = tokens,
        _maxAngle = maxAngle {
    _controller.addListener(_onValueChanged);
  }

  GaugeController _controller;
  GaugeTokens _tokens;
  double _maxAngle;

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

  set maxAngle(double v) {
    if (_maxAngle == v) return;
    _maxAngle = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final side = constraints.biggest.shortestSide;
    size = constraints.constrain(Size(side, side * 0.4));
  }

  void _rebuildStaticPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw tube background
    final tubeRect = Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.6);
    final tubeRRect = RRect.fromRectAndRadius(
      tubeRect,
      Radius.circular(size.height * 0.3),
    );
    canvas.drawRRect(tubeRRect, Paint()..color = _tokens.trackColor);

    // Center mark
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(
      Offset(cx, tubeRect.top + 4),
      Offset(cx, tubeRect.bottom - 4),
      Paint()
        ..color = _tokens.majorTick.color
        ..strokeWidth = _tokens.majorTick.strokeWidth,
    );

    // Tick marks at angles
    const divisions = 4;
    for (var i = -divisions; i <= divisions; i++) {
      if (i == 0) continue;
      final x = cx + (i / divisions) * (size.width / 2 - 20);
      canvas.drawLine(
        Offset(x, tubeRect.top + 4),
        Offset(x, tubeRect.top + _tokens.minorTick.length + 4),
        Paint()
          ..color = _tokens.minorTick.color
          ..strokeWidth = _tokens.minorTick.strokeWidth,
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

    // Bubble position using tan() for inclinometer physics
    final angleDeg = _controller.value.clamp(-_maxAngle, _maxAngle);
    final angleRad = angleDeg * math.pi / 180;
    final bubbleOffset = math.tan(angleRad) * (size.width / 2 - 30);
    final cx = size.width / 2 - bubbleOffset; // bubble opposes tilt
    final cy = size.height / 2;
    final bubbleRadius = size.height * 0.2;

    // Shadow
    canvas.drawCircle(
      Offset(cx + 1, cy + 2),
      bubbleRadius,
      Paint()..color = const Color(0x30000000),
    );

    // Bubble
    canvas.drawCircle(
      Offset(cx, cy),
      bubbleRadius,
      Paint()..color = _tokens.valueColor.withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      bubbleRadius,
      Paint()
        ..color = _tokens.valueColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
