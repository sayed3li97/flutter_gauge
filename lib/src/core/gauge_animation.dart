import 'package:flutter/animation.dart';

/// Immutable configuration for a gauge value-change animation.
///
/// [GaugeAnimation] bundles a [Duration] and a [Curve] so that animation
/// parameters can be passed as a single object and stored in [GaugeTokens].
///
/// Two named constructors provide ready-made presets that match the two
/// [GaugeMode] variants:
///
/// ```dart
/// // 600 ms easeInOut — matches GaugeMode.ambient
/// const GaugeAnimation.ambient()
///
/// // 300 ms easeOut — matches GaugeMode.instrument
/// const GaugeAnimation.instrument()
/// ```
///
/// To supply a fully custom animation pass an explicit [duration] and [curve]:
///
/// ```dart
/// const GaugeAnimation(
///   duration: Duration(milliseconds: 450),
///   curve: Curves.bounceOut,
/// )
/// ```
class GaugeAnimation {
  /// Creates a [GaugeAnimation] with an explicit [duration] and [curve].
  const GaugeAnimation({
    required this.duration,
    required this.curve,
  });

  /// Preset that matches [GaugeMode.ambient]: 600 ms, [Curves.easeInOut].
  ///
  /// Use for dashboard tiles and consumer UIs where a smooth, leisurely
  /// transition feels natural.
  const GaugeAnimation.ambient()
      : duration = const Duration(milliseconds: 600),
        curve = Curves.easeInOut;

  /// Preset that matches [GaugeMode.instrument]: 300 ms, [Curves.easeOut].
  ///
  /// Use for cockpit and industrial panels where a snappy response to data
  /// changes is more important than visual smoothness.
  const GaugeAnimation.instrument()
      : duration = const Duration(milliseconds: 300),
        curve = Curves.easeOut;

  /// How long the value-change transition takes.
  ///
  /// Shorter durations feel more responsive; longer durations feel smoother.
  /// The [GaugeMode.ambient] preset uses 600 ms and [GaugeMode.instrument]
  /// uses 300 ms.
  final Duration duration;

  /// The easing curve applied to the value interpolation.
  ///
  /// Any [Curve] from [Curves] or a custom implementation is accepted.
  /// [Curves.easeInOut] is used by the ambient preset; [Curves.easeOut] is
  /// used by the instrument preset.
  final Curve curve;
}
