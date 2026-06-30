import 'package:flutter/painting.dart';
import 'gauge_controller.dart';

/// An additional needle that can be overlaid on a [RadialGauge].
///
/// Use [RadialGauge.extraPointers] to add one or more secondary needles,
/// for example to show a speed limit, a target value, or a min/max marker.
///
/// ```dart
/// RadialGauge(
///   controller: speedCtrl,
///   min: 0, max: 200,
///   extraPointers: [
///     GaugePointer(
///       controller: limitCtrl,
///       color: Colors.red,
///       label: 'Speed limit',
///     ),
///   ],
/// )
/// ```
class GaugePointer {
  /// Creates a gauge pointer.
  const GaugePointer({
    required this.controller,
    this.color,
    this.strokeWidth,
    this.lengthFraction = 0.75,
    this.label,
  });

  /// The controller that drives this pointer's angular position.
  final GaugeController controller;

  /// Needle colour. Defaults to the gauge token needle colour at 70% opacity.
  final Color? color;

  /// Needle stroke width. Defaults to the gauge token needle width.
  final double? strokeWidth;

  /// Fraction of the gauge radius that the needle extends to (0.0–1.0).
  /// Defaults to 0.75, which places the tip slightly inside the main needle.
  final double lengthFraction;

  /// Semantic label for this pointer, announced by screen readers.
  final String? label;
}
