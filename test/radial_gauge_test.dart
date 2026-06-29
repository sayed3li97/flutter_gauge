import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('RadialGauge widget', () {
    testWidgets('renders without error', (tester) async {
      final ctrl = GaugeController(initialValue: 50);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 200,
              child: RadialGauge(controller: ctrl),
            ),
          ),
        ),
      );
      expect(find.byType(RadialGauge), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('speedometer preset renders', (tester) async {
      final ctrl = GaugeController(initialValue: 80);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 200,
              child: RadialGauge.speedometer(controller: ctrl),
            ),
          ),
        ),
      );
      expect(find.byType(RadialGauge), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('updates when controller value changes', (tester) async {
      final ctrl = GaugeController(initialValue: 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 200,
              child: RadialGauge(controller: ctrl),
            ),
          ),
        ),
      );
      ctrl.value = 75;
      await tester.pump();
      expect(find.byType(RadialGauge), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('applies GaugeThemeExtension', (tester) async {
      final ctrl = GaugeController(initialValue: 50);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [
              const GaugeThemeExtension(
                style: ExecutiveGaugeStyle(),
                defaultMode: GaugeMode.instrument,
              ),
            ],
          ),
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 200,
              child: RadialGauge(controller: ctrl),
            ),
          ),
        ),
      );
      expect(find.byType(RadialGauge), findsOneWidget);
      ctrl.dispose();
    });
  });
}
