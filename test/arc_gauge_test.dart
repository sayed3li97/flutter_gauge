import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('ArcGauge widget', () {
    testWidgets('renders without error', (tester) async {
      final ctrl = GaugeController(initialValue: 50);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 200,
              child: ArcGauge(controller: ctrl),
            ),
          ),
        ),
      );
      expect(find.byType(ArcGauge), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('cpu usage preset renders', (tester) async {
      final ctrl = GaugeController(initialValue: 80);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 200,
              child: ArcGauge.cpuUsage(controller: ctrl),
            ),
          ),
        ),
      );
      expect(find.byType(ArcGauge), findsOneWidget);
      ctrl.dispose();
    });
  });
}
