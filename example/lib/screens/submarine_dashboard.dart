import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class SubmarineDashboardScreen extends StatefulWidget {
  const SubmarineDashboardScreen({super.key});

  @override
  State<SubmarineDashboardScreen> createState() =>
      _SubmarineDashboardScreenState();
}

class _SubmarineDashboardScreenState extends State<SubmarineDashboardScreen> {
  // Primary instruments
  final _depthCtrl = GaugeController(initialValue: 85.0); // 0–300 m tape
  final _pressCtrl = GaugeController(initialValue: 9.5); // 0–100 bar radial
  final _o2Ctrl = GaugeController(initialValue: 78.0); // 0–100% tank
  final _co2Ctrl = GaugeController(initialValue: 800.0); // 0–5000 ppm arc
  final _speedCtrl = GaugeController(initialValue: 6.0); // 0–30 knots radial
  final _trimCtrl = GaugeController(initialValue: -2.0); // ±45° inclinometer

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
  double _co2Ppm = 800.0;
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
      _pressCtrl.value =
          (depth / 10.0 + 0.5 * sin(_phase * 0.7)).clamp(0.0, 100.0);

      // O2 slowly decreases over time
      _o2Level -= 0.04;
      if (_o2Level < 10.0) _o2Level = 78.0;
      _o2Ctrl.value = _o2Level;

      // CO2 ppm slowly rises
      _co2Ppm += 1.5;
      if (_co2Ppm > 4500.0) _co2Ppm = 800.0;
      _co2Ctrl.value = _co2Ppm;

      // Speed oscillates 4–12 knots (extended range 0–30)
      _speedCtrl.value =
          (6.0 + 4.0 * sin(_phase * 0.5) + 2.0 * sin(_phase * 1.1))
              .clamp(0.0, 30.0);

      // Trim: slight pitch oscillation ±45°
      _trimCtrl.value = (-2.0 + 3.0 * sin(_phase * 0.6)).clamp(-45.0, 45.0);

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
      _o2StatusCtrl.value =
          _o2Level < 20.0 ? 2.0 : (_o2Level < 35.0 ? 1.0 : 0.0);
      _co2StatusCtrl.value =
          _co2Ppm > 3500.0 ? 2.0 : (_co2Ppm > 2000.0 ? 1.0 : 0.0);
      _powerStatusCtrl.value = _battCLevel < 25.0 ? 1.0 : 0.0;

