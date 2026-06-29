import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class CarDashboardScreen extends StatefulWidget {
  const CarDashboardScreen({super.key});

  @override
  State<CarDashboardScreen> createState() => _CarDashboardScreenState();
}

class _CarDashboardScreenState extends State<CarDashboardScreen> {
  // Controllers
  final _speedCtrl = GaugeController(initialValue: 85.0);
  final _rpmCtrl = GaugeController(initialValue: 3200.0);
  final _fuelCtrl = GaugeController(initialValue: 68.0);
  final _coolantCtrl = GaugeController(initialValue: 87.0);
  final _oilCtrl = GaugeController(initialValue: 3.8);
  final _odomCtrl = GaugeController(initialValue: 48321.4);

  // Status controllers (0=ok, 1=warn, 2=danger)
  final _engineStatusCtrl = GaugeController(initialValue: 0.0);
  final _batteryStatusCtrl = GaugeController(initialValue: 0.0);
  final _oilStatusCtrl = GaugeController(initialValue: 0.0);

  Timer? _timer;
  double _phase = 0.0;
  double _fuelLevel = 68.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _phase += 0.12;
      // Speed oscillates 70–160 km/h with realistic variation
      final speed = 115.0 + 45.0 * sin(_phase) + 10.0 * sin(_phase * 2.3);
      _speedCtrl.value = speed.clamp(0.0, 240.0);

      // RPM tracks speed with slight lag + engine character
      final rpm = 1500.0 + speed * 28.0 + 200.0 * sin(_phase * 1.7);
      _rpmCtrl.value = rpm.clamp(800.0, 8000.0);

      // Fuel slowly drains
      _fuelLevel -= 0.02;
      if (_fuelLevel < 5.0) _fuelLevel = 68.0;
      _fuelCtrl.value = _fuelLevel;

      // Coolant stays in normal range, slight oscillation
      _coolantCtrl.value = (88.0 + 3.0 * sin(_phase * 0.3)).clamp(0.0, 120.0);

      // Oil pressure tracks RPM
      _oilCtrl.value = (2.5 + rpm / 3000.0 + 0.2 * sin(_phase)).clamp(0.0, 6.0);

      // Odometer slowly ticks
      _odomCtrl.value += speed / 7200.0;

      // Update oil warning if pressure drops
      _oilStatusCtrl.value = _oilCtrl.value < 1.5 ? 2.0 : (_oilCtrl.value < 2.0 ? 1.0 : 0.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speedCtrl.dispose();
    _rpmCtrl.dispose();
    _fuelCtrl.dispose();
    _coolantCtrl.dispose();
    _oilCtrl.dispose();
    _odomCtrl.dispose();
    _engineStatusCtrl.dispose();
    _batteryStatusCtrl.dispose();
    _oilStatusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF111111);
    const labelStyle = TextStyle(
      color: Color(0xFFAAAAAA),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    );
    const style = ExecutiveGaugeStyle();
    const mode = GaugeMode.instrument;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top status bar ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatusItem(label: 'ENGINE', ctrl: _engineStatusCtrl),
                  _StatusItem(label: 'BATTERY', ctrl: _batteryStatusCtrl),
                  _StatusItem(label: 'OIL PRESS', ctrl: _oilStatusCtrl),
                  const _GearIndicator(gear: 'D'),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A), height: 1),

            // ── Main gauge row: Tach | Speed | Fuel ─────────────────────────
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Tachometer
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RadialGauge.tachometer(
                              controller: _rpmCtrl,
                              redlineRpm: 6500,
                              maxRpm: 8000,
                              style: style,
                              mode: mode,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('RPM × 1000', style: labelStyle),
                        ],
                      ),
                    ),

                    // Center speedometer — larger
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RadialGauge.speedometer(
                              controller: _speedCtrl,
                              max: 240,
                              style: style,
                              mode: mode,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('km/h', style: labelStyle),
                        ],
                      ),
                    ),

                    // Fuel gauge
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RadialGauge.fuel(
                              controller: _fuelCtrl,
                              style: style,
                              mode: mode,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('FUEL', style: labelStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A), height: 1),

            // ── Odometer ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  OdometerGauge.mileage(
                    controller: _odomCtrl,
                    unit: 'km',
                    style: style,
                    mode: mode,
                  ),
                  const SizedBox(height: 2),
                  const Text('ODOMETER', style: labelStyle),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A), height: 1),

            // ── Bottom small gauges: Coolant | Oil Pressure ──────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Coolant Temp
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: RadialGauge(
                              controller: _coolantCtrl,
                              min: 0,
                              max: 120,
                              startAngleDeg: 150,
                              sweepAngleDeg: 240,
                              ranges: const [
                                GaugeRange(min: 0, max: 40, color: Color(0xFF0077BB)),
                                GaugeRange(min: 40, max: 95, color: Color(0xFF228833)),
                                GaugeRange(min: 95, max: 120, color: Color(0xFFCC3311)),
                              ],
                              majorDivisions: 6,
                              showLabels: true,
                              showNeedle: true,
                              style: style,
                              mode: mode,
                            ),
                          ),
                          const Text('COOLANT °C', style: labelStyle),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Oil Pressure
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: RadialGauge(
                              controller: _oilCtrl,
                              min: 0,
                              max: 6,
                              startAngleDeg: 150,
                              sweepAngleDeg: 240,
                              ranges: const [
                                GaugeRange(min: 0, max: 1, color: Color(0xFFCC3311)),
                                GaugeRange(min: 1, max: 2, color: Color(0xFFEE7733)),
                                GaugeRange(min: 2, max: 5, color: Color(0xFF228833)),
                                GaugeRange(min: 5, max: 6, color: Color(0xFFEE7733)),
                              ],
                              majorDivisions: 6,
                              showLabels: true,
                              showNeedle: true,
                              style: style,
                              mode: mode,
                            ),
                          ),
                          const Text('OIL PRESS bar', style: labelStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _StatusItem extends StatelessWidget {
  final String label;
  final GaugeController ctrl;

  const _StatusItem({required this.label, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: StatusGauge(
            controller: ctrl,
            radius: 10,
            style: const ExecutiveGaugeStyle(),
            mode: GaugeMode.instrument,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 9,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _GearIndicator extends StatelessWidget {
  final String gear;
  const _GearIndicator({required this.gear});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFBB33), width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            gear,
            style: const TextStyle(
              color: Color(0xFFFFBB33),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'GEAR',
          style: TextStyle(color: Color(0xFF777777), fontSize: 9, letterSpacing: 1.2),
        ),
      ],
    );
  }
}
