import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [OdometerGauge] — a rolling digit display.
class OdometerGaugeRenderBox extends RenderBox {
  OdometerGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required int digitCount,
    required int decimalDigits,
    required String? unit,
  })  : _controller = controller,
        _tokens = tokens,
        _digitCount = digitCount,
        _decimalDigits = decimalDigits,
        _unit = unit {
    _controller.addListener(_onValueChanged);
  }

  GaugeController _controller;
  GaugeTokens _tokens;
  int _digitCount;
  int _decimalDigits;
  String? _unit;

  @override
  bool get isRepaintBoundary => true;

  void _onValueChanged() => markNeedsPaint();

  set tokens(GaugeTokens v) {
    if (_tokens == v) return;
    _tokens = v;
    markNeedsPaint();
  }

  set digitCount(int v) {
    if (_digitCount == v) return;
    _digitCount = v;
    markNeedsLayout();
  }

  set decimalDigits(int v) {
    if (_decimalDigits == v) return;
    _decimalDigits = v;
    markNeedsLayout();
  }

  set unit(String? v) {
    _unit = v;
    markNeedsPaint();
  }

  static const double _digitW = 22.0;
  static const double _digitH = 36.0;

  @override
  void performLayout() {
    final totalDigits = _digitCount + (_decimalDigits > 0 ? _decimalDigits + 1 : 0);
    final w = totalDigits * _digitW + (_unit != null ? 24 : 0) + 16;
    size = constraints.constrain(Size(w, _digitH + 16));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final bg = Paint()..color = _tokens.trackColor;
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(6),
    );
    canvas.drawRRect(rr, bg);

    final value = _controller.value;
    final formatted = value.toStringAsFixed(_decimalDigits);
    final totalInt = _digitCount;

    // Build display string with leading zeros
    String display = '';
    if (_decimalDigits > 0) {
      final parts = formatted.split('.');
      final intPart = parts[0].replaceAll('-', '');
      final decPart = parts.length > 1 ? parts[1] : '0' * _decimalDigits;
      display = intPart.padLeft(totalInt, '0') + '.' + decPart;
    } else {
      display = formatted.replaceAll('-', '').padLeft(totalInt, '0');
    }

    final style = _tokens.labelStyle.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: 2,
    );

    double x = 8;
    for (var i = 0; i < display.length; i++) {
      final ch = display[i];
      final tp = TextPainter(
        text: TextSpan(text: ch, style: style),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: _digitW, maxWidth: _digitW);

      if (ch != '.') {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, 4, _digitW, _digitH),
            const Radius.circular(3),
          ),
          Paint()..color = _tokens.valueColor.withValues(alpha: 0.15),
        );
      }

      tp.paint(canvas, Offset(x + (_digitW - tp.width) / 2, (size.height - _digitH) / 2));
      x += ch == '.' ? 10 : _digitW + 2;
    }

    if (_unit != null) {
      final utp = TextPainter(
        text: TextSpan(text: _unit, style: _tokens.labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      utp.paint(canvas, Offset(x + 4, size.height / 2 - utp.height / 2));
    }

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
