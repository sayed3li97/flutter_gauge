import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [LevelMeterGauge] — vertical stereo VU meter bars.
class LevelMeterGaugeRenderBox extends RenderBox {
  LevelMeterGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required int channelCount,
    required double gap,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _channelCount = channelCount,
        _gap = gap {
    _controller.addListener(_onValueChanged);
  }

  GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  int _channelCount;
  double _gap;

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

  set channelCount(int v) {
    if (_channelCount == v) return;
    _channelCount = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(
        (_channelCount * 20) + (_channelCount - 1) * _gap,
        constraints.maxHeight,
      ),
    );
  }

  Color _colorAt(double frac) {
    if (frac >= 0.85) return _tokens.zoneDanger;
    if (frac >= 0.65) return _tokens.zoneWarning;
    return _tokens.zoneNormal;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final channelWidth = (size.width - _gap * (_channelCount - 1)) / _channelCount;
    final frac = valueToFraction(_controller.value, _min, _max);

    for (var ch = 0; ch < _channelCount; ch++) {
      final x = ch * (channelWidth + _gap);

      // Background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, channelWidth, size.height),
          const Radius.circular(3),
        ),
        Paint()..color = _tokens.trackColor,
      );

      // Fill in segments
      const segCount = 20;
      final segH = (size.height - (segCount - 1) * 2) / segCount;
      for (var s = 0; s < segCount; s++) {
        final segFrac = (s + 1) / segCount;
        if (segFrac > frac) continue;
        final sy = size.height - (s + 1) * (segH + 2) + 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 1, sy, channelWidth - 2, segH),
            const Radius.circular(2),
          ),
          Paint()..color = _colorAt(segFrac),
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
