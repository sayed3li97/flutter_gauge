import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_range.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';

enum LinearGaugeOrientation { horizontal, vertical }

/// Render engine for [LinearGauge].
class LinearGaugeRenderBox extends RenderBox {
  LinearGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required LinearGaugeOrientation orientation,
    required List<GaugeRange> ranges,
    required int majorDivisions,
    required bool showLabels,
    required bool showTicks,
    String? semanticsLabel,
    bool reverse = false,
    bool showValue = false,
    String? unitText,
    String Function(double)? labelFormatter,
    double? barRadius,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _orientation = orientation,
        _ranges = ranges,
        _majorDivisions = majorDivisions,
        _showLabels = showLabels,
        _showTicks = showTicks,
        _semanticsLabel = semanticsLabel,
        _reverse = reverse,
        _showValue = showValue,
        _unitText = unitText,
        _labelFormatter = labelFormatter,
        _barRadius = barRadius {
    _controller.addListener(_onValueChanged);
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  LinearGaugeOrientation _orientation;
  List<GaugeRange> _ranges;
  int _majorDivisions;
  bool _showLabels;
  bool _showTicks;
  String? _semanticsLabel;
  bool _reverse;
  bool _showValue;
  String? _unitText;
  String Function(double)? _labelFormatter;
  double? _barRadius;

  ui.Picture? _staticPicture;
  Size _staticSize = Size.zero;

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
    _staticPicture = null;
    markNeedsPaint();
  }

