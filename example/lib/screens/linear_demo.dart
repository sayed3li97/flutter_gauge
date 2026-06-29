import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class LinearDemoScreen extends StatefulWidget {
  const LinearDemoScreen({super.key});

  @override
  State<LinearDemoScreen> createState() => _LinearDemoScreenState();
}

class _LinearDemoScreenState extends State<LinearDemoScreen> {
  double _value = 40;
  final _ctrl = GaugeController(initialValue: 40);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linear Gauges')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Horizontal progress:'),
            const SizedBox(height: 8),
            LinearGauge.progress(controller: _ctrl),
            const SizedBox(height: 16),
            const Text('Volume (with ticks):'),
            const SizedBox(height: 8),
            LinearGauge.volume(controller: _ctrl),
            const SizedBox(height: 16),
            const Text('Custom range:'),
            const SizedBox(height: 8),
            LinearGauge(
              controller: _ctrl,
              min: 0,
              max: 100,
              ranges: [
                const GaugeRange(min: 70, max: 100, color: Color(0xFFCC3311)),
              ],
            ),
            const SizedBox(height: 24),
            Slider(
              value: _value,
              min: 0,
              max: 100,
              onChanged: (v) {
                setState(() => _value = v);
                _ctrl.value = v;
              },
            ),
          ],
        ),
      ),
    );
  }
}
