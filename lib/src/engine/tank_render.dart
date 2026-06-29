import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [TankGauge] — a vertical or horizontal liquid tank.
class TankGaugeRenderBox extends RenderBox {
  TankGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required bool vertical,
    bool showWave = false,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _vertical = vertical {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  final bool _vertical;

  @override
  bool get isRepaintBoundary => true;

  void _onValueChanged() => markNeedsPaint();

  set tokens(GaugeTokens v) {
    if (_tokens == v) return;
    _tokens = v;
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
  void performLayout() {
    if (_vertical) {
      size = constraints.constrain(Size(60, constraints.maxHeight));
    } else {
      size = constraints.constrain(Size(constraints.maxWidth, 60));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final rr = Radius.circular(_tokens.trackBorderRadius + 4);
    final border = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      rr,
    );

    // Tank body
    canvas.drawRRect(border, Paint()..color = _tokens.trackColor);

    final frac = valueToFraction(_controller.value, _min, _max);

    if (_vertical) {
      final fillHeight = frac * size.height;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight),
        rr,
      );
      canvas.drawRRect(fillRect, Paint()..color = _tokens.valueColor);
    } else {
      final fillWidth = frac * size.width;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        rr,
      );
      canvas.drawRRect(fillRect, Paint()..color = _tokens.valueColor);
    }

    // Tank border
    canvas.drawRRect(
      border,
      Paint()
        ..color = _tokens.majorTick.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Level percentage label
    final label = '${(frac * 100).round()}%';
    final tp = TextPainter(
      text: TextSpan(text: label, style: _tokens.labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        size.width / 2 - tp.width / 2,
        size.height / 2 - tp.height / 2,
      ),
    );

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
