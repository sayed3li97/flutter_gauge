import 'package:flutter/material.dart';

import 'screens/car_dashboard.dart';
import 'screens/flight_dashboard.dart';
import 'screens/weather_dashboard.dart';
import 'screens/audio_dashboard.dart';
import 'screens/server_dashboard.dart';
import 'screens/submarine_dashboard.dart';

void main() {
  runApp(const GaugeKitExampleApp());
}

class GaugeKitExampleApp extends StatelessWidget {
  const GaugeKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gauge_kit Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _tabIndex = 0;

  static const _tabs = [
    (icon: Icons.directions_car, label: 'Car'),
    (icon: Icons.flight, label: 'Flight'),
    (icon: Icons.wb_sunny, label: 'Weather'),
    (icon: Icons.equalizer, label: 'Audio'),
    (icon: Icons.dns, label: 'Server'),
    (icon: Icons.waves, label: 'Sub'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          CarDashboardScreen(),
          FlightDashboardScreen(),
          WeatherDashboardScreen(),
          AudioDashboardScreen(),
          ServerDashboardScreen(),
          SubmarineDashboardScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
