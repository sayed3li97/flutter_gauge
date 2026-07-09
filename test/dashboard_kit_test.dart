import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';
import 'package:gauge_kit/gauge_kit_dashboard_kit.dart';

Widget _host(Widget child, {double width = 400, double height = 400}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: width, height: height, child: child),
    ),
  );
}

void main() {
  group('DashboardCard chrome', () {
    testWidgets('renders with and without glow', (tester) async {
      await tester.pumpWidget(_host(
        const DashboardCard(
          accentColor: Colors.blue,
          child: SizedBox(width: 40, height: 40),
        ),
      ));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_host(
        const DashboardCard(
          showGlow: false,
          child: SizedBox(width: 40, height: 40),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DashboardCardHeader renders', (tester) async {
      await tester.pumpWidget(_host(
        const DashboardCardHeader(
          label: 'SPEED',
          icon: Icons.speed_rounded,
          accentColor: Colors.blue,
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('SPEED'), findsOneWidget);
    });
  });

  group('GaugeRingCard / GaugeBarCard', () {
    testWidgets('GaugeRingCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 65);
      await tester.pumpWidget(_host(
        GaugeRingCard(
          controller: c,
          label: 'BATTERY',
          icon: Icons.battery_charging_full_rounded,
          accentColor: const Color(0xFF34D399),
          unitText: '%',
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('65'), findsOneWidget);
      addTearDown(c.dispose);
    });

    testWidgets('GaugeBarCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 32);
      await tester.pumpWidget(_host(
        GaugeBarCard(
          controller: c,
          label: 'FUEL',
          icon: Icons.local_gas_station_rounded,
          accentColor: const Color(0xFFFB7185),
          unitText: '%',
        ),
        height: 140,
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('32'), findsOneWidget);
      addTearDown(c.dispose);
    });

    testWidgets('colorForValue recomputes accent per frame', (tester) async {
      final c = GaugeController(initialValue: 10);
      await tester.pumpWidget(_host(
        GaugeRingCard(
          controller: c,
          label: 'BATTERY',
          icon: Icons.battery_charging_full_rounded,
          accentColor: Colors.green,
          colorForValue: (v) => v < 15 ? Colors.red : Colors.green,
        ),
      ));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });
  });

  group('Stat card presets', () {
    testWidgets('SpeedStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 120);
      await tester.pumpWidget(
          _host(SpeedStatCard(controller: c), width: 300, height: 300));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('BatteryStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 8);
      await tester.pumpWidget(_host(BatteryStatCard(controller: c)));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('RangeStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 250);
      await tester
          .pumpWidget(_host(RangeStatCard(controller: c, maxRangeKm: 480)));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('EcoScoreStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 88);
      await tester.pumpWidget(_host(EcoScoreStatCard(controller: c)));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('ClimateStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 21.5);
      await tester.pumpWidget(_host(ClimateStatCard(controller: c)));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('TirePressureStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 26);
      await tester
          .pumpWidget(_host(TirePressureStatCard(controller: c), height: 140));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('FuelStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 12);
      await tester.pumpWidget(_host(FuelStatCard(controller: c), height: 140));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });

    testWidgets('TripStatCard renders without error', (tester) async {
      final c = GaugeController(initialValue: 24.3);
      await tester.pumpWidget(
          _host(TripStatCard(controller: c, targetKm: 50), height: 140));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });
  });

  group('StatCardGrid', () {
    testWidgets('lays out hero + children responsively', (tester) async {
      final speedCtrl = GaugeController(initialValue: 120);
      final batteryCtrl = GaugeController(initialValue: 65);
      final rangeCtrl = GaugeController(initialValue: 250);
      final climateCtrl = GaugeController(initialValue: 21);

      await tester.pumpWidget(_host(
        SingleChildScrollView(
          child: StatCardGrid(
            hero: SpeedStatCard(controller: speedCtrl),
            children: [
              BatteryStatCard(controller: batteryCtrl),
              RangeStatCard(controller: rangeCtrl),
              ClimateStatCard(controller: climateCtrl),
            ],
          ),
        ),
        width: 380,
        height: 900,
      ));
      expect(tester.takeException(), isNull);

      addTearDown(() {
        speedCtrl.dispose();
        batteryCtrl.dispose();
        rangeCtrl.dispose();
        climateCtrl.dispose();
      });
    });

    testWidgets('renders with no hero and empty children', (tester) async {
      await tester.pumpWidget(_host(const StatCardGrid()));
      expect(tester.takeException(), isNull);
    });
  });
}
