import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class FlightDashboardScreen extends StatefulWidget {
  const FlightDashboardScreen({super.key});

  @override
  State<FlightDashboardScreen> createState() => _FlightDashboardScreenState();
}

class _FlightDashboardScreenState extends State<FlightDashboardScreen> {
  // Artificial Horizon
  final _pitchCtrl = GaugeController(initialValue: 2.0);
  final _rollCtrl = GaugeController(initialValue: 8.0);

  // Airspeed tape (knots)
  final _airspeedCtrl = GaugeController(initialValue: 142.0);

  // Altimeter tape (feet)
  final _altCtrl = GaugeController(initialValue: 3500.0);

  // Compass / heading
  final _headingCtrl = GaugeController(initialValue: 275.0);

  // Inclinometer (slip/skid)
  final _inclinCtrl = GaugeController(initialValue: 0.0);

  // VSI: vertical speed (fpm)  -2000..+2000, center=0
  final _vsiCtrl = GaugeController(initialValue: 0.0);

  // G-force 0..5
  final _gforceCtrl = GaugeController(initialValue: 1.0);

  Timer? _timer;
  double _phase = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      _phase += 0.08;

      // Pitch: gentle oscillation ±5°
      _pitchCtrl.value = 2.0 + 5.0 * sin(_phase * 0.7);

      // Roll: bank in and out ±15°
      _rollCtrl.value = 8.0 * sin(_phase * 0.5) + 6.0 * sin(_phase * 1.1);

      // Airspeed: 120–160 kts
      _airspeedCtrl.value = 140.0 + 20.0 * sin(_phase * 0.4);

      // Altitude: 3200–3800 ft with slow climb
      _altCtrl.value = 3500.0 + 300.0 * sin(_phase * 0.3);

      // Heading: slow turn
      _headingCtrl.value = (275.0 + 15.0 * sin(_phase * 0.2)) % 360;

      // Slip: small oscillation
      _inclinCtrl.value = 2.0 * sin(_phase * 1.3);

      // VSI tracks altitude derivative (approx)
      _vsiCtrl.value = (300.0 * cos(_phase * 0.3) * 0.3).clamp(-2000.0, 2000.0);

      // G-force: slight variation around 1G
      _gforceCtrl.value = (1.0 + 0.15 * sin(_phase * 0.9)).clamp(0.0, 5.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pitchCtrl.dispose();
    _rollCtrl.dispose();
    _airspeedCtrl.dispose();
    _altCtrl.dispose();
    _headingCtrl.dispose();
    _inclinCtrl.dispose();
    _vsiCtrl.dispose();
    _gforceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF080A12);
    const cyan = Color(0xFF00CCFF);
    const labelStyle = TextStyle(
      color: Color(0xFF88AACC),
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
    );
    const style = ExecutiveGaugeStyle();
    const mode = GaugeMode.instrument;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Title bar ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF060810),
                border: Border(bottom: BorderSide(color: Color(0xFF1A2A3A))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PRIMARY FLIGHT DISPLAY',
                    style: TextStyle(
                      color: Color(0xFF00CCFF),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Row(children: [
                    _PfdChip(label: 'NAV', active: true),
                    const SizedBox(width: 8),
                    _PfdChip(label: 'AP', active: true),
                    const SizedBox(width: 8),
                    _PfdChip(label: 'HOLD', active: false),
                  ]),
                ],
              ),
            ),

            // ── Main PFD area ──────────────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  // Left: Airspeed tape + digital readout
                  Container(
                    width: 100,
                    color: const Color(0xFF060810),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('AIRSPEED', style: labelStyle),
                        ),
                        Expanded(
                          child: TapeGauge.airspeed(
                            controller: _airspeedCtrl,
                            style: style,
                            mode: mode,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Digital cyan readout box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001822),
                            border: Border.all(color: cyan, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListenableBuilder(
                            listenable: _airspeedCtrl,
                            builder: (_, __) => Text(
                              '${_airspeedCtrl.value.toStringAsFixed(0)} kts',
                              style: const TextStyle(
                                color: cyan,
                                fontSize: 16,
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

                  // Center: Horizon + instruments below
                  Expanded(
                    child: Column(
                      children: [
                        // Artificial horizon — dominant widget
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ArtificialHorizonGauge(
                              pitchController: _pitchCtrl,
                              rollController: _rollCtrl,
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ),

                        // Compass below horizon
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Column(
                              children: [
                                const Text('HDG', style: labelStyle),
                                Expanded(
                                  child: RadialGauge.compass(
                                    controller: _headingCtrl,
                                    style: style,
                                    mode: mode,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom instrument row
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                // Inclinometer
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('SLIP', style: labelStyle),
                                      Expanded(
                                        child: InclinometerGauge(
                                          controller: _inclinCtrl,
                                          maxAngle: 15,
                                          style: style,
                                          mode: mode,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // VSI with live overlay
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('VSI fpm', style: labelStyle),
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: ListenableBuilder(
                                                listenable: _vsiCtrl,
                                                builder: (_, __) => ArcGauge(
                                                  controller: _vsiCtrl,
                                                  min: -2000,
                                                  max: 2000,
                                                  startAngleDeg: 150,
                                                  sweepAngleDeg: 240,
                                                  centerLabel:
                                                      '${_vsiCtrl.value > 0 ? '+' : ''}${_vsiCtrl.value.toStringAsFixed(0)}',
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

                                const SizedBox(width: 8),

                                // G-Force with live overlay
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('G-FORCE', style: labelStyle),
                                      Expanded(
                                        child: ListenableBuilder(
                                          listenable: _gforceCtrl,
                                          builder: (_, __) => ArcGauge(
                                            controller: _gforceCtrl,
                                            min: 0,
                                            max: 5,
                                            startAngleDeg: 150,
                                            sweepAngleDeg: 240,
                                            centerLabel:
                                                '${_gforceCtrl.value.toStringAsFixed(1)} G',
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
                      ],
                    ),
                  ),

                  // Right: Altimeter tape + digital readout
                  Container(
                    width: 100,
                    color: const Color(0xFF060810),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('ALTITUDE', style: labelStyle),
                        ),
                        Expanded(
                          child: TapeGauge.altimeter(
                            controller: _altCtrl,
                            style: style,
                            mode: mode,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Digital cyan readout box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001822),
                            border: Border.all(color: cyan, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListenableBuilder(
                            listenable: _altCtrl,
                            builder: (_, __) => Text(
                              '${_altCtrl.value.toStringAsFixed(0)} ft',
                              style: const TextStyle(
                                color: cyan,
                                fontSize: 16,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PfdChip extends StatelessWidget {
  final String label;
  final bool active;
  const _PfdChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF001A2A) : const Color(0xFF0D0D0D),
        border: Border.all(
          color: active ? const Color(0xFF00CCFF) : const Color(0xFF222222),
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF00CCFF) : const Color(0xFF444444),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
