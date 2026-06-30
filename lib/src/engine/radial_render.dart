import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/gauge_controller.dart';
import '../core/gauge_pointer.dart';
import '../core/gauge_range.dart';
import '../core/value_to_angle.dart';
import '../styles/gauge_tokens.dart';

/// Render engine for [RadialGauge]. Separates static and dynamic layers.
class RadialGaugeRenderBox extends RenderBox {
  RadialGaugeRenderBox({
    required GaugeController controller,
    required GaugeTokens tokens,
    required double min,
    required double max,
    required double startAngleDeg,
    required double sweepAngleDeg,
    required List<GaugeRange> ranges,
    required int majorDivisions,
    required int minorDivisions,
    required bool showLabels,
    required bool showNeedle,
    required bool interactive,
    required ValueChanged<double>? onChanged,
    bool showCenterLabel = false,
    String? centerLabel,
    TextStyle? centerLabelStyle,
    List<GaugePointer> extraPointers = const [],
    String? semanticsLabel,
  })  : _controller = controller,
        _tokens = tokens,
        _min = min,
        _max = max,
        _startAngleDeg = startAngleDeg,
        _sweepAngleDeg = sweepAngleDeg,
        _ranges = ranges,
        _majorDivisions = majorDivisions,
        _minorDivisions = minorDivisions,
        _showLabels = showLabels,
        _showNeedle = showNeedle,
        _interactive = interactive,
        _onChanged = onChanged,
        _showCenterLabel = showCenterLabel,
        _centerLabel = centerLabel,
        _centerLabelStyle = centerLabelStyle,
        _extraPointers = extraPointers,
        _semanticsLabel = semanticsLabel {
    _controller.addListener(_onValueChanged);
    for (final pointer in _extraPointers) {
      pointer.controller.addListener(_onValueChanged);
    }
  }

  final GaugeController _controller;
  GaugeTokens _tokens;
  double _min;
  double _max;
  final double _startAngleDeg;
  final double _sweepAngleDeg;
  List<GaugeRange> _ranges;
  int _majorDivisions;
  int _minorDivisions;
  bool _showLabels;
  bool _showNeedle;
  bool _interactive;
  ValueChanged<double>? _onChanged;
  bool _showCenterLabel;
  String? _centerLabel;
  TextStyle? _centerLabelStyle;
  List<GaugePointer> _extraPointers;
  String? _semanticsLabel;

  ui.Picture? _staticPicture;
  Size _staticSize = Size.zero;

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => false;

  void _onValueChanged() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  // Setters that invalidate static picture when structural props change.
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

