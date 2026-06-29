import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class SubmarineDashboardScreen extends StatefulWidget {
  const SubmarineDashboardScreen({super.key});

  @override
  State<SubmarineDashboardScreen> createState() => _SubmarineDashboardScreenState();
}

class _SubmarineDashboardScreenState extends State<SubmarineDashboardScreen> {
  // Primary instruments
  final _depthCtrl = GaugeController(initialValue: 85.0);      // 0–300 m tape
  final _pressCtrl = GaugeController(initialValue: 9.5);       // 0–100 bar radial
  final _o2Ctrl = GaugeController(initialValue: 78.0);         // 0–100% arc
  final _co2Ctrl = GaugeController(initialValue: 65.0);        // CO2 scrubber tank
  final _speedCtrl = GaugeController(initialValue: 6.0);       // 0–20 knots radial
  final _trimCtrl = GaugeController(initialValue: -2.0);       // ±30° inclinometer

  // Battery banks (0–100%)
  final _battACtrl = GaugeController(initialValue: 88.0);
  final _battBCtrl = GaugeController(initialValue: 92.0);
  final _battCCtrl = GaugeController(initialValue: 71.0);

  // Status dots (0=ok, 1=warn, 2=danger)
  final _hullStatusCtrl = GaugeController(initialValue: 0.0);
  final _ballastStatusCtrl = GaugeController(initialValue: 0.0);
  final _o2StatusCtrl = GaugeController(initialValue: 0.0);
  final _co2StatusCtrl = GaugeController(initialValue: 0.0);
  final _powerStatusCtrl = GaugeController(initialValue: 0.0);
  final _commsStatusCtrl = GaugeController(initialValue: 1.0);
  final _sonarStatusCtrl = GaugeController(initialValue: 0.0);
  final _navStatusCtrl = GaugeController(initialValue: 0.0);

  Timer? _timer;
  double _phase = 0.0;
  double _o2Level = 78.0;
  double _co2Remaining = 65.0;
  double _battALevel = 88.0;
  double _battBLevel = 92.0;
  double _battCLevel = 71.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      _phase += 0.10;

      // Depth oscillates around 85m ±5m
      final depth = 85.0 + 5.0 * sin(_phase * 0.4);
      _depthCtrl.value = depth.clamp(0.0, 300.0);

      // Pressure tracks depth (roughly 1 bar per 10m)
      _pressCtrl.value = (depth / 10.0 + 0.5 * sin(_phase * 0.7)).clamp(0.0, 100.0);

      // O2 slowly decreases over time
      _o2Level -= 0.04;
      if (_o2Level < 10.0) _o2Level = 78.0;
      _o2Ctrl.value = _o2Level;

      // CO2 scrubber capacity decreases
      _co2Remaining -= 0.02;
      if (_co2Remaining < 5.0) _co2Remaining = 65.0;
      _co2Ctrl.value = _co2Remaining;

      // Speed oscillates 4–10 knots
      _speedCtrl.value = (6.0 + 3.0 * sin(_phase * 0.5)).clamp(0.0, 20.0);

      // Trim: slight pitch oscillation
      _trimCtrl.value = (-2.0 + 3.0 * sin(_phase * 0.6)).clamp(-30.0, 30.0);

      // Battery drain
      _battALevel -= 0.01;
      _battBLevel -= 0.008;
      _battCLevel -= 0.012;
      if (_battALevel < 20.0) _battALevel = 88.0;
      if (_battBLevel < 20.0) _battBLevel = 92.0;
      if (_battCLevel < 20.0) _battCLevel = 71.0;
      _battACtrl.value = _battALevel;
      _battBCtrl.value = _battBLevel;
      _battCCtrl.value = _battCLevel;

      // Update status based on O2 level
      _o2StatusCtrl.value = _o2Level < 20.0 ? 2.0 : (_o2Level < 35.0 ? 1.0 : 0.0);
      _co2StatusCtrl.value = _co2Remaining < 15.0 ? 2.0 : (_co2Remaining < 25.0 ? 1.0 : 0.0);
      _powerStatusCtrl.value = _battCLevel < 25.0 ? 1.0 : 0.0;

      // Pressure warning
      _hullStatusCtrl.value = _pressCtrl.value > 85.0 ? 2.0 : (_pressCtrl.value > 75.0 ? 1.0 : 0.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _depthCtrl.dispose();
    _pressCtrl.dispose();
    _o2Ctrl.dispose();
    _co2Ctrl.dispose();
    _speedCtrl.dispose();
    _trimCtrl.dispose();
    _battACtrl.dispose();
    _battBCtrl.dispose();
    _battCCtrl.dispose();
    _hullStatusCtrl.dispose();
    _ballastStatusCtrl.dispose();
    _o2StatusCtrl.dispose();
    _co2StatusCtrl.dispose();
    _powerStatusCtrl.dispose();
    _commsStatusCtrl.dispose();
    _sonarStatusCtrl.dispose();
    _navStatusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF060B14);
    const style = ExecutiveGaugeStyle();
    const mode = GaugeMode.instrument;

