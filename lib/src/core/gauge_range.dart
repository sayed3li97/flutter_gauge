import 'package:flutter/painting.dart';

/// A colored band on the gauge track, spanning [min, max].
class GaugeRange {
  const GaugeRange({
    required this.min,
    required this.max,
    required this.color,
    this.label,
  }) : assert(min < max, 'GaugeRange.min must be less than GaugeRange.max');

  final double min;
  final double max;
  final Color color;
  final String? label;

  GaugeRange copyWith({
    double? min,
    double? max,
    Color? color,
    String? label,
  }) {
    return GaugeRange(
      min: min ?? this.min,
      max: max ?? this.max,
      color: color ?? this.color,
      label: label ?? this.label,
    );
  }
}
