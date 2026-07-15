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
  group('DashboardCardStyle factories', () {
    test('dark() is exactly the default constructor', () {
      // .dark() redirects to the default constructor, so the two produce the
      // same canonical const instance — a single identity check guards all
      // ten fields at once and fails the moment they could ever diverge.
      expect(
        identical(const DashboardCardStyle.dark(), const DashboardCardStyle()),
        isTrue,
      );
    });

    test('light() flips background, text, and track to light-theme values', () {
      const light = DashboardCardStyle.light();
      expect(light.backgroundColor, Colors.white);
      // Track must be a dark wash so the empty track stays visible on white.
      expect(light.trackColor, const Color(0x14000000));
      // Value text must be dark, not the dark-theme white.
      expect(light.valueStyle.color, const Color(0xFF0F172A));
      expect(light.backgroundColor,
          isNot(const DashboardCardStyle().backgroundColor));
    });

    test('factories still accept per-field overrides', () {
      const light = DashboardCardStyle.light(cornerRadius: 12);
      expect(light.cornerRadius, 12);
      expect(light.backgroundColor, Colors.white); // others keep light default
    });

    testWidgets('a light-themed card renders without error', (tester) async {
      final c = GaugeController(initialValue: 65);
      await tester.pumpWidget(_host(
        GaugeRingCard(
          controller: c,
          label: 'BATTERY',
          icon: Icons.battery_charging_full_rounded,
          accentColor: const Color(0xFF16A34A),
          unitText: '%',
          cardStyle: const DashboardCardStyle.light(),
        ),
      ));
      expect(tester.takeException(), isNull);
      addTearDown(c.dispose);
    });
  });

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

    testWidgets('GaugeListTile renders without error, grouped in a list',
        (tester) async {
      final battery = GaugeController(initialValue: 65);
      final range = GaugeController(initialValue: 250);
      await tester.pumpWidget(_host(
        DashboardCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GaugeListTile(
                controller: battery,
                label: 'BATTERY',
                icon: Icons.battery_charging_full_rounded,
                accentColor: Colors.green,
                unitText: '%',
              ),
              const Divider(height: 1),
              GaugeListTile(
                controller: range,
                label: 'RANGE',
                icon: Icons.route_rounded,
                accentColor: Colors.purple,
                unitText: 'km',
                max: 500,
                showTrailingIndicator: false,
              ),
            ],
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('65'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      addTearDown(() {
        battery.dispose();
        range.dispose();
      });
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
