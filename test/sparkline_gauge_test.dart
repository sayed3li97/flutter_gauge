import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('SparklineController', () {
    test('starts empty by default', () {
      final c = SparklineController();
      expect(c.samples, isEmpty);
      expect(c.latest, isNull);
      c.dispose();
    });

    test('addSample appends and notifies listeners', () {
      final c = SparklineController();
      var notified = false;
      c.addListener(() => notified = true);
      c.addSample(1.0);
      expect(c.samples, [1.0]);
      expect(c.latest, 1.0);
      expect(notified, isTrue);
      c.dispose();
    });

    test('drops oldest sample once capacity is exceeded', () {
      final c = SparklineController(capacity: 3);
      c.addSample(1);
      c.addSample(2);
      c.addSample(3);
      c.addSample(4);
      expect(c.samples, [2, 3, 4]);
      c.dispose();
    });

    test('initialSamples longer than capacity is truncated to the tail', () {
      final c = SparklineController(capacity: 2, initialSamples: [1, 2, 3]);
      expect(c.samples, [2, 3]);
      c.dispose();
    });

    test('clear empties history and can reseed it', () {
      final c = SparklineController(initialSamples: [1, 2, 3]);
      c.clear(values: [9]);
      expect(c.samples, [9]);
      c.dispose();
    });
  });

  group('SparklineGauge widget', () {
    testWidgets('renders with fewer than 2 samples without error',
        (tester) async {
      final c = SparklineController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 40,
            width: 120,
            child: SparklineGauge(controller: c),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('renders with a flat sample window without error',
        (tester) async {
      final c = SparklineController(initialSamples: [5, 5, 5, 5]);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 40,
            width: 120,
            child: SparklineGauge(controller: c),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('repaints when a new sample is added', (tester) async {
      final c = SparklineController(initialSamples: [1, 2, 3]);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 40,
            width: 120,
            child: SparklineGauge(controller: c),
          ),
        ),
      ));
      c.addSample(10);
      await tester.pump();
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });
  });
}
