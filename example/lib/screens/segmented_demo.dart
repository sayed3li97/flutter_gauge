import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class SegmentedDemoScreen extends StatefulWidget {
  const SegmentedDemoScreen({super.key});

  @override
  State<SegmentedDemoScreen> createState() => _SegmentedDemoScreenState();
}

class _SegmentedDemoScreenState extends State<SegmentedDemoScreen> {
  double _value = 60;
  final _ctrl = GaugeController(initialValue: 60);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segmented Gauges')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('20 segments (LED bar):'),
            const SizedBox(height: 8),
            SizedBox(height: 28, child: SegmentedGauge(controller: _ctrl)),
            const SizedBox(height: 16),
            const Text('Signal strength (5 bars):'),
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: SegmentedGauge.signalStrength(controller: _ctrl),
            ),
            const SizedBox(height: 16),
            const Text('Battery level (10 bars):'),
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: SegmentedGauge.battery(controller: _ctrl),
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
            Text('Value: ${_value.round()}%'),
          ],
        ),
      ),
    );
  }
}
