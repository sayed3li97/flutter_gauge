import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/unit_converter.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [ThermometerGauge].
/// Value is always stored in Celsius; [scale] controls display.
class ThermometerGaugeRenderBox extends RenderBox {
  ThermometerGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double minCelsius,
    required double maxCelsius,
    required TemperatureScale scale,
    required bool showScale,
  })  : _controller = controller,
        _tokens = tokens,
        _minCelsius = minCelsius,
        _maxCelsius = maxCelsius,
        _scale = scale,
        _showScale = showScale {
    _controller.addListener(_onValueChanged);
  }

  GaugeController _controller;
  GaugeTokens _tokens;
  double _minCelsius;
  double _maxCelsius;
  TemperatureScale _scale;
  bool _showScale;

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

  set scale(TemperatureScale v) {
    if (_scale == v) return;
    _scale = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(60, constraints.maxHeight));
  }

  static const double _bulbRadius = 16.0;
  static const double _stemWidth = 12.0;

  void _rebuildStaticPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final cx = size.width / 2;
    final stemTop = 8.0;
    final stemBottom = size.height - _bulbRadius * 2 - 4;
    final stemHeight = stemBottom - stemTop;

    // Stem outline
    final stemRect = Rect.fromLTWH(
      cx - _stemWidth / 2,
      stemTop,
      _stemWidth,
      stemHeight,
    );
    final stemRRect = RRect.fromRectAndCorners(
      stemRect,
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(stemRRect, Paint()..color = _tokens.trackColor);

    // Bulb outline
    final bulbCenter = Offset(cx, size.height - _bulbRadius - 2);
    canvas.drawCircle(bulbCenter, _bulbRadius, Paint()..color = _tokens.trackColor);

    // Scale labels
    if (_showScale) {
      const divisions = 5;
      for (var i = 0; i <= divisions; i++) {
        final t = i / divisions;
        final y = stemBottom - t * stemHeight;
        final val = _minCelsius + t * (_maxCelsius - _minCelsius);
        final display = _scale.convert(val);
        final label = '${display.round()}${_scale.symbol}';
        final tp = TextPainter(
          text: TextSpan(text: label, style: _tokens.labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx + _stemWidth / 2 + 4, y - tp.height / 2));
        // Tick
        canvas.drawLine(
          Offset(cx + _stemWidth / 2, y),
          Offset(cx + _stemWidth / 2 + 3, y),
          Paint()
            ..color = _tokens.majorTick.color
            ..strokeWidth = 1,
        );
      }
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

    final cx = size.width / 2;
    final stemTop = 8.0;
    final stemBottom = size.height - _bulbRadius * 2 - 4;
    final stemHeight = stemBottom - stemTop;

    final frac = valueToFraction(_controller.value, _minCelsius, _maxCelsius);
    final fillHeight = frac * stemHeight;
    final fillTop = stemBottom - fillHeight;

    // Value fill in stem
    final fillRect = Rect.fromLTWH(
      cx - _stemWidth / 2 + 2,
      fillTop,
      _stemWidth - 4,
      fillHeight,
    );
    canvas.drawRect(fillRect, Paint()..color = _tokens.valueColor);

    // Bulb fill
    final bulbCenter = Offset(cx, size.height - _bulbRadius - 2);
    canvas.drawCircle(
        bulbCenter, _bulbRadius - 2, Paint()..color = _tokens.valueColor);

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
