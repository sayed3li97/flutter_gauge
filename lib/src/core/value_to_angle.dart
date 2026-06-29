import 'dart:math' as math;

/// Maps [value] linearly onto the angular range [startAngle, startAngle + sweepAngle].
/// Angles are in radians. [value] is clamped to [min, max].
double valueToAngle(
  double value,
  double min,
  double max,
  double startAngle,
  double sweepAngle,
) {
  assert(max > min, 'max must be greater than min');
  final clamped = value.clamp(min, max);
  final t = (clamped - min) / (max - min);
  return startAngle + t * sweepAngle;
}

/// Maps [value] linearly to a fraction in [0, 1].
double valueToFraction(double value, double min, double max) {
  assert(max > min, 'max must be greater than min');
  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}

/// Computes a "nice" tick interval for [range] aiming for [targetDivisions].
/// Uses the Wilkinson-style algorithm: try 1, 2, 2.5, 5, 10 multipliers.
double niceTick(double range, {int targetDivisions = 5}) {
  if (range <= 0 || targetDivisions <= 0) return 1.0;
  final rawStep = range / targetDivisions;
  final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor());
  const niceFactors = [1.0, 2.0, 2.5, 5.0, 10.0];
  double bestStep = niceFactors.last * magnitude;
  for (final f in niceFactors) {
    final candidate = f * magnitude;
    if (candidate >= rawStep) {
      bestStep = candidate;
      break;
    }
  }
  return bestStep;
}

/// Degrees → radians.
double degToRad(double deg) => deg * math.pi / 180.0;
