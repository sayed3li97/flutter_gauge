import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [ArtificialHorizonGauge].
/// Uses two [GaugeController]s: pitch (degrees) and roll (degrees).
class HorizonGaugeRenderBox extends RenderBox {
  HorizonGaugeRenderBox({
    required GaugeController pitchController,
    required GaugeController rollController,
    required HorizonGaugeTokens tokens,
    String? semanticsLabel,
  })  : _pitchController = pitchController,
        _rollController = rollController,
        _tokens = tokens,
        _semanticsLabel = semanticsLabel {
    _pitchController.addListener(_onValueChanged);
    _rollController.addListener(_onValueChanged);
  }

  final GaugeController _pitchController;
  final GaugeController _rollController;
  HorizonGaugeTokens _tokens;
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

  set tokens(HorizonGaugeTokens v) {
    if (_tokens == v) return;
    _tokens = v;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final side = constraints.biggest.shortestSide;
    size = constraints.constrain(Size(side, side));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    // Clip to circle
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r)));

    // Roll rotation
    final roll = _rollController.value * math.pi / 180;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll);
    canvas.translate(-center.dx, -center.dy);

    // Pitch offset (1.5px per degree)
    final pitchOffset = _pitchController.value * 1.5;

    // Sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, center.dy + pitchOffset),
      Paint()..color = _tokens.skyColor,
    );

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, center.dy + pitchOffset, size.width,
          size.height - center.dy - pitchOffset),
      Paint()..color = _tokens.groundColor,
    );

    // Horizon line
    canvas.drawLine(
      Offset(0, center.dy + pitchOffset),
      Offset(size.width, center.dy + pitchOffset),
      Paint()
        ..color = _tokens.horizonLineColor
        ..strokeWidth = _tokens.horizonLineWidth,
    );

    // Pitch ladder (every 10 degrees)
    _paintPitchLadder(canvas, center, pitchOffset);

    canvas.restore();

    // Aircraft symbol (fixed, no rotation)
    _paintAircraftSymbol(canvas, center);

    // Roll arc
    _paintRollArc(canvas, center, r);

    canvas.restore();
  }

  void _paintPitchLadder(Canvas canvas, Offset center, double pitchOffset) {
    const step = 10.0;
    const halfWidth = 40.0;
    const count = 4;
    for (var i = -count; i <= count; i++) {
      if (i == 0) continue;
      final yOffset = center.dy + pitchOffset - i * 1.5 * step;
      canvas.drawLine(
        Offset(center.dx - halfWidth, yOffset),
        Offset(center.dx + halfWidth, yOffset),
        Paint()
          ..color = _tokens.pitchLadderColor
          ..strokeWidth = 1.5,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${(i * step).abs().round()}',
          style: _tokens.labelStyle.copyWith(fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(center.dx + halfWidth + 4, yOffset - tp.height / 2));
    }
  }

  void _paintAircraftSymbol(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = _tokens.aircraftSymbolColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    // Left wing
    canvas.drawLine(
      Offset(center.dx - 40, center.dy),
      Offset(center.dx - 10, center.dy),
      paint,
    );
    // Right wing
    canvas.drawLine(
      Offset(center.dx + 10, center.dy),
      Offset(center.dx + 40, center.dy),
      paint,
    );
    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = _tokens.aircraftSymbolColor);
  }

  void _paintRollArc(Canvas canvas, Offset center, double r) {
    const arcR = 0.85;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * arcR),
      -math.pi,
      math.pi,
      false,
      Paint()
        ..color = _tokens.rollArcColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Roll index at top
    canvas.drawLine(
      Offset(center.dx, center.dy - r * arcR),
      Offset(center.dx, center.dy - r * arcR + 10),
      Paint()
        ..color = _tokens.rollArcColor
        ..strokeWidth = 2,
    );

    // Current roll marker
    final rollRad = _rollController.value * math.pi / 180;
    final markerAngle = -math.pi / 2 + rollRad;
    canvas.drawLine(
      Offset(
        center.dx + math.cos(markerAngle) * r * arcR,
        center.dy + math.sin(markerAngle) * r * arcR,
      ),
      Offset(
        center.dx + math.cos(markerAngle) * (r * arcR - 12),
        center.dy + math.sin(markerAngle) * (r * arcR - 12),
      ),
      Paint()
        ..color = _tokens.aircraftSymbolColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? 'Artificial horizon'
      ..value =
          'pitch ${_pitchController.value.toStringAsFixed(1)}°, roll ${_rollController.value.toStringAsFixed(1)}°'
      ..textDirection = TextDirection.ltr;
  }

  @override
  void dispose() {
    _pitchController.removeListener(_onValueChanged);
    _rollController.removeListener(_onValueChanged);
    super.dispose();
  }
}
