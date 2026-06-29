import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('GaugeMode', () {
    test('has ambient and instrument values', () {
      expect(GaugeMode.values, contains(GaugeMode.ambient));
      expect(GaugeMode.values, contains(GaugeMode.instrument));
      expect(GaugeMode.values.length, 2);
    });
  });
}
