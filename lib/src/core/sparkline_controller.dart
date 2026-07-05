import 'package:flutter/foundation.dart';

/// Holds a rolling window of sample values for a [SparklineGauge].
///
/// Unlike [GaugeController], which represents a single live value,
/// [SparklineController] keeps a bounded history of discrete samples — the
/// data a sparkline needs to draw a trend line. Push a new reading with
/// [addSample]; once [capacity] is exceeded the oldest sample is dropped.
///
/// ```dart
/// final controller = SparklineController(capacity: 30);
/// Timer.periodic(const Duration(seconds: 1), (_) {
///   controller.addSample(readSensor());
/// });
/// ```
class SparklineController extends ChangeNotifier {
  /// Creates a [SparklineController].
  ///
  /// [capacity] is the maximum number of samples retained; must be `>= 1`.
  /// [initialSamples] seeds the history — if longer than [capacity], only the
  /// most recent [capacity] entries are kept.
  SparklineController({
    this.capacity = 50,
    List<double> initialSamples = const [],
  })  : assert(capacity >= 1, 'capacity must be at least 1'),
        _samples = initialSamples.length > capacity
            ? initialSamples.sublist(initialSamples.length - capacity)
            : List<double>.from(initialSamples);

  /// Maximum number of samples retained. Oldest samples are dropped once
  /// this is exceeded.
  final int capacity;

  final List<double> _samples;

  /// An unmodifiable view of the current sample history, oldest first.
  List<double> get samples => List.unmodifiable(_samples);

  /// The most recently added sample, or `null` if no samples exist yet.
  double? get latest => _samples.isEmpty ? null : _samples.last;

  /// Appends [value] to the history, dropping the oldest sample if
  /// [capacity] is exceeded, then notifies listeners.
  void addSample(double value) {
    _samples.add(value);
    if (_samples.length > capacity) {
      _samples.removeAt(0);
    }
    notifyListeners();
  }

  /// Clears all history, optionally seeding it with [values], then notifies
  /// listeners.
  void clear({List<double> values = const []}) {
    _samples
      ..clear()
      ..addAll(
        values.length > capacity
            ? values.sublist(values.length - capacity)
            : values,
      );
    notifyListeners();
  }
}
