import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class ArcDemoScreen extends StatefulWidget {
  const ArcDemoScreen({super.key});

  @override
  State<ArcDemoScreen> createState() => _ArcDemoScreenState();
}

class _ArcDemoScreenState extends State<ArcDemoScreen> {
  double _value = 65;
  final _ctrl = GaugeController(initialValue: 65);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arc Gauges')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: ArcGauge(controller: _ctrl, min: 0, max: 100),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: ArcGauge.cpuUsage(controller: _ctrl),
                ),
                SizedBox(
                  height: 140,
                  width: 140,
                  child: ArcGauge.networkSpeed(controller: _ctrl, maxMbps: 100),
                ),
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
