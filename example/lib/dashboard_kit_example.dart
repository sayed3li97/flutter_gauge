// A focused, self-contained Dashboard Kit example.
//
// This is intentionally minimal and separate from the big multi-tab demo in
// `main.dart` — it's the copy-pasteable starting point referenced by
// `example/README.md`, and it showcases the three building blocks of
// `gauge_kit_dashboard_kit.dart`:
//
//   1. `StatCardGrid` + stat-card presets  — the bento grid of ring/bar tiles
//   2. `GaugeListTile`                      — the full-width row primitive
//   3. `DashboardCardStyle.dark()` / `.light()` — one-line theme chrome
//
// Run it directly with:  flutter run -t lib/dashboard_kit_example.dart
import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';
import 'package:gauge_kit/gauge_kit_dashboard_kit.dart';

void main() => runApp(const DashboardKitExampleApp());

class DashboardKitExampleApp extends StatelessWidget {
  const DashboardKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardKitExample(),
    );
  }
}

class DashboardKitExample extends StatefulWidget {
  const DashboardKitExample({super.key});

  @override
  State<DashboardKitExample> createState() => _DashboardKitExampleState();
}

class _DashboardKitExampleState extends State<DashboardKitExample> {
  // One controller per stat. In a real app you'd drive these from your data;
  // here they hold fixed values so the example is deterministic.
  final _speed = GaugeController(initialValue: 116);
  final _battery = GaugeController(initialValue: 78);
  final _range = GaugeController(initialValue: 372);
  final _eco = GaugeController(initialValue: 84);
  final _climate = GaugeController(initialValue: 21.5);
  final _tire = GaugeController(initialValue: 33);
  final _fuel = GaugeController(initialValue: 62);

  @override
  void dispose() {
    for (final c in [
      _speed,
      _battery,
      _range,
      _eco,
      _climate,
      _tire,
      _fuel,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1 ── Bento grid of ring/bar tiles ──────────────────────────
              StatCardGrid(
                hero: SpeedStatCard(controller: _speed, max: 240),
                children: [
                  BatteryStatCard(controller: _battery),
                  RangeStatCard(controller: _range, maxRangeKm: 500),
                  EcoScoreStatCard(controller: _eco),
                  ClimateStatCard(controller: _climate),
                ],
              ),
              const SizedBox(height: 20),

              // 2 ── GaugeListTile rows in a DARK card ─────────────────────
              const _SectionLabel('GaugeListTile · DashboardCardStyle.dark()'),
              const SizedBox(height: 8),
              DashboardCard(
                showGlow: false,
                style: const DashboardCardStyle.dark(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GaugeListTile(
                      controller: _battery,
                      label: 'BATTERY',
                      icon: Icons.battery_charging_full_rounded,
                      accentColor: const Color(0xFF34D399),
                      unitText: '%',
                      cardStyle: const DashboardCardStyle.dark(),
                    ),
                    const Divider(height: 1, color: Color(0x14FFFFFF)),
                    GaugeListTile(
                      controller: _range,
                      label: 'RANGE',
                      icon: Icons.route_rounded,
                      accentColor: const Color(0xFFA78BFA),
                      unitText: 'km',
                      max: 500,
                      cardStyle: const DashboardCardStyle.dark(),
                    ),
                    const Divider(height: 1, color: Color(0x14FFFFFF)),
                    GaugeListTile(
                      controller: _fuel,
                      label: 'FUEL',
                      icon: Icons.local_gas_station_rounded,
                      accentColor: const Color(0xFFFB7185),
                      unitText: '%',
                      cardStyle: const DashboardCardStyle.dark(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3 ── The SAME rows in a LIGHT card, one line to switch ──────
              const _SectionLabel('GaugeListTile · DashboardCardStyle.light()'),
              const SizedBox(height: 8),
              DashboardCard(
                showGlow: false,
                style: const DashboardCardStyle.light(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GaugeListTile(
                      controller: _tire,
                      label: 'TYRE PRESSURE',
                      icon: Icons.tire_repair_rounded,
                      accentColor: const Color(0xFFD97706),
                      unitText: 'PSI',
                      min: 20,
                      max: 40,
                      cardStyle: const DashboardCardStyle.light(),
                    ),
                    const Divider(height: 1, color: Color(0x14000000)),
                    GaugeListTile(
                      controller: _eco,
                      label: 'ECO SCORE',
                      icon: Icons.eco_rounded,
                      accentColor: const Color(0xFF059669),
                      cardStyle: const DashboardCardStyle.light(),
                    ),
                    const Divider(height: 1, color: Color(0x14000000)),
                    GaugeListTile(
                      controller: _climate,
                      label: 'CABIN TEMP',
                      icon: Icons.thermostat_rounded,
                      accentColor: const Color(0xFF0891B2),
                      unitText: '°C',
                      min: 16,
                      max: 30,
                      valueFormatter: (v) => v.toStringAsFixed(1),
                      cardStyle: const DashboardCardStyle.light(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8A8F98),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
