import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../styles/gauge_tokens.dart';
import 'paint_utils.dart';

/// Render engine for [StatusGauge] — a simple colored indicator dot or ring.
/// [controller.value]: 0 = normal, 1 = warning, 2 = danger.
class StatusGaugeRenderBox extends RenderBox {
  StatusGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double radius,
    required String? label,
  })  : _controller = controller,
        _tokens = tokens,
        _radius = radius,
        _label = label {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _radius;
  String? _label;

  @override
  bool get isRepaintBoundary => true;

  void _onValueChanged() => markNeedsPaint();

  set tokens(GaugeTokens v) {
    if (_tokens == v) return;
    _tokens = v;
    markNeedsPaint();
  }

  set radius(double v) {
    if (_radius == v) return;
    _radius = v;
    markNeedsLayout();
  }

  set label(String? v) {
    _label = v;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final tp = _label == null
        ? null
        : (TextPainter(
            text: TextSpan(text: _label, style: _tokens.labelStyle),
            textDirection: TextDirection.ltr,
          )..layout());
    final w = _radius * 2 + (_label != null ? (tp!.width + 8) : 0);
    size = constraints.constrain(Size(w, _radius * 2));
  }

  Color get _statusColor {
    final v = _controller.value.round();
    if (v >= 2) return _tokens.zoneDanger;
    if (v >= 1) return _tokens.zoneWarning;
    return _tokens.zoneNormal;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final color = _statusColor;
    final center = Offset(_radius, _radius);

    // Glow
    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(center, _radius, Paint()..color = color);
    canvas.drawCircle(
      center,
      _radius * 0.55,
      Paint()..color = color.withValues(alpha: 0.6),
    );

    if (_label != null) {
      final tp = TextPainter(
        text: TextSpan(text: _label, style: _tokens.labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      paintTextOnCanvas(canvas, tp, Offset(_radius * 2 + 8, _radius - tp.height / 2));
    }

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
