import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('GaugeController', () {
    test('initializes with given value', () {
      final c = GaugeController(initialValue: 42.0);
      expect(c.value, 42.0);
      c.dispose();
    });

    test('notifies listeners on value change', () {
      final c = GaugeController(initialValue: 0);
      var notified = false;
      c.addListener(() => notified = true);
      c.value = 10;
      expect(notified, isTrue);
      c.dispose();
    });

    test('does not notify listeners when value unchanged', () {
      final c = GaugeController(initialValue: 5);
      var count = 0;
      c.addListener(() => count++);
      c.value = 5;
      expect(count, 0);
      c.dispose();
    });

    test('clamps are not applied by controller (widget responsibility)', () {
      final c = GaugeController(initialValue: 0);
      c.value = 200;
      expect(c.value, 200);
      c.dispose();
    });
  });
}
