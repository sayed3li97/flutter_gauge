import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('valueToAngle', () {
    const start = 0.0;
    const sweep = math.pi * 2;

    test('min value → startAngle', () {
      expect(valueToAngle(0, 0, 100, start, sweep), closeTo(start, 0.001));
    });

    test('max value → startAngle + sweepAngle', () {
      expect(valueToAngle(100, 0, 100, start, sweep),
          closeTo(start + sweep, 0.001));
    });

    test('mid value → midpoint angle', () {
      expect(valueToAngle(50, 0, 100, start, sweep),
          closeTo(start + sweep / 2, 0.001));
    });

    test('clamps below min', () {
      expect(valueToAngle(-10, 0, 100, start, sweep), closeTo(start, 0.001));
    });

    test('clamps above max', () {
      expect(valueToAngle(150, 0, 100, start, sweep),
          closeTo(start + sweep, 0.001));
    });
  });

  group('valueToFraction', () {
    test('min → 0', () => expect(valueToFraction(0, 0, 100), 0.0));
    test('max → 1', () => expect(valueToFraction(100, 0, 100), 1.0));
    test('mid → 0.5', () => expect(valueToFraction(50, 0, 100), 0.5));
    test('clamps below 0', () => expect(valueToFraction(-5, 0, 100), 0.0));
    test('clamps above 1', () => expect(valueToFraction(105, 0, 100), 1.0));
  });

  group('niceTick', () {
    test('returns positive value', () {
      expect(niceTick(100, targetDivisions: 5), greaterThan(0));
    });

    test('100 range / 5 divisions → 20', () {
      expect(niceTick(100, targetDivisions: 5), closeTo(20, 0.001));
    });

    test('1000 range / 10 divisions → 100', () {
      expect(niceTick(1000, targetDivisions: 10), closeTo(100, 0.001));
    });
  });

  group('degToRad', () {
    test('0 → 0', () => expect(degToRad(0), closeTo(0, 0.0001)));
    test('180 → π', () => expect(degToRad(180), closeTo(math.pi, 0.0001)));
    test('360 → 2π', () => expect(degToRad(360), closeTo(2 * math.pi, 0.0001)));
  });
}
