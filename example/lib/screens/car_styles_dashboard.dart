import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

/// Showcases three distinct automotive instrument-cluster design languages,
/// all built from the same gauge_kit widget set — proof that one component
/// library can span everything from minimalist EV displays to classic
/// analog gauge clusters.
class CarStylesDashboardScreen extends StatefulWidget {
  const CarStylesDashboardScreen({super.key});

  @override
  State<CarStylesDashboardScreen> createState() =>
      _CarStylesDashboardScreenState();
}

class _CarStylesDashboardScreenState extends State<CarStylesDashboardScreen> {
  int _styleIndex = 0;

  static const _styles = [
    (label: 'EV Minimal', icon: Icons.electric_bolt),
    (label: 'Analog Twin', icon: Icons.speed),
    (label: 'Centered Tach', icon: Icons.dashboard_customize),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < _styles.length; i++) ...[
                    Expanded(
                      child: _StylePill(
                        label: _styles[i].label,
                        icon: _styles[i].icon,
                        selected: _styleIndex == i,
                        onTap: () => setState(() => _styleIndex = i),
                      ),
                    ),
                    if (i != _styles.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _styleIndex,
                children: const [
                  _MinimalistEvCluster(),
                  _AnalogTwinDialCluster(),
                  _CenteredTachCluster(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StylePill extends StatelessWidget {
  const _StylePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A2A2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF666666) : const Color(0xFF2A2A2A),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Style 1 — Minimalist EV cluster
// A single-screen minimalist layout in the spirit of modern EV driver
// displays: a plain digital speed readout, a centre-zero power/regen meter,
// a battery arc, and a small heading compass.
// ─────────────────────────────────────────────────────────────────────────

class _MinimalistEvCluster extends StatefulWidget {
  const _MinimalistEvCluster();

  @override
  State<_MinimalistEvCluster> createState() => _MinimalistEvClusterState();
}

class _MinimalistEvClusterState extends State<_MinimalistEvCluster> {
  final _speedCtrl = GaugeController(initialValue: 62.0);
  final _powerCtrl = GaugeController(initialValue: 25.0);
  final _batteryCtrl = GaugeController(initialValue: 74.0);
  final _headingCtrl = GaugeController(initialValue: 40.0);
  final _autopilotCtrl = GaugeController(initialValue: 0.0);

  Timer? _timer;
  double _phase = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _phase += 0.15;
      _speedCtrl.value = (65.0 + 35.0 * sin(_phase * 0.5)).clamp(0.0, 200.0);
      _powerCtrl.value = (30.0 * sin(_phase * 0.8)).clamp(-100.0, 200.0);
      _batteryCtrl.value = (_batteryCtrl.value - 0.01).clamp(5.0, 100.0);
      _headingCtrl.value = (_headingCtrl.value + 0.6) % 360.0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speedCtrl.dispose();
    _powerCtrl.dispose();
    _batteryCtrl.dispose();
    _headingCtrl.dispose();
    _autopilotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = ExecutiveGaugeStyle();
    const mode = GaugeMode.instrument;
    const dim = TextStyle(
      color: Color(0xFF666666),
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _GearPill(gear: 'D'),
              SizedBox(
                width: 26,
                height: 26,
                child: StatusGauge(
                  controller: _autopilotCtrl,
                  radius: 13,
                  label: 'Assist',
                  style: style,
                  mode: mode,
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: RadialGauge(
                  controller: _headingCtrl,
                  min: 0,
                  max: 360,
                  startAngleDeg: 270,
                  sweepAngleDeg: 360,
                  majorDivisions: 4,
                  minorDivisions: 0,
                  showLabels: false,
                  style: style,
                  mode: mode,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ListenableBuilder(
              listenable: _speedCtrl,
              builder: (_, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _speedCtrl.value.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 96,
                      fontWeight: FontWeight.w200,
                      height: 1.0,
                    ),
                  ),
                  const Text('km/h', style: dim),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('REGEN · POWER', style: dim),
                    const SizedBox(height: 6),
                    DeltaGauge(
                      controller: _powerCtrl,
                      baseline: 0,
                      min: -100,
                      max: 200,
                      unit: 'kW',
                      lowerIsBetter: true,
                      style: style,
                      mode: mode,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    const Text('BATTERY', style: dim),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 90,
                      child: ArcGauge(
                        controller: _batteryCtrl,
                        min: 0,
                        max: 100,
                        ranges: const [
                          GaugeRange(min: 0, max: 20, color: Color(0xFFCC3311)),
                        ],
                        unitText: '%',
                        style: style,
                        mode: mode,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Style 2 — Analog twin-dial cluster
// A classic German-luxury-style cluster: two large opaque-faced analog
// dials (tachometer + speedometer) flanking a digital trip computer, with
// small fuel/temp gauges below. Uses RadialGauge's `fillColor` for the
// solid dial face — a skeuomorphic look impossible before that parameter
// existed.
// ─────────────────────────────────────────────────────────────────────────

class _AnalogTwinDialCluster extends StatefulWidget {
  const _AnalogTwinDialCluster();

  @override
  State<_AnalogTwinDialCluster> createState() => _AnalogTwinDialClusterState();
}

class _AnalogTwinDialClusterState extends State<_AnalogTwinDialCluster> {
  final _rpmCtrl = GaugeController(initialValue: 2200.0);
  final _speedCtrl = GaugeController(initialValue: 90.0);
  final _fuelCtrl = GaugeController(initialValue: 62.0);
  final _tempCtrl = GaugeController(initialValue: 88.0);

  Timer? _timer;
  double _phase = 0.0;

  static const _dialFace = Color(0xFF262626);
  static const _needleOrange = Color(0xFFFF7A00);
  static const _tickWhite = Color(0xFFE8E8E8);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _phase += 0.14;
      final speed = 95.0 + 60.0 * sin(_phase * 0.6);
      _speedCtrl.value = speed.clamp(0.0, 280.0);
      _rpmCtrl.value = (1800.0 + speed * 30.0).clamp(800.0, 8000.0);
      _fuelCtrl.value = (_fuelCtrl.value - 0.01).clamp(5.0, 100.0);
      _tempCtrl.value = (88.0 + 2.0 * sin(_phase * 0.2)).clamp(0.0, 120.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rpmCtrl.dispose();
    _speedCtrl.dispose();
    _fuelCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  GaugeStyle get _dialStyle => const ExecutiveGaugeStyle().override(
        const GaugeTokensOverride(
          needleColor: _needleOrange,
          knobColor: _needleOrange,
          knobRadius: 4.0,
          majorTick:
              GaugeTickStyle(color: _tickWhite, strokeWidth: 2, length: 12),
          minorTick: GaugeTickStyle(
              color: Color(0xFF999999), strokeWidth: 1, length: 6),
          labelStyle: TextStyle(
              color: _tickWhite, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const mode = GaugeMode.instrument;
    const dim = TextStyle(
      color: Color(0xFF666666),
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: RadialGauge.tachometer(
                    controller: _rpmCtrl,
                    redlineRpm: 6500,
                    maxRpm: 8000,
                    fillColor: _dialFace,
                    style: _dialStyle,
                    mode: mode,
                  ),
                ),
                const SizedBox(
                  width: 84,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('GEAR', style: dim),
                      SizedBox(height: 2),
                      Text(
                        'D',
                        style: TextStyle(
                          color: _needleOrange,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RadialGauge.speedometer(
                    controller: _speedCtrl,
                    max: 280,
                    showCenterLabel: true,
                    centerLabelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    fillColor: _dialFace,
                    style: _dialStyle,
                    mode: mode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('FUEL', style: dim),
                      Expanded(
                        child: LinearGauge(
                          controller: _fuelCtrl,
                          min: 0,
                          max: 100,
                          showLabels: false,
                          showTicks: false,
                          barRadius: 4,
                          ranges: const [
                            GaugeRange(
                                min: 0, max: 15, color: Color(0xFFCC3311)),
                          ],
                          style: _dialStyle,
                          mode: mode,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('COOLANT', style: dim),
                      Expanded(
                        child: LinearGauge(
                          controller: _tempCtrl,
                          min: 0,
                          max: 120,
                          showLabels: false,
                          showTicks: false,
                          barRadius: 4,
                          ranges: const [
                            GaugeRange(
                                min: 95, max: 120, color: Color(0xFFCC3311)),
                          ],
                          style: _dialStyle,
                          mode: mode,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Style 3 — Centered tachometer cluster
// A five-dial classic sports-car cluster: an oversized centre tachometer
// flanked by four smaller instruments, all sharing a cream analog face —
// the opposite palette from the twin-dial cluster, demonstrating the same
// `fillColor` customization point.
// ─────────────────────────────────────────────────────────────────────────

class _CenteredTachCluster extends StatefulWidget {
  const _CenteredTachCluster();

  @override
  State<_CenteredTachCluster> createState() => _CenteredTachClusterState();
}

class _CenteredTachClusterState extends State<_CenteredTachCluster> {
  final _rpmCtrl = GaugeController(initialValue: 3400.0);
  final _speedCtrl = GaugeController(initialValue: 110.0);
  final _fuelCtrl = GaugeController(initialValue: 58.0);
  final _tempCtrl = GaugeController(initialValue: 90.0);
  final _oilCtrl = GaugeController(initialValue: 4.2);

  Timer? _timer;
  double _phase = 0.0;

  static const _dialFace = Color(0xFFF2F0EA);
  static const _dialInk = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _phase += 0.14;
      final speed = 120.0 + 50.0 * sin(_phase * 0.5);
      _speedCtrl.value = speed.clamp(0.0, 300.0);
      _rpmCtrl.value = (2500.0 + speed * 32.0).clamp(800.0, 9000.0);
      _fuelCtrl.value = (_fuelCtrl.value - 0.01).clamp(5.0, 100.0);
      _tempCtrl.value = (90.0 + 2.0 * sin(_phase * 0.2)).clamp(0.0, 130.0);
      _oilCtrl.value = (3.5 + 0.6 * sin(_phase * 0.9)).clamp(0.0, 8.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rpmCtrl.dispose();
    _speedCtrl.dispose();
    _fuelCtrl.dispose();
    _tempCtrl.dispose();
    _oilCtrl.dispose();
    super.dispose();
  }

  GaugeStyle get _dialStyle => const MaterialGaugeStyle().override(
        const GaugeTokensOverride(
          needleColor: _dialInk,
          knobColor: _dialInk,
          knobRadius: 2.0,
          trackColor: Color(0xFFBBBBB0),
          majorTick:
              GaugeTickStyle(color: _dialInk, strokeWidth: 2, length: 10),
          minorTick: GaugeTickStyle(
              color: Color(0xFF555550), strokeWidth: 1, length: 5),
          labelStyle: TextStyle(
              color: _dialInk, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );

  Widget _smallDial({
    required GaugeController controller,
    required double min,
    required double max,
    required String unit,
    List<GaugeRange> ranges = const [],
  }) {
    return RadialGauge(
      controller: controller,
      min: min,
      max: max,
      majorDivisions: 4,
      ranges: ranges,
      showCenterLabel: true,
      unitText: unit,
      centerLabelStyle: const TextStyle(
          color: _dialInk, fontSize: 13, fontWeight: FontWeight.bold),
      fillColor: _dialFace,
      style: _dialStyle,
      mode: GaugeMode.instrument,
    );
  }

  @override
  Widget build(BuildContext context) {
    const dim = TextStyle(
      color: Color(0xFF888888),
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('FUEL', style: dim),
                      Expanded(
                        child: _smallDial(
                          controller: _fuelCtrl,
                          min: 0,
                          max: 100,
                          unit: '%',
                          ranges: const [
                            GaugeRange(
                                min: 0, max: 15, color: Color(0xFFCC3311)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('SPEED', style: dim),
                      Expanded(
                        child: _smallDial(
                          controller: _speedCtrl,
                          min: 0,
                          max: 300,
                          unit: 'km/h',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Text('TACHOMETER', style: dim),
                      Expanded(
                        child: RadialGauge.tachometer(
                          controller: _rpmCtrl,
                          redlineRpm: 7000,
                          maxRpm: 9000,
                          showCenterLabel: true,
                          centerLabelStyle: const TextStyle(
                            color: _dialInk,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          fillColor: _dialFace,
                          style: _dialStyle,
                          mode: GaugeMode.instrument,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('COOLANT', style: dim),
                      Expanded(
                        child: _smallDial(
                          controller: _tempCtrl,
                          min: 0,
                          max: 130,
                          unit: '°C',
                          ranges: const [
                            GaugeRange(
                                min: 100, max: 130, color: Color(0xFFCC3311)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('OIL', style: dim),
                      Expanded(
                        child: _smallDial(
                          controller: _oilCtrl,
                          min: 0,
                          max: 8,
                          unit: 'bar',
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
    );
  }
}

class _GearPill extends StatelessWidget {
  const _GearPill({required this.gear});
  final String gear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF333333)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        gear,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
