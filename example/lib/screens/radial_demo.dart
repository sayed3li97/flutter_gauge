import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class RadialDemoScreen extends StatefulWidget {
  const RadialDemoScreen({super.key});

  @override
  State<RadialDemoScreen> createState() => _RadialDemoScreenState();
}

class _RadialDemoScreenState extends State<RadialDemoScreen>
    with TickerProviderStateMixin {
  final _speedCtrl = GaugeController(initialValue: 60);
  final _rpmCtrl = GaugeController(initialValue: 3000);
  final _fuelCtrl = GaugeController(initialValue: 70);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _speedCtrl.value = 50 + (DateTime.now().millisecond % 100).toDouble();
      _rpmCtrl.value = 1000 + (DateTime.now().millisecond % 6000).toDouble();
      _fuelCtrl.value = 20 + (DateTime.now().millisecond % 70).toDouble();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speedCtrl.dispose();
    _rpmCtrl.dispose();
    _fuelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radial Gauges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Speedometer', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: RadialGauge.speedometer(controller: _speedCtrl, max: 180),
            ),
            const SizedBox(height: 16),
            const Text('Tachometer', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: RadialGauge.tachometer(controller: _rpmCtrl),
            ),
            const SizedBox(height: 16),
            const Text('Fuel Level', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: RadialGauge.fuel(controller: _fuelCtrl),
            ),
            const SizedBox(height: 16),
            const Text('Compass', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: RadialGauge.compass(
                controller: GaugeController(initialValue: 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
