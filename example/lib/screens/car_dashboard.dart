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
      _oilStatusCtrl.value =
          _oilCtrl.value < 1.5 ? 2.0 : (_oilCtrl.value < 2.0 ? 1.0 : 0.0);
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
    const bg = Color(0xFF0D0D0D);
    const labelStyle = TextStyle(
      color: Color(0xFF888888),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    );
    const style = ExecutiveGaugeStyle();
    const mode = GaugeMode.instrument;

    // Center label styles — painted directly on canvas, always visible
    const speedLabelStyle = TextStyle(
      color: Colors.white,
      fontSize: 52,
      fontWeight: FontWeight.bold,
      letterSpacing: -2,
    );
    const rpmLabelStyle = TextStyle(
      color: Color(0xFFFFBB33),
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: -1,
    );
    const fuelLabelStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top status bar ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
              ),
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

            // ── Main gauge row: Tach | Speed | Fuel ─────────────────────────
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Tachometer — RPM label painted on canvas
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _LiveRadialGauge(
                              controller: _rpmCtrl,
                              builder: (value) => RadialGauge.tachometer(
                                controller: _rpmCtrl,
                                redlineRpm: 6500,
                                maxRpm: 8000,
                                showCenterLabel: true,
                                centerLabel:
                                    '${(value / 1000).toStringAsFixed(1)}\n×1000 RPM',
                                centerLabelStyle: rpmLabelStyle,
                                style: style,
                                mode: mode,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center speedometer — speed + unit painted on canvas
                    Expanded(
                      flex: 2,
                      child: _LiveRadialGauge(
                        controller: _speedCtrl,
                        builder: (value) => RadialGauge.speedometer(
                          controller: _speedCtrl,
                          max: 240,
                          showCenterLabel: true,
                          centerLabel: '${value.toStringAsFixed(0)}\nkm/h',
                          centerLabelStyle: speedLabelStyle,
                          style: style,
                          mode: mode,
                        ),
                      ),
                    ),

                    // Fuel gauge — percentage painted on canvas
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _LiveRadialGauge(
                              controller: _fuelCtrl,
                              builder: (value) => RadialGauge.fuel(
                                controller: _fuelCtrl,
                                showCenterLabel: true,
                                centerLabel:
                                    '${value.toStringAsFixed(0)}%\nFUEL',
                                centerLabelStyle: fuelLabelStyle,
                                style: style,
                                mode: mode,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A), height: 1),

            // ── Odometer ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: const Color(0xFF0A0A0A),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Coolant Temp
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: _LiveRadialGauge(
                              controller: _coolantCtrl,
                              builder: (value) => RadialGauge(
                                controller: _coolantCtrl,
                                min: 0,
                                max: 120,
                                startAngleDeg: 150,
                                sweepAngleDeg: 240,
                                ranges: const [
                                  GaugeRange(
                                      min: 0,
                                      max: 40,
                                      color: Color(0xFF0077BB)),
                                  GaugeRange(
                                      min: 40,
                                      max: 95,
                                      color: Color(0xFF228833)),
                                  GaugeRange(
                                      min: 95,
                                      max: 120,
                                      color: Color(0xFFCC3311)),
                                ],
                                majorDivisions: 6,
                                showLabels: true,
                                showNeedle: true,
                                showCenterLabel: true,
                                centerLabel: '${value.toStringAsFixed(0)}°C',
                                centerLabelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                style: style,
                                mode: mode,
                              ),
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
                            child: _LiveRadialGauge(
                              controller: _oilCtrl,
                              builder: (value) => RadialGauge(
                                controller: _oilCtrl,
                                min: 0,
                                max: 6,
                                startAngleDeg: 150,
                                sweepAngleDeg: 240,
                                ranges: const [
                                  GaugeRange(
                                      min: 0, max: 1, color: Color(0xFFCC3311)),
                                  GaugeRange(
                                      min: 1, max: 2, color: Color(0xFFEE7733)),
                                  GaugeRange(
                                      min: 2, max: 5, color: Color(0xFF228833)),
                                  GaugeRange(
                                      min: 5, max: 6, color: Color(0xFFEE7733)),
                                ],
                                majorDivisions: 6,
                                showLabels: true,
                                showNeedle: true,
                                showCenterLabel: true,
                                centerLabel: '${value.toStringAsFixed(1)} bar',
                                centerLabelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                style: style,
                                mode: mode,
                              ),
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

// Rebuilds the RadialGauge widget when controller value changes, providing
// the live value so it can be embedded in centerLabel without Stack/Align.
class _LiveRadialGauge extends StatefulWidget {
  final GaugeController controller;
  final Widget Function(double value) builder;

  const _LiveRadialGauge({
    required this.controller,
    required this.builder,
  });

  @override
  State<_LiveRadialGauge> createState() => _LiveRadialGaugeState();
}

class _LiveRadialGaugeState extends State<_LiveRadialGauge> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void didUpdateWidget(_LiveRadialGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(widget.controller.value);
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _StatusItem extends StatelessWidget {
  final String label;
  final GaugeController ctrl;

  const _StatusItem({required this.label, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ctrl,
      builder: (_, __) {
        final val = ctrl.value;
        final statusColor = val >= 2.0
            ? const Color(0xFFCC3311)
            : val >= 1.0
                ? const Color(0xFFFFBB33)
                : const Color(0xFF228833);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            border: Border.all(
                color: statusColor.withValues(alpha: 0.5), width: 1.0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: StatusGauge(
                  controller: ctrl,
                  radius: 14,
                  style: const ExecutiveGaugeStyle(),
                  mode: GaugeMode.instrument,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GearIndicator extends StatelessWidget {
  final String gear;
  const _GearIndicator({required this.gear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFBB33).withValues(alpha: 0.1),
        border: Border.all(color: const Color(0xFFFFBB33), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'GEAR',
            style: TextStyle(
              color: Color(0xFF886633),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            gear,
            style: const TextStyle(
              color: Color(0xFFFFBB33),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
