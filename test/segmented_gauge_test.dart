import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('SegmentedGauge widget', () {
    testWidgets('renders without error', (tester) async {
      final ctrl = GaugeController(initialValue: 60);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 40,
              child: SegmentedGauge(controller: ctrl),
            ),
          ),
        ),
      );
      expect(find.byType(SegmentedGauge), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('battery preset renders', (tester) async {
      final ctrl = GaugeController(initialValue: 80);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 40,
              child: SegmentedGauge.battery(controller: ctrl),
            ),
          ),
        ),
      );
      expect(find.byType(SegmentedGauge), findsOneWidget);
      ctrl.dispose();
    });
  });
}
