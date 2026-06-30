import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../styles/gauge_tokens.dart';
import 'paint_utils.dart';

/// Render engine for [TapeGauge] — a scrolling tape/ribbon gauge (altimeter style).
class TapeGaugeRenderBox extends RenderBox {
  TapeGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required double tickInterval,
    required String? unit,
    required bool vertical,
    String? semanticsLabel,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _tickInterval = tickInterval,
        _unit = unit,
        _vertical = vertical,
        _semanticsLabel = semanticsLabel {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  double _tickInterval;
  final String? _unit;
  final bool _vertical;
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

  set tickInterval(double v) {
    if (_tickInterval == v) return;
    _tickInterval = v;
    markNeedsPaint();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? 'Tape gauge'
      ..value = _controller.value.toStringAsFixed(0)
      ..textDirection = TextDirection.ltr;
  }

  @override
  void performLayout() {
    if (_vertical) {
      size = constraints.constrain(Size(80, constraints.maxHeight));
    } else {
      size = constraints.constrain(Size(constraints.maxWidth, 60));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Clip
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final value = _controller.value;
    final range = _max - _min;

    if (_vertical) {
      final pxPerUnit = size.height / range;

      // Draw ticks around current value
      final firstTick =
          ((value - range / 2) / _tickInterval).floor() * _tickInterval;
      var tick = firstTick;
      while (tick <= value + range / 2) {
        final y = size.height / 2 - (tick - value) * pxPerUnit;
        if (y >= 0 && y <= size.height) {
          final isMajor = (tick % (_tickInterval * 5)).abs() < 0.001;
          final tStyle = isMajor ? _tokens.majorTick : _tokens.minorTick;
          canvas.drawLine(
            Offset(size.width - tStyle.length, y),
            Offset(size.width, y),
            Paint()
              ..color = tStyle.color
              ..strokeWidth = tStyle.strokeWidth,
          );
          if (isMajor) {
            final tp = TextPainter(
              text: TextSpan(text: _fmt(tick), style: _tokens.labelStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            paintTextOnCanvas(
              canvas,
              tp,
              Offset(size.width - tStyle.length - tp.width - 4, y - tp.height / 2),
            );
          }
        }
        tick += _tickInterval;
      }

      // Center marker
      canvas.drawLine(
        Offset(size.width - _tokens.majorTick.length - 4, size.height / 2),
        Offset(size.width, size.height / 2),
        Paint()
          ..color = _tokens.valueColor
          ..strokeWidth = 2.5,
      );
    } else {
      final pxPerUnit = size.width / range;
      final firstTick =
          ((value - range / 2) / _tickInterval).floor() * _tickInterval;
      var tick = firstTick;
      while (tick <= value + range / 2) {
        final x = size.width / 2 + (tick - value) * pxPerUnit;
        if (x >= 0 && x <= size.width) {
          final isMajor = (tick % (_tickInterval * 5)).abs() < 0.001;
          final tStyle = isMajor ? _tokens.majorTick : _tokens.minorTick;
          canvas.drawLine(
            Offset(x, 0),
            Offset(x, tStyle.length),
            Paint()
              ..color = tStyle.color
              ..strokeWidth = tStyle.strokeWidth,
          );
          if (isMajor) {
            final tp = TextPainter(
              text: TextSpan(text: _fmt(tick), style: _tokens.labelStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            paintTextOnCanvas(canvas, tp, Offset(x - tp.width / 2, tStyle.length + 2));
          }
        }
        tick += _tickInterval;
      }

      // Center marker
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, _tokens.majorTick.length + 4),
        Paint()
          ..color = _tokens.valueColor
          ..strokeWidth = 2.5,
      );
    }

    // Current value badge
    if (_unit != null) {
      final label = '${_fmt(value)} $_unit';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: _tokens.labelStyle.copyWith(
            color: _tokens.valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (_vertical) {
        paintTextOnCanvas(canvas, tp, Offset(4, size.height / 2 - tp.height / 2));
      } else {
        paintTextOnCanvas(canvas, tp, Offset(size.width / 2 - tp.width / 2, size.height - tp.height - 4));
      }
    }

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
