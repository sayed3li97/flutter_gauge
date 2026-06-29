import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class PresetsDemoScreen extends StatefulWidget {
  const PresetsDemoScreen({super.key});

  @override
  State<PresetsDemoScreen> createState() => _PresetsDemoScreenState();
}

class _PresetsDemoScreenState extends State<PresetsDemoScreen> {
  final _tempCtrl = GaugeController(initialValue: 22);
  final _levelCtrl = GaugeController(initialValue: 65);
  final _statusCtrl = GaugeController(initialValue: 0);
  final _pitchCtrl = GaugeController(initialValue: 5);
  final _rollCtrl = GaugeController(initialValue: 15);
  final _odomCtrl = GaugeController(initialValue: 123456.7);
  final _bulletCtrl = GaugeController(initialValue: 72);
  final _tapeCtrl = GaugeController(initialValue: 3500);

  @override
  void dispose() {
    _tempCtrl.dispose();
    _levelCtrl.dispose();
    _statusCtrl.dispose();
    _pitchCtrl.dispose();
    _rollCtrl.dispose();
    _odomCtrl.dispose();
    _bulletCtrl.dispose();
    _tapeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Presets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Thermometer'),
            SizedBox(
              height: 200,
              child: ThermometerGauge(
                controller: _tempCtrl,
                minCelsius: 0,
                maxCelsius: 40,
              ),
            ),
            _section('Tank Level'),
            SizedBox(
              height: 120,
              width: 60,
              child: TankGauge.water(controller: _levelCtrl),
            ),
            _section('Status Indicator'),
            Row(
              children: [
                StatusGauge(
                    controller: GaugeController(initialValue: 0), label: 'OK'),
                const SizedBox(width: 16),
                StatusGauge(
                    controller: GaugeController(initialValue: 1),
                    label: 'Warning'),
                const SizedBox(width: 16),
                StatusGauge(
                    controller: GaugeController(initialValue: 2),
                    label: 'Critical'),
              ],
            ),
            _section('Artificial Horizon'),
            SizedBox(
              height: 200,
              width: 200,
              child: ArtificialHorizonGauge(
                pitchController: _pitchCtrl,
                rollController: _rollCtrl,
              ),
            ),
            _section('Odometer'),
            OdometerGauge.mileage(controller: _odomCtrl),
            _section('Bullet Chart'),
            BulletGauge.kpi(controller: _bulletCtrl, label: 'Revenue'),
            _section('Tape / Altimeter'),
            SizedBox(
              height: 200,
              child: TapeGauge.altimeter(controller: _tapeCtrl),
            ),
            _section('Inclinometer'),
            SizedBox(
              height: 60,
              child: InclinometerGauge(
                controller: GaugeController(initialValue: 12),
              ),
            ),
            _section('Level Meter'),
            SizedBox(
              height: 120,
              child: LevelMeterGauge.stereo(controller: _levelCtrl),
            ),
            _section('Delta Gauge'),
            DeltaGauge(
              controller: GaugeController(initialValue: 75),
              baseline: 50,
              min: 0,
              max: 100,
              unit: '%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
