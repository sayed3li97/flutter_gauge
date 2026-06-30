import 'package:flutter/painting.dart';

/// A colored band painted on the gauge track between [min] and [max].
///
/// Ranges are drawn beneath the needle/pointer layer so they do not obscure
/// the current value. Multiple non-overlapping ranges are supported, and they
/// are rendered in list order (first range is painted first).
///
/// Example — danger zone on a temperature gauge:
/// ```dart
/// GaugeRange(min: 80, max: 100, color: Colors.red, label: 'Danger')
/// ```
class GaugeRange {
  /// Creates a [GaugeRange].
  ///
  /// [min] must be strictly less than [max].
  const GaugeRange({
    required this.min,
    required this.max,
    required this.color,
    this.label,
  }) : assert(min < max, 'GaugeRange.min must be less than GaugeRange.max');

  /// The lower bound of the range, in the same unit as the gauge's `min`/`max`.
  ///
  /// Must be strictly less than [max].
  final double min;

  /// The upper bound of the range, in the same unit as the gauge's `min`/`max`.
  ///
  /// Must be strictly greater than [min].
  final double max;

  /// The fill color used when painting this band on the gauge track.
  ///
  /// Semi-transparent colors are supported and will blend with the track
  /// color beneath them.
  final Color color;

  /// Optional human-readable label for this range.
  ///
  /// When provided, some gauge styles render this text adjacent to the band
  /// (e.g. "Normal", "Warning", "Critical"). It is also surfaced in the
  /// widget's semantics tree so screen readers can describe range boundaries.
  final String? label;

  /// Returns a copy of this range with the given fields replaced.
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
