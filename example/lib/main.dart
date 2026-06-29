import 'package:flutter/material.dart';

import 'screens/radial_demo.dart';
import 'screens/linear_demo.dart';
import 'screens/segmented_demo.dart';
import 'screens/arc_demo.dart';
import 'screens/presets_demo.dart';
import 'screens/theme_demo.dart';

void main() {
  runApp(const GaugeKitExampleApp());
}

class GaugeKitExampleApp extends StatelessWidget {
  const GaugeKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gauge_kit Demo',
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
    (icon: Icons.radio_button_checked, label: 'Radial'),
    (icon: Icons.linear_scale, label: 'Linear'),
    (icon: Icons.bar_chart, label: 'Segmented'),
    (icon: Icons.donut_large, label: 'Arc'),
    (icon: Icons.dashboard, label: 'Presets'),
    (icon: Icons.palette, label: 'Themes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          RadialDemoScreen(),
          LinearDemoScreen(),
          SegmentedDemoScreen(),
          ArcDemoScreen(),
          PresetsDemoScreen(),
          ThemeDemoScreen(),
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