  set majorDivisions(int v) {
    if (_majorDivisions == v) return;
    _majorDivisions = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set minorDivisions(int v) {
    if (_minorDivisions == v) return;
    _minorDivisions = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set showLabels(bool v) {
    if (_showLabels == v) return;
    _showLabels = v;
    _staticPicture = null;
    markNeedsPaint();
  }

  set showNeedle(bool v) {
    if (_showNeedle == v) return;
    _showNeedle = v;
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

  set interactive(bool v) {
    if (_interactive == v) return;
    _interactive = v;
    markNeedsPaint();
  }

  set onChanged(ValueChanged<double>? v) {
    _onChanged = v;
  }

  set showCenterLabel(bool v) {
    if (_showCenterLabel == v) return;
    _showCenterLabel = v;
    markNeedsPaint();
  }

  set centerLabel(String? v) {
    _centerLabel = v;
    markNeedsPaint();
  }

  set centerLabelStyle(TextStyle? v) {
    _centerLabelStyle = v;
    markNeedsPaint();
  }

  set extraPointers(List<GaugePointer> v) {
    // Remove listeners from old pointers.
    for (final pointer in _extraPointers) {
      pointer.controller.removeListener(_onValueChanged);
    }
    _extraPointers = v;
    // Add listeners to new pointers.
    for (final pointer in _extraPointers) {
      pointer.controller.addListener(_onValueChanged);
    }
    markNeedsPaint();
  }

  set semanticsLabel(String? v) {
    if (_semanticsLabel == v) return;
    _semanticsLabel = v;
    markNeedsSemanticsUpdate();
  }

  @override
  void performLayout() {
    final side = constraints.biggest.shortestSide;
    size = constraints.constrain(Size(side, side));
  }

  @override
  bool hitTestSelf(Offset position) => _interactive;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (!_interactive || _onChanged == null) return;
    final center = size.center(Offset.zero);
    final angle = (event.localPosition - center).direction;
    final startRad = degToRad(_startAngleDeg);
    final sweepRad = degToRad(_sweepAngleDeg);
    var t = (angle - startRad) / sweepRad;
    t = t.clamp(0.0, 1.0);
    _onChanged!(_min + t * (_max - _min));
  }

  void _rebuildStaticPicture(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _tokens.trackStrokeWidth / 2 - 2;

    final startRad = degToRad(_startAngleDeg);
    final sweepRad = degToRad(_sweepAngleDeg);

    // Track background
    final trackPaint = Paint()
      ..color = _tokens.trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _tokens.trackStrokeWidth
      ..strokeCap = _tokens.trackStrokeCap;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepRad,
      false,
      trackPaint,
    );

    // Colored ranges
    for (final range in _ranges) {
      final rStart = valueToAngle(range.min, _min, _max, startRad, sweepRad);
      final rSweep = valueToAngle(range.max, _min, _max, startRad, sweepRad) - rStart;
      final rangePaint = Paint()
        ..color = range.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _tokens.trackStrokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        rStart,
        rSweep,
        false,
        rangePaint,
      );
    }

    // Major ticks + labels
    if (_majorDivisions > 0) {
      final tickPaint = Paint()
        ..color = _tokens.majorTick.color
        ..strokeWidth = _tokens.majorTick.strokeWidth
        ..strokeCap = StrokeCap.round;

      final tickInner = radius - _tokens.majorTick.length;
      final tickOuter = radius + _tokens.trackStrokeWidth / 2 + 2;

      for (var i = 0; i <= _majorDivisions; i++) {
        final t = i / _majorDivisions;
        final angle = startRad + t * sweepRad;
        final cos = math.cos(angle);
        final sin = math.sin(angle);
        canvas.drawLine(
          Offset(center.dx + cos * tickInner, center.dy + sin * tickInner),
          Offset(center.dx + cos * tickOuter, center.dy + sin * tickOuter),
          tickPaint,
        );

        if (_showLabels) {
          final value = _min + t * (_max - _min);
          final label = _formatLabel(value);
          final tp = TextPainter(
            text: TextSpan(text: label, style: _tokens.labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          final labelR = radius - _tokens.majorTick.length - _tokens.labelOffset;
          final lx = center.dx + cos * labelR - tp.width / 2;
          final ly = center.dy + sin * labelR - tp.height / 2;
          tp.paint(canvas, Offset(lx, ly));
        }
      }

      // Minor ticks
      if (_minorDivisions > 0) {
        final mTickPaint = Paint()
          ..color = _tokens.minorTick.color
          ..strokeWidth = _tokens.minorTick.strokeWidth
          ..strokeCap = StrokeCap.round;
        final mTickInner = radius - _tokens.minorTick.length;

        for (var i = 0; i < _majorDivisions; i++) {
          for (var j = 1; j < _minorDivisions; j++) {
            final t2 = (i + j / _minorDivisions) / _majorDivisions;
            final angle = startRad + t2 * sweepRad;
            final cos = math.cos(angle);
            final sin = math.sin(angle);
            canvas.drawLine(
              Offset(
                  center.dx + cos * mTickInner, center.dy + sin * mTickInner),
              Offset(center.dx + cos * tickOuter, center.dy + sin * tickOuter),
              mTickPaint,
            );
          }
        }
      }
    }

    _staticPicture = recorder.endRecording();
    _staticSize = size;
  }

  String _formatLabel(double value) {
    if (value == value.truncateToDouble()) {
      return value.truncate().toString();
    }
    return value.toStringAsFixed(1);
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

    // Dynamic: value arc
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _tokens.trackStrokeWidth / 2 - 2;
    final startRad = degToRad(_startAngleDeg);
    final sweepRad = degToRad(_sweepAngleDeg);
    final valueAngle =
        valueToAngle(_controller.value, _min, _max, startRad, sweepRad);

    if (valueAngle > startRad) {
      final valueSweep = valueAngle - startRad;
      final rect = Rect.fromCircle(center: center, radius: radius);

      if (_tokens.valueGradient != null) {
        final shader = _tokens.valueGradient!.createShader(rect);
        final vPaint = Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = _tokens.valueStrokeWidth
          ..strokeCap = _tokens.trackStrokeCap;
        canvas.drawArc(rect, startRad, valueSweep, false, vPaint);
      } else {
        final vPaint = Paint()
          ..color = _tokens.valueColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _tokens.valueStrokeWidth
          ..strokeCap = _tokens.trackStrokeCap;
        canvas.drawArc(rect, startRad, valueSweep, false, vPaint);
      }
    }

    // Needle
    if (_showNeedle) {
      _paintNeedle(canvas, center, radius, valueAngle);
    }

    // Extra pointers — drawn after the main needle so they appear on top.
    for (final pointer in _extraPointers) {
      final pointerAngle =
          valueToAngle(pointer.controller.value, _min, _max, startRad, sweepRad);
      _paintExtraNeedle(canvas, center, radius, pointerAngle, pointer, _tokens);
    }

    // Center label — painted via PictureRecorder so text renders correctly in CanvasKit
    if (_showCenterLabel) {
      final labelText = _centerLabel ?? _formatLabel(_controller.value);
      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: _centerLabelStyle ??
              _tokens.labelStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final textRecorder = ui.PictureRecorder();
      tp.paint(Canvas(textRecorder), Offset.zero);
      final textPic = textRecorder.endRecording();
      canvas.save();
      canvas.translate(center.dx - tp.width / 2, center.dy - tp.height / 2);
      canvas.drawPicture(textPic);
      canvas.restore();
    }

    canvas.restore();
  }

  void _paintNeedle(
      Canvas canvas, Offset center, double radius, double valueAngle) {
    final cos = math.cos(valueAngle);
    final sin = math.sin(valueAngle);

    if (_tokens.needleDropShadow) {
      final shadowPaint = Paint()
        ..color = const Color(0x40000000)
        ..strokeWidth = _tokens.needleWidth + 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(
        Offset(center.dx - cos * _tokens.knobRadius * 0.5,
            center.dy - sin * _tokens.knobRadius * 0.5),
        Offset(center.dx + cos * radius * 0.85,
            center.dy + sin * radius * 0.85),
        shadowPaint,
      );
    }

    final needlePaint = Paint()
      ..color = _tokens.needleColor
      ..strokeWidth = _tokens.needleWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - cos * _tokens.knobRadius * 0.5,
          center.dy - sin * _tokens.knobRadius * 0.5),
      Offset(
          center.dx + cos * radius * 0.85, center.dy + sin * radius * 0.85),
      needlePaint,
    );

    // Knob
    final knobPaint = Paint()..color = _tokens.knobColor;
    canvas.drawCircle(center, _tokens.knobRadius, knobPaint);
    if (_tokens.knobBorderColor != null && _tokens.knobBorderWidth > 0) {
      final borderPaint = Paint()
        ..color = _tokens.knobBorderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = _tokens.knobBorderWidth;
      canvas.drawCircle(center, _tokens.knobRadius, borderPaint);
    }
  }

  void _paintExtraNeedle(
    Canvas canvas,
    Offset center,
    double radius,
    double valueAngle,
    GaugePointer pointer,
    GaugeTokens tokens,
  ) {
    final cos = math.cos(valueAngle);
    final sin = math.sin(valueAngle);
    final needleColor =
        pointer.color ?? tokens.needleColor.withValues(alpha: 0.7);
    final strokeWidth = pointer.strokeWidth ?? tokens.needleWidth * 0.8;
    final tipRadius = radius * pointer.lengthFraction;

    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + cos * tipRadius, center.dy + sin * tipRadius),
      needlePaint,
    );
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? 'Radial gauge'
      ..value = _formatLabel(_controller.value)
      ..isEnabled = _interactive
      ..textDirection = TextDirection.ltr;
    if (_interactive) {
      final step = (_max - _min) / 10;
      config.onIncrease = () {
        _onChanged?.call((_controller.value + step).clamp(_min, _max));
      };
      config.onDecrease = () {
        _onChanged?.call((_controller.value - step).clamp(_min, _max));
      };
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    for (final pointer in _extraPointers) {
      pointer.controller.removeListener(_onValueChanged);
    }
    super.dispose();
  }
}
