import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('GaugeRange', () {
    test('creates with valid min/max', () {
      const r = GaugeRange(min: 0, max: 100, color: Color(0xFF0077BB));
      expect(r.min, 0);
      expect(r.max, 100);
    });

    test('copyWith replaces fields', () {
      const r = GaugeRange(min: 0, max: 100, color: Color(0xFF0077BB));
      final r2 = r.copyWith(max: 200);
      expect(r2.max, 200);
      expect(r2.min, 0);
    });

    test('label is optional', () {
      const r = GaugeRange(min: 0, max: 50, color: Color(0xFFEE7733));
      expect(r.label, isNull);
    });

    test('label can be set', () {
      const r =
          GaugeRange(min: 0, max: 50, color: Color(0xFFEE7733), label: 'Low');
      expect(r.label, 'Low');
    });
  });
}
