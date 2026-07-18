import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 220, height: 220, child: child),
        ),
      ),
    );

void main() {
  group('Value-only constructors (no controller, no dispose)', () {
    testWidgets('RadialGauge(value:) renders without a controller',
        (tester) async {
      await tester.pumpWidget(_host(
        const RadialGauge(value: 60, max: 200, showCenterLabel: true),
      ));
      expect(tester.takeException(), isNull);
      expect(find.byType(RadialGauge), findsOneWidget);
    });

    testWidgets('ArcGauge(value:) renders without a controller',
        (tester) async {
      await tester.pumpWidget(_host(const ArcGauge(value: 72, unitText: '%')));
      expect(tester.takeException(), isNull);
      expect(find.byType(ArcGauge), findsOneWidget);
    });

    testWidgets('LinearGauge(value:) renders without a controller',
        (tester) async {
      await tester.pumpWidget(_host(
        const SizedBox(height: 24, child: LinearGauge(value: 40)),
      ));
      expect(tester.takeException(), isNull);
      expect(find.byType(LinearGauge), findsOneWidget);
    });

    testWidgets('value change animates without error', (tester) async {
      await tester.pumpWidget(_host(const RadialGauge(value: 10, max: 100)));
      // Rebuild with a new value — the internal controller animates to it.
      await tester.pumpWidget(_host(const RadialGauge(value: 90, max: 100)));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700)); // finish animation
      expect(tester.takeException(), isNull);
    });

    testWidgets('unmounting a value-only gauge disposes cleanly (no leak)',
        (tester) async {
      await tester.pumpWidget(_host(const RadialGauge(value: 50, max: 100)));
      // Replace with an empty tree — the internal controller must dispose
      // without throwing.
      await tester.pumpWidget(_host(const SizedBox.shrink()));
      expect(tester.takeException(), isNull);
    });

    test('providing neither controller nor value throws an assertion', () {
      expect(() => RadialGauge(), throwsAssertionError);
      expect(() => ArcGauge(), throwsAssertionError);
      expect(() => LinearGauge(), throwsAssertionError);
    });

    test('providing both controller and value throws an assertion', () {
      final c = GaugeController(initialValue: 1);
      expect(() => RadialGauge(controller: c, value: 1), throwsAssertionError);
      expect(() => ArcGauge(controller: c, value: 1), throwsAssertionError);
      expect(() => LinearGauge(controller: c, value: 1), throwsAssertionError);
      c.dispose();
    });
  });
}
