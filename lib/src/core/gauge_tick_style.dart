import 'package:flutter/painting.dart';

class GaugeTickStyle {
  const GaugeTickStyle({
    required this.color,
    required this.strokeWidth,
    required this.length,
  });

  final Color color;
  final double strokeWidth;
  final double length;

  GaugeTickStyle copyWith({
    Color? color,
    double? strokeWidth,
    double? length,
  }) {
    return GaugeTickStyle(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      length: length ?? this.length,
    );
  }

  static GaugeTickStyle lerp(
    GaugeTickStyle a,
    GaugeTickStyle b,
    double t,
  ) {
    return GaugeTickStyle(
      color: Color.lerp(a.color, b.color, t)!,
      strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t),
      length: lerpDouble(a.length, b.length, t),
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