    const labelStyle = TextStyle(
      color: Color(0xFF3A7AAA),
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    );
    const dimText = TextStyle(
      color: Color(0xFF2A4A6A),
      fontSize: 9,
      letterSpacing: 1.0,
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header bar ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF0F2030))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SUBMARINE CONTROL ROOM',
                    style: TextStyle(
                      color: Color(0xFF2A7AAA),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                  Row(children: [
                    _SubLed(color: const Color(0xFF225588), label: 'DIVE MODE'),
                    const SizedBox(width: 12),
                    ListenableBuilder(
                      listenable: _depthCtrl,
                      builder: (_, __) => Text(
                        'DEPTH: ${_depthCtrl.value.toStringAsFixed(0)} m',
                        style: const TextStyle(
                          color: Color(0xFF44AADD),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            // ── Main panel ────────────────────────────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left column: Depth tape + Speed ─────────────────
                  Container(
                    width: 80,
                    color: const Color(0xFF070C16),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: Column(
                      children: [
                        const Text('DEPTH', style: labelStyle),
                        const SizedBox(height: 4),
                        Expanded(
                          flex: 3,
                          child: TapeGauge(
                            controller: _depthCtrl,
                            min: 0,
                            max: 300,
                            tickInterval: 25,
                            unit: 'm',
                            vertical: true,
                            style: style,
                            mode: mode,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('SPEED', style: labelStyle),
                        const SizedBox(height: 4),
                        Expanded(
                          flex: 2,
                          child: RadialGauge(
                            controller: _speedCtrl,
                            min: 0,
                            max: 20,
                            startAngleDeg: 150,
                            sweepAngleDeg: 240,
                            majorDivisions: 5,
                            showLabels: true,
                            showNeedle: true,
                            style: style,
                            mode: mode,
                          ),
                        ),
                        const Text('knots', style: dimText),
                      ],
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: const Color(0xFF0F2030)),

                  // ── Center column: Pressure + O2 + CO2 + Trim ────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          // Hull Pressure + O2 row
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                // Hull Pressure radial
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('HULL PRESSURE', style: labelStyle),
                                      Expanded(
                                        child: RadialGauge(
                                          controller: _pressCtrl,
                                          min: 0,
                                          max: 100,
                                          startAngleDeg: 150,
                                          sweepAngleDeg: 240,
                                          ranges: const [
                                            GaugeRange(min: 0, max: 60, color: Color(0xFF0077BB)),
                                            GaugeRange(min: 60, max: 80, color: Color(0xFFEE7733)),
                                            GaugeRange(min: 80, max: 100, color: Color(0xFFCC3311)),
                                          ],
                                          majorDivisions: 5,
                                          showLabels: true,
                                          showNeedle: true,
                                          style: style,
                                          mode: mode,
                                        ),
                                      ),
                                      const Text('bar', style: dimText),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // O2 Level arc
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('O2 LEVEL', style: labelStyle),
                                      Expanded(
                                        child: ArcGauge(
                                          controller: _o2Ctrl,
                                          min: 0,
                                          max: 100,
                                          startAngleDeg: 150,
                                          sweepAngleDeg: 240,
                                          centerLabel: 'O2%',
                                          style: style,
                                          mode: mode,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // CO2 Tank + Trim row
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                // CO2 Scrubber tank
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('CO2 SCRUBBER', style: labelStyle),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 44,
                                              child: TankGauge(
                                                controller: _co2Ctrl,
                                                min: 0,
                                                max: 100,
                                                vertical: true,
                                                showWave: true,
                                                style: style,
                                                mode: mode,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text('capacity %', style: dimText),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Trim/pitch inclinometer
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('TRIM / PITCH', style: labelStyle),
                                      Expanded(
                                        child: InclinometerGauge(
                                          controller: _trimCtrl,
                                          maxAngle: 30,
                                          style: style,
                                          mode: mode,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Battery banks
                          const Text('BATTERY BANKS', style: labelStyle),
                          const SizedBox(height: 4),
                          _BatteryRow(label: 'BANK A', ctrl: _battACtrl, style: style, mode: mode),
                          const SizedBox(height: 4),
                          _BatteryRow(label: 'BANK B', ctrl: _battBCtrl, style: style, mode: mode),
                          const SizedBox(height: 4),
                          _BatteryRow(label: 'BANK C', ctrl: _battCCtrl, style: style, mode: mode),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Status panel ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF07101A),
                border: Border(top: BorderSide(color: Color(0xFF0F2030))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SubStatus('HULL', _hullStatusCtrl, style, mode),
                  _SubStatus('BALLAST', _ballastStatusCtrl, style, mode),
                  _SubStatus('O2', _o2StatusCtrl, style, mode),
                  _SubStatus('CO2', _co2StatusCtrl, style, mode),
                  _SubStatus('POWER', _powerStatusCtrl, style, mode),
                  _SubStatus('COMMS', _commsStatusCtrl, style, mode),
                  _SubStatus('SONAR', _sonarStatusCtrl, style, mode),
                  _SubStatus('NAV', _navStatusCtrl, style, mode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatteryRow extends StatelessWidget {
  final String label;
  final GaugeController ctrl;
  final GaugeStyle style;
  final GaugeMode mode;

  const _BatteryRow({
    required this.label,
    required this.ctrl,
    required this.style,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3A7AAA),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 24,
            child: SegmentedGauge.battery(
              controller: ctrl,
              style: style,
              mode: mode,
            ),
          ),
        ),
        const SizedBox(width: 6),
        ListenableBuilder(
          listenable: ctrl,
          builder: (_, __) => SizedBox(
            width: 36,
            child: Text(
              '${ctrl.value.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Color(0xFF3A7AAA),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubStatus extends StatelessWidget {
  final String label;
  final GaugeController ctrl;
  final GaugeStyle style;
  final GaugeMode mode;

  const _SubStatus(this.label, this.ctrl, this.style, this.mode);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: StatusGauge(
            controller: ctrl,
            radius: 8,
            style: style,
            mode: mode,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2A5A7A),
            fontSize: 7,
            letterSpacing: 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SubLed extends StatelessWidget {
  final Color color;
  final String label;
  const _SubLed({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 5)],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 9, letterSpacing: 1.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
