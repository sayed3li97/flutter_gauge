# gauge_kit examples

Two things live here:

- **`lib/main.dart`** — the full gallery: ten live dashboards (car, flight,
  weather, audio, server, submarine, ML, smart home, and the **Dashboard
  Kit** tab). Run with `flutter run`.
- **`lib/dashboard_kit_example.dart`** — a focused, copy-pasteable
  [Dashboard Kit](https://pub.dev/packages/gauge_kit#dashboard-kit) starting
  point (shown below). Run with
  `flutter run -t lib/dashboard_kit_example.dart`.

## Dashboard Kit in ~40 lines

The Dashboard Kit is a high-level layer on top of the core gauges — drop-in,
pre-styled "smart dashboard" cards. Import it alongside the core barrel:

```dart
import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';
import 'package:gauge_kit/gauge_kit_dashboard_kit.dart';

class MyDashboard extends StatelessWidget {
  const MyDashboard({super.key, required this.speed, required this.battery});

  final GaugeController speed;   // drive these from your own data
  final GaugeController battery;

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
              // Bento grid of pre-styled ring/bar tiles — each preset needs
              // only a GaugeController:
              StatCardGrid(
                hero: SpeedStatCard(controller: speed, max: 240),
                children: [
                  BatteryStatCard(controller: battery),
                ],
              ),
              const SizedBox(height: 20),

              // Or the row primitive, grouped in one card. Swap the whole
              // card to a light theme with a single named constructor:
              DashboardCard(
                style: const DashboardCardStyle.light(),
                child: GaugeListTile(
                  controller: battery,
                  label: 'BATTERY',
                  icon: Icons.battery_charging_full,
                  accentColor: const Color(0xFF16A34A),
                  unitText: '%',
                  cardStyle: const DashboardCardStyle.light(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

See `lib/dashboard_kit_example.dart` for a complete runnable version with a
full grid, both `DashboardCardStyle.dark()` and `.light()` cards, and a
stack of `GaugeListTile` rows. The main gauge_kit
[README](https://pub.dev/packages/gauge_kit#dashboard-kit) documents every
widget and parameter.
