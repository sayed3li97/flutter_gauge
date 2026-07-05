import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('Smoke tests — all 15 gauge types render without error', () {
    testWidgets('RadialGauge', (tester) async {
      final c = GaugeController(initialValue: 50);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 200,
                  width: 200,
                  child: RadialGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('LinearGauge', (tester) async {
      final c = GaugeController(initialValue: 50);
      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: LinearGauge(controller: c))));
      addTearDown(c.dispose);
    });

    testWidgets('SegmentedGauge', (tester) async {
      final c = GaugeController(initialValue: 50);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body:
                  SizedBox(height: 28, child: SegmentedGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('ArcGauge', (tester) async {
      final c = GaugeController(initialValue: 50);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 200, width: 200, child: ArcGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('ThermometerGauge', (tester) async {
      final c = GaugeController(initialValue: 22);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 200, child: ThermometerGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('BulletGauge', (tester) async {
      final c = GaugeController(initialValue: 72);
      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: BulletGauge(controller: c))));
      addTearDown(c.dispose);
    });

    testWidgets('TankGauge', (tester) async {
      final c = GaugeController(initialValue: 60);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 200, width: 60, child: TankGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('InclinometerGauge', (tester) async {
      final c = GaugeController(initialValue: 5);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 60, child: InclinometerGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('StatusGauge', (tester) async {
      final c = GaugeController(initialValue: 0);
      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: StatusGauge(controller: c))));
      addTearDown(c.dispose);
    });

    testWidgets('DeltaGauge', (tester) async {
      final c = GaugeController(initialValue: 75);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: DeltaGauge(controller: c, baseline: 50))));
      addTearDown(c.dispose);
    });

    testWidgets('ArtificialHorizonGauge', (tester) async {
      final pitch = GaugeController(initialValue: 5);
      final roll = GaugeController(initialValue: 10);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 200,
                  width: 200,
                  child: ArtificialHorizonGauge(
                    pitchController: pitch,
                    rollController: roll,
                  )))));
      addTearDown(() {
        pitch.dispose();
        roll.dispose();
      });
    });

    testWidgets('OdometerGauge', (tester) async {
      final c = GaugeController(initialValue: 12345.6);
      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: OdometerGauge(controller: c))));
      addTearDown(c.dispose);
    });

    testWidgets('LevelMeterGauge', (tester) async {
      final c = GaugeController(initialValue: 70);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 200, child: LevelMeterGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('TapeGauge', (tester) async {
      final c = GaugeController(initialValue: 3500);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(height: 200, child: TapeGauge(controller: c)))));
      addTearDown(c.dispose);
    });

    testWidgets('SparklineGauge', (tester) async {
      final c =
          SparklineController(capacity: 20, initialSamples: [1, 3, 2, 5, 4, 6]);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  height: 40,
                  width: 120,
                  child: SparklineGauge(controller: c)))));
      addTearDown(c.dispose);
    });
  });
}
