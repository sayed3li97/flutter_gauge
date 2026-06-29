import 'package:flutter/animation.dart';

/// Configuration for value-change animations.
class GaugeAnimation {
  const GaugeAnimation({
    required this.duration,
    required this.curve,
  });

  const GaugeAnimation.ambient()
      : duration = const Duration(milliseconds: 600),
        curve = Curves.easeInOut;

  const GaugeAnimation.instrument()
      : duration = const Duration(milliseconds: 300),
        curve = Curves.easeOut;

  final Duration duration;
  final Curve curve;
}