  set ranges(List<GaugeRange> v) {
    _ranges = v;
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

  set orientation(LinearGaugeOrientation v) {
    if (_orientation == v) return;
    _orientation = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set majorDivisions(int v) {
    if (_majorDivisions == v) return;
    _majorDivisions = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set showLabels(bool v) {
    if (_showLabels == v) return;
    _showLabels = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set showTicks(bool v) {
    if (_showTicks == v) return;
    _showTicks = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set reverse(bool v) {
    if (_reverse == v) return;
    _reverse = v;
    markNeedsPaint();
  }

  set showValue(bool v) {
    if (_showValue == v) return;
    _showValue = v;
    markNeedsPaint();
  }

  set unitText(String? v) {
    if (_unitText == v) return;
    _unitText = v;
    markNeedsPaint();
  }

  set labelFormatter(String Function(double)? v) {
    _labelFormatter = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set barRadius(double? v) {
    if (_barRadius == v) return;
    _barRadius = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? 'Linear gauge'
      ..value = _fmtWithUnit(_controller.value)
      ..textDirection = TextDirection.ltr;
  }

  @override
  void performLayout() {
    if (_orientation == LinearGaugeOrientation.horizontal) {
      size = constraints.constrain(
          Size(constraints.maxWidth, _tokens.trackStrokeWidth + 40));
    } else {
      size = constraints.constrain(
          Size(_tokens.trackStrokeWidth + 40, constraints.maxHeight));
    }
  }

  bool get _isHorizontal => _orientation == LinearGaugeOrientation.horizontal;

  String _fmtLabel(double v) {
    if (_labelFormatter != null) return _labelFormatter!(v);
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v.toStringAsFixed(1);
  }

  String _fmtWithUnit(double v) {
    final s = _fmtLabel(v);
    return _unitText != null ? '$s $_unitText' : s;
  }

  void _rebuildStaticPicture(Size sz) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final trackW = _tokens.trackStrokeWidth;
    final isH = _isHorizontal;
    // Use a non-nullable radius; useRRect drives the rendering mode.
    final bRadius = _barRadius ?? 0.0;
    final useRRect = bRadius > 0;

    if (isH) {
      final left = trackW / 2 + 4;
      final right = sz.width - trackW / 2 - 4;
      final cy = sz.height / 2;

      if (useRRect) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(left - trackW / 2, cy - trackW / 2,
                right + trackW / 2, cy + trackW / 2),
            Radius.circular(bRadius),
          ),
          Paint()
            ..color = _tokens.trackColor
            ..style = PaintingStyle.fill,
        );
        final trackLen = right - left;
        for (final range in _ranges) {
          final rF = valueToFraction(range.min, _min, _max);
          final rE = valueToFraction(range.max, _min, _max);
          canvas.drawRect(
            Rect.fromLTRB(left + rF * trackLen, cy - trackW / 2,
                left + rE * trackLen, cy + trackW / 2),
            Paint()
              ..color = range.color
              ..style = PaintingStyle.fill,
          );
        }
      } else {
        canvas.drawLine(
          Offset(left, cy),
          Offset(right, cy),
          Paint()
            ..color = _tokens.trackColor
            ..strokeWidth = trackW
            ..strokeCap = _tokens.trackStrokeCap
            ..style = PaintingStyle.stroke,
        );
        final trackLen = right - left;
        for (final range in _ranges) {
          final rF = valueToFraction(range.min, _min, _max);
          final rE = valueToFraction(range.max, _min, _max);
          canvas.drawLine(
            Offset(left + rF * trackLen, cy),
            Offset(left + rE * trackLen, cy),
            Paint()
              ..color = range.color
              ..strokeWidth = trackW
              ..strokeCap = StrokeCap.butt
              ..style = PaintingStyle.stroke,
          );
        }
      }

      if (_showTicks && _majorDivisions > 0) {
        final trackLen = right - left;
        final tickPaint = Paint()
          ..color = _tokens.majorTick.color
          ..strokeWidth = _tokens.majorTick.strokeWidth
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i <= _majorDivisions; i++) {
          final t = i / _majorDivisions;
          final val = _min + t * (_max - _min);
          final x = left + t * trackLen;
          canvas.drawLine(
            Offset(x, cy - _tokens.majorTick.length),
            Offset(x, cy + trackW / 2 + 2),
            tickPaint,
          );
          if (_showLabels) {
            final tp = TextPainter(
              text: TextSpan(text: _fmtLabel(val), style: _tokens.labelStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            tp.paint(canvas, Offset(x - tp.width / 2, cy + trackW / 2 + 6));
          }
        }
      }
    } else {
      final top = trackW / 2 + 4;
      final bottom = sz.height - trackW / 2 - 4;
      final cx = sz.width / 2;

      if (useRRect) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(cx - trackW / 2, top - trackW / 2,
                cx + trackW / 2, bottom + trackW / 2),
            Radius.circular(bRadius),
          ),
          Paint()
            ..color = _tokens.trackColor
            ..style = PaintingStyle.fill,
        );
        final trackLen = bottom - top;
        for (final range in _ranges) {
          final rF = valueToFraction(range.min, _min, _max);
          final rE = valueToFraction(range.max, _min, _max);
          canvas.drawRect(
            Rect.fromLTRB(cx - trackW / 2, top + rF * trackLen,
                cx + trackW / 2, top + rE * trackLen),
            Paint()
              ..color = range.color
              ..style = PaintingStyle.fill,
          );
        }
      } else {
        canvas.drawLine(
          Offset(cx, top),
          Offset(cx, bottom),
          Paint()
            ..color = _tokens.trackColor
            ..strokeWidth = trackW
            ..strokeCap = _tokens.trackStrokeCap
            ..style = PaintingStyle.stroke,
        );
        final trackLen = bottom - top;
        for (final range in _ranges) {
          final rF = valueToFraction(range.min, _min, _max);
          final rE = valueToFraction(range.max, _min, _max);
          canvas.drawLine(
            Offset(cx, top + rF * trackLen),
            Offset(cx, top + rE * trackLen),
            Paint()
              ..color = range.color
              ..strokeWidth = trackW
              ..strokeCap = StrokeCap.butt
              ..style = PaintingStyle.stroke,
          );
        }
      }

      if (_showTicks && _majorDivisions > 0) {
        final trackLen = bottom - top;
        final tickPaint = Paint()
          ..color = _tokens.majorTick.color
          ..strokeWidth = _tokens.majorTick.strokeWidth
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i <= _majorDivisions; i++) {
          final t = i / _majorDivisions;
          final val = _min + t * (_max - _min);
          final y = top + t * trackLen;
          canvas.drawLine(
            Offset(cx - _tokens.majorTick.length, y),
            Offset(cx + trackW / 2 + 2, y),
            tickPaint,
          );
          if (_showLabels) {
            final tp = TextPainter(
              text: TextSpan(text: _fmtLabel(val), style: _tokens.labelStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            tp.paint(canvas, Offset(cx + trackW / 2 + 6, y - tp.height / 2));
          }
        }
      }
    }

    _staticPicture = recorder.endRecording();
    _staticSize = sz;
  }

  void _paintGlow(Canvas canvas) {
    final glowR = _tokens.valueGlowRadius;
    if (glowR <= 0) return;
    final glowColor =
        _tokens.valueGlowColor ?? _tokens.valueColor.withValues(alpha: 0.5);
    final gp = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowR);
    _paintBar(canvas, gp);
  }

