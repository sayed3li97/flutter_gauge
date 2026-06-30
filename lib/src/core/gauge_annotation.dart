import 'package:flutter/widgets.dart';

/// Pins a Flutter [Widget] at a specific [value] position on a [RadialGauge].
///
/// Annotations are laid out by the gauge wrapper widget using [LayoutBuilder]
/// so no external sizing is needed. Use [radiusFraction] to control how far
/// from the centre the annotation appears, and [offset] for fine-tuning.
///
/// ```dart
/// RadialGauge(
///   controller: myCtrl,
///   annotations: [
///     GaugeAnnotation(
///       value: 75,
///       radiusFraction: 0.55,
///       widget: const Icon(Icons.warning, color: Colors.orange, size: 18),
///     ),
///   ],
/// )
/// ```
class GaugeAnnotation {
  const GaugeAnnotation({
    required this.value,
    required this.widget,
    this.radiusFraction = 0.65,
    this.offset = Offset.zero,
  });

  /// Value on the gauge scale at which the widget is anchored.
  ///
  /// Clamped to [min, max] at render time.
  final double value;

  /// The widget to display at the resolved angular position.
  final Widget widget;

  /// Fraction of the track radius at which the annotation is placed.
  ///
  /// `0.0` = gauge centre; `1.0` = track arc. Defaults to `0.65`.
  final double radiusFraction;

  /// Additional pixel offset applied after the angular position is resolved.
  final Offset offset;
}
