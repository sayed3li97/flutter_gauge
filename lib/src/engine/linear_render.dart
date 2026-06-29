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
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _orientation = orientation,
        _ranges = ranges,
        _majorDivisions = majorDivisions,
        _showLabels = showLabels,
        _showTicks = showTicks {
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

  void _rebuildStaticPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final trackW = _tokens.trackStrokeWidth;
    final isH = _isHorizontal;

    final trackStart = isH
        ? Offset(trackW / 2 + 4, size.height / 2)
        : Offset(size.width / 2, trackW / 2 + 4);
    final trackEnd = isH
        ? Offset(size.width - trackW / 2 - 4, size.height / 2)
        : Offset(size.width / 2, size.height - trackW / 2 - 4);
    final trackLength = isH
        ? trackEnd.dx - trackStart.dx
        : trackEnd.dy - trackStart.dy;

    // Background track
    final trackPaint = Paint()
      ..color = _tokens.trackColor
      ..strokeWidth = trackW
      ..strokeCap = _tokens.trackStrokeCap
      ..style = PaintingStyle.stroke;
    canvas.drawLine(trackStart, trackEnd, trackPaint);

    // Ranges
    for (final range in _ranges) {
      final rFrac = valueToFraction(range.min, _min, _max);
      final rEnd = valueToFraction(range.max, _min, _max);
      final rangePaint = Paint()
        ..color = range.color
        ..strokeWidth = trackW
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke;
      if (isH) {
        canvas.drawLine(
          Offset(trackStart.dx + rFrac * trackLength, trackStart.dy),
          Offset(trackStart.dx + rEnd * trackLength, trackEnd.dy),
          rangePaint,
        );
      } else {
        canvas.drawLine(
          Offset(trackStart.dx, trackStart.dy + rFrac * trackLength),
          Offset(trackEnd.dx, trackStart.dy + rEnd * trackLength),
          rangePaint,
        );
      }
    }

    // Ticks + labels
    if (_showTicks && _majorDivisions > 0) {
      final tickPaint = Paint()
        ..color = _tokens.majorTick.color
        ..strokeWidth = _tokens.majorTick.strokeWidth
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i <= _majorDivisions; i++) {
        final t = i / _majorDivisions;
        final val = _min + t * (_max - _min);
        final labelStr = _fmt(val);

        if (isH) {
          final x = trackStart.dx + t * trackLength;
          canvas.drawLine(
            Offset(x, trackStart.dy - _tokens.majorTick.length),
            Offset(x, trackStart.dy + trackW / 2 + 2),
            tickPaint,
          );
          if (_showLabels) {
            final tp = TextPainter(
              text: TextSpan(text: labelStr, style: _tokens.labelStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            tp.paint(
              canvas,
              Offset(
                x - tp.width / 2,
                trackStart.dy + trackW / 2 + 6,
              ),
            );
          }
        } else {
          final y = trackStart.dy + t * trackLength;
          canvas.drawLine(
            Offset(trackStart.dx - _tokens.majorTick.length, y),
            Offset(trackStart.dx + trackW / 2 + 2, y),
            tickPaint,
          );
          if (_showLabels) {
            final tp = TextPainter(
              text: TextSpan(text: labelStr, style: _tokens.labelStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            tp.paint(
              canvas,
              Offset(
                trackStart.dx + trackW / 2 + 6,
                y - tp.height / 2,
              ),
            );
          }
        }
      }
    }

    _staticPicture = recorder.endRecording();
    _staticSize = size;
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v.toStringAsFixed(1);
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

    // Dynamic: value bar
    final trackW = _tokens.trackStrokeWidth;
    final isH = _isHorizontal;

    final trackStart = isH
        ? Offset(trackW / 2 + 4, size.height / 2)
        : Offset(size.width / 2, trackW / 2 + 4);
    final trackEnd = isH
        ? Offset(size.width - trackW / 2 - 4, size.height / 2)
        : Offset(size.width / 2, size.height - trackW / 2 - 4);
    final trackLength = isH
        ? trackEnd.dx - trackStart.dx
        : trackEnd.dy - trackStart.dy;
    final frac = valueToFraction(_controller.value, _min, _max);

    final vPaint = Paint()
      ..color = _tokens.valueColor
      ..strokeWidth = trackW
      ..strokeCap = _tokens.trackStrokeCap
      ..style = PaintingStyle.stroke;

    if (frac > 0) {
      if (isH) {
        canvas.drawLine(
          trackStart,
          Offset(trackStart.dx + frac * trackLength, trackStart.dy),
          vPaint,
        );
      } else {
        canvas.drawLine(
          trackStart,
          Offset(trackStart.dx, trackStart.dy + frac * trackLength),
          vPaint,
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
