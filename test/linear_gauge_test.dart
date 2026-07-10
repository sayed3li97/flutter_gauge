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

    testWidgets('renders with valueGradient and barRadius without error',
        (tester) async {
      final ctrl = GaugeController(initialValue: 65);
      const style = DefaultGaugeStyle();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 20,
              child: LinearGauge(
                controller: ctrl,
                barRadius: 10,
                style: style.override(
                  const GaugeTokensOverride(
                    valueGradient: LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      ctrl.dispose();
    });
  });
}