  void _paintBar(Canvas canvas, Paint paint) {
    final trackW = _tokens.trackStrokeWidth;
    final isH = _isHorizontal;
    final bRadius = _barRadius ?? 0.0;
    final useRRect = bRadius > 0;
    final frac = valueToFraction(_controller.value, _min, _max);
    final effectiveFrac = _reverse ? 1.0 - frac : frac;

    if (isH) {
      final left = trackW / 2 + 4;
      final right = size.width - trackW / 2 - 4;
      final cy = size.height / 2;
      final trackLen = right - left;
      final barStart = _reverse ? left + effectiveFrac * trackLen : left;
      final barEnd = _reverse ? right : left + effectiveFrac * trackLen;
      if (useRRect) {
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(barStart, cy - trackW / 2, barEnd, cy + trackW / 2),
            Radius.circular(bRadius),
          ),
          paint,
        );
      } else {
        paint.strokeWidth = trackW;
        paint.strokeCap = _tokens.trackStrokeCap;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(barStart, cy), Offset(barEnd, cy), paint);
      }
    } else {
      final top = trackW / 2 + 4;
      final bottom = size.height - trackW / 2 - 4;
      final cx = size.width / 2;
      final trackLen = bottom - top;
      final barStart = _reverse ? top + effectiveFrac * trackLen : top;
      final barEnd = _reverse ? bottom : top + effectiveFrac * trackLen;
      if (useRRect) {
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(cx - trackW / 2, barStart, cx + trackW / 2, barEnd),
            Radius.circular(bRadius),
          ),
          paint,
        );
      } else {
        paint.strokeWidth = trackW;
        paint.strokeCap = _tokens.trackStrokeCap;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(cx, barStart), Offset(cx, barEnd), paint);
      }
    }
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

    final frac = valueToFraction(_controller.value, _min, _max);
    if (frac > 0) {
      _paintGlow(canvas);
      _paintBar(canvas, Paint()..color = _tokens.valueColor);
    }

    // Value label above the bar tip
    if (_showValue && frac > 0) {
      final trackW = _tokens.trackStrokeWidth;
      final isH = _isHorizontal;
      final effectiveFrac = _reverse ? 1.0 - frac : frac;

      final label = _fmtWithUnit(_controller.value);
      final tp = TextPainter(
        text: TextSpan(text: label, style: _tokens.labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final rec = ui.PictureRecorder();
      tp.paint(Canvas(rec), Offset.zero);
      final pic = rec.endRecording();
      canvas.save();
      if (isH) {
        final left = trackW / 2 + 4;
        final right = size.width - trackW / 2 - 4;
        final cy = size.height / 2;
        final trackLen = right - left;
        final tipX = _reverse
            ? left + effectiveFrac * trackLen
            : left + effectiveFrac * trackLen;
        canvas.translate(
          tipX - tp.width / 2,
          cy - trackW / 2 - tp.height - 2,
        );
      } else {
        final top = trackW / 2 + 4;
        final bottom = size.height - trackW / 2 - 4;
        final cx = size.width / 2;
        final trackLen = bottom - top;
        final tipY = top + effectiveFrac * trackLen;
        canvas.translate(cx + trackW / 2 + 4, tipY - tp.height / 2);
      }
      canvas.drawPicture(pic);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    super.dispose();
  }
}
