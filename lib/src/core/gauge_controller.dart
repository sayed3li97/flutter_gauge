import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Controls the current value of a gauge widget.
///
/// [GaugeController] extends [ChangeNotifier] so that any widget listening to
/// it will rebuild whenever [value] changes.
///
/// Typical usage:
/// ```dart
/// final controller = GaugeController(initialValue: 0.0);
/// await controller.animateTo(0.75);
/// controller.dispose();
/// ```
class GaugeController extends ChangeNotifier {
  /// Creates a [GaugeController] with an optional [initialValue].
  ///
  /// [initialValue] defaults to `0.0`.
  GaugeController({double initialValue = 0.0}) : _value = initialValue;

  double _value;

  /// The current value of the gauge.
  ///
  /// Setting this property directly cancels any running animation and
  /// immediately notifies listeners.
  double get value => _value;

  set value(double newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  /// The ticker used to drive the current animation, if any.
  Ticker? _ticker;

  /// Animates [value] from its current level to [target].
  ///
  /// The animation runs over [duration] (default 600 ms) and follows [curve]
  /// (default [Curves.easeInOut]). Any previously running animation is
  /// cancelled before the new one starts.
  ///
  /// Returns a [Future] that completes when the animation reaches [target].
  ///
  /// ```dart
  /// await controller.animateTo(0.9, duration: Duration(seconds: 1));
  /// ```
  Future<void> animateTo(
    double target, {
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOut,
  }) {
    _ticker?.dispose();
    _ticker = null;
    final start = _value;
    final completer = Completer<void>();
    _ticker = Ticker((elapsed) {
      final t =
          (elapsed.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);
      value = start + (target - start) * curve.transform(t);
      if (t >= 1.0) {
        _ticker?.dispose();
        _ticker = null;
        if (!completer.isCompleted) completer.complete();
      }
    })..start();
    return completer.future;
  }

  /// Stops any animation that is currently running.
  ///
  /// The gauge [value] is left at whatever level it had reached when the
  /// animation was stopped.
  void stopAnimation() {
    _ticker?.dispose();
    _ticker = null;
  }

  /// Releases all resources used by this controller.
  ///
  /// Must be called when the controller is no longer needed. Cancels any
  /// in-flight animation before delegating to [ChangeNotifier.dispose].
  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}
