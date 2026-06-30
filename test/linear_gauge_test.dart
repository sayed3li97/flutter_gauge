import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('LinearGauge widget', () {
    testWidgets('renders without error', (tester) async {
      final ctrl = GaugeController(initialValue: 40);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearGauge(controller: ctrl),
          ),
        ),
      );
      expect(find.byType(LinearGauge), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('progress preset renders', (tester) async {
      final ctrl = GaugeController(initialValue: 70);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearGauge.progress(controller: ctrl),
          ),
        ),
      );
      expect(find.byType(LinearGauge), findsOneWidget);
      ctrl.dispose();
    });
  });
}