      // Pressure warning
      _hullStatusCtrl.value =
          _pressCtrl.value > 85.0 ? 2.0 : (_pressCtrl.value > 75.0 ? 1.0 : 0.0);
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
    const cardBg = Color(0xFF1A2A3A);
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
                color: Color(0xFF060B14),
                border: Border(bottom: BorderSide(color: Color(0xFF0F2030))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CONTROL ROOM',
                    style: TextStyle(
                      color: Color(0xFF2A7AAA),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                  Row(children: [
                    _SubLed(color: const Color(0xFF225588), label: 'DIVE MODE'),
                    const SizedBox(width: 16),
                    ListenableBuilder(
                      listenable: _depthCtrl,
                      builder: (_, __) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1A2A),
                          border: Border.all(
                              color: const Color(0xFF44AADD), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEPTH: ${_depthCtrl.value.toStringAsFixed(0)} m',
                          style: const TextStyle(
                            color: Color(0xFF44AADD),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
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
                  // ── Left column: Depth tape + digital box ────────────
                  Container(
                    width: 100,
                    color: const Color(0xFF070C16),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: Column(
                      children: [
                        const Text('DEPTH', style: labelStyle),
                        const SizedBox(height: 4),
                        Expanded(
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
                        // Amber digital depth readout
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0800),
                            border: Border.all(
                                color: const Color(0xFFFFBB33), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListenableBuilder(
                            listenable: _depthCtrl,
                            builder: (_, __) => Text(
                              '${_depthCtrl.value.toStringAsFixed(0)} m',
                              style: const TextStyle(
                                color: Color(0xFFFFBB33),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: const Color(0xFF0F2030)),

                  // ── Center: 2×2 grid of instruments ──────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          // Top row: Speed + Hull Pressure
                          Expanded(
                            child: Row(
                              children: [
                                // Speed radial (0–30 knots)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFF1A3A55)),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      children: [
                                        const Text('SPEED', style: labelStyle),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: RadialGauge(
                                                  controller: _speedCtrl,
                                                  min: 0,
                                                  max: 30,
                                                  startAngleDeg: 150,
                                                  sweepAngleDeg: 240,
                                                  ranges: const [
                                                    GaugeRange(
                                                        min: 0,
                                                        max: 10,
                                                        color:
                                                            Color(0xFF228833)),
                                                    GaugeRange(
                                                        min: 10,
                                                        max: 20,
                                                        color:
                                                            Color(0xFFEE7733)),
                                                    GaugeRange(
                                                        min: 20,
                                                        max: 30,
                                                        color:
                                                            Color(0xFFCC3311)),
                                                  ],
                                                  majorDivisions: 6,
                                                  showLabels: true,
                                                  showNeedle: true,
                                                  style: style,
                                                  mode: mode,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    const Alignment(0, 0.6),
                                                child: ListenableBuilder(
                                                  listenable: _speedCtrl,
                                                  builder: (_, __) => Text(
                                                    '${_speedCtrl.value.toStringAsFixed(1)} kts',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
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

                                const SizedBox(width: 8),

                                // Hull Pressure radial (0–100 bar)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFF1A3A55)),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      children: [
                                        const Text('HULL PRESSURE',
                                            style: labelStyle),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: RadialGauge(
                                                  controller: _pressCtrl,
                                                  min: 0,
                                                  max: 100,
                                                  startAngleDeg: 150,
                                                  sweepAngleDeg: 240,
                                                  ranges: const [
                                                    GaugeRange(
                                                        min: 0,
                                                        max: 60,
                                                        color:
                                                            Color(0xFF0077BB)),
                                                    GaugeRange(
                                                        min: 60,
                                                        max: 80,
                                                        color:
                                                            Color(0xFFEE7733)),
                                                    GaugeRange(
                                                        min: 80,
                                                        max: 100,
                                                        color:
                                                            Color(0xFFCC3311)),
                                                  ],
                                                  majorDivisions: 5,
                                                  showLabels: true,
                                                  showNeedle: true,
                                                  style: style,
                                                  mode: mode,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    const Alignment(0, 0.6),
                                                child: ListenableBuilder(
                                                  listenable: _pressCtrl,
                                                  builder: (_, __) => Text(
                                                    '${_pressCtrl.value.toStringAsFixed(1)} bar',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
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
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Bottom row: O2 Tank + Inclinometer
                          Expanded(
                            child: Row(
                              children: [
                                // O2 TankGauge with % overlay
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFF1A3A55)),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      children: [
                                        const Text('O2 LEVEL',
                                            style: labelStyle),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 50,
                                                      child: TankGauge(
                                                        controller: _o2Ctrl,
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
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4),
                                                  child: ListenableBuilder(
                                                    listenable: _o2Ctrl,
                                                    builder: (_, __) => Text(
                                                      '${_o2Ctrl.value.toStringAsFixed(0)}%',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Text('O2 %', style: dimText),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Inclinometer pitch ±45° with angle overlay
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFF1A3A55)),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      children: [
                                        const Text('TRIM / PITCH',
                                            style: labelStyle),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: InclinometerGauge(
                                                  controller: _trimCtrl,
                                                  maxAngle: 45,
                                                  style: style,
                                                  mode: mode,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4),
                                                  child: ListenableBuilder(
                                                    listenable: _trimCtrl,
                                                    builder: (_, __) => Text(
                                                      '${_trimCtrl.value > 0 ? '+' : ''}${_trimCtrl.value.toStringAsFixed(1)}°',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: const Color(0xFF0F2030)),

                  // ── Right column: CO2 arc + battery banks ─────────────
                  Container(
                    width: 120,
                    color: const Color(0xFF070C16),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: Column(
                      children: [
                        const Text('CO2 LEVEL', style: labelStyle),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 130,
                          child: ListenableBuilder(
                            listenable: _co2Ctrl,
                            builder: (_, __) => ArcGauge(
                              controller: _co2Ctrl,
                              min: 0,
                              max: 5000,
                              startAngleDeg: 150,
                              sweepAngleDeg: 240,
                              centerLabel:
                                  '${_co2Ctrl.value.toStringAsFixed(0)} ppm',
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: const Color(0xFF0F2030)),
                        const SizedBox(height: 10),
                        const Text('BATTERY BANKS', style: labelStyle),
                        const SizedBox(height: 8),
                        _BatteryRow(
                            label: 'BANK A',
                            ctrl: _battACtrl,
                            style: style,
                            mode: mode),
                        const SizedBox(height: 6),
                        _BatteryRow(
                            label: 'BANK B',
                            ctrl: _battBCtrl,
                            style: style,
                            mode: mode),
                        const SizedBox(height: 6),
                        _BatteryRow(
                            label: 'BANK C',
                            ctrl: _battCCtrl,
                            style: style,
                            mode: mode),
                      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3A7AAA),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            ListenableBuilder(
              listenable: ctrl,
              builder: (_, __) => Text(
                '${ctrl.value.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFF3A7AAA),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 28,
          child: SegmentedGauge.battery(
            controller: ctrl,
            style: style,
            mode: mode,
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
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 5)
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
              color: color,
              fontSize: 9,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
