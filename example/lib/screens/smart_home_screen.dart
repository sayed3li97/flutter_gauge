import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0D1117);
const _kCard = Color(0xFF161B22);
const _kBorder = Color(0xFF30363D);
const _kDim = Color(0xFF8B949E);

const _kSolar = Color(0xFFFFCA28);
const _kBattery = Color(0xFF66BB6A);
const _kGrid = Color(0xFFFF7043);
const _kLiving = Color(0xFF42A5F5);
const _kBedroom = Color(0xFFAB47BC);
const _kKitchen = Color(0xFFFF7043);
const _kGarage = Color(0xFFFFCA28);

// Power modes (by kW)
const _kEco = Color(0xFF66BB6A);
const _kNormal = Color(0xFFFFCA28);
const _kPeak = Color(0xFFFF7043);

// ── Screen ────────────────────────────────────────────────────────────────────

class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  // Power draw 0–10 kW (whole house)
  final _powerCtrl = GaugeController(initialValue: 3.2);
  // Solar generation 0–6 kW
  final _solarCtrl = GaugeController(initialValue: 4.1);
  // Grid import 0–5 kW (reverse arc: lower = more budget left)
  final _gridCtrl = GaugeController(initialValue: 1.8);
  // Battery charge 0–100 %
  final _batteryCtrl = GaugeController(initialValue: 72.0);
  // Room usage today, 0–5 kWh each
  final _livingCtrl = GaugeController(initialValue: 2.4);
  final _bedroomCtrl = GaugeController(initialValue: 1.8);
  final _kitchenCtrl = GaugeController(initialValue: 3.9);
  final _garageCtrl = GaugeController(initialValue: 1.2);

  Timer? _timer;
  final _rng = Random();
  double _phase = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      _phase += 0.15;
      _solarCtrl.value =
          (4.5 + 1.5 * sin(_phase * 0.7) + _rng.nextDouble() * 0.3).clamp(0, 6);
      _powerCtrl.value =
          (3.5 + 2.5 * sin(_phase * 0.4) + _rng.nextDouble() * 0.8).clamp(0.5, 10);
      _gridCtrl.value =
          ((_powerCtrl.value - _solarCtrl.value).clamp(0, 5) + _rng.nextDouble() * 0.2)
              .clamp(0, 5);
      final surplus = (_solarCtrl.value - _powerCtrl.value).clamp(-2.0, 2.0);
      _batteryCtrl.value = (_batteryCtrl.value + surplus * 0.4).clamp(5, 100);
      _livingCtrl.value = (_livingCtrl.value + 0.04 * _rng.nextDouble()).clamp(0, 5);
      _kitchenCtrl.value = (_kitchenCtrl.value + 0.03 * _rng.nextDouble()).clamp(0, 5);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [
      _powerCtrl, _solarCtrl, _gridCtrl, _batteryCtrl,
      _livingCtrl, _bedroomCtrl, _kitchenCtrl, _garageCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static Color _modeColor(double kw) {
    if (kw < 3.5) return _kEco;
    if (kw < 7.0) return _kNormal;
    return _kPeak;
  }

  static String _modeLabel(double kw) {
    if (kw < 3.5) return 'ECO';
    if (kw < 7.0) return 'NORMAL';
    return 'PEAK';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPowerSection(),
              const SizedBox(height: 16),
              _buildGenerationSection(),
              const SizedBox(height: 16),
              _buildRoomSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sections ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.home_filled, color: _kBattery, size: 22),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SMART HOME',
                style: TextStyle(
                  color: _kBattery,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                'Energy Monitor  •  Live',
                style: TextStyle(color: _kDim, fontSize: 11),
              ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: _batteryCtrl,
          builder: (_, __) => _Chip(
            '${_batteryCtrl.value.toStringAsFixed(0)}%',
            Icons.battery_charging_full,
            _kBattery,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('POWER CONSUMPTION'),
          const SizedBox(height: 4),
          const Text(
            'RadialGauge · child  ·  annotations  ·  labelFormatter  ·  unitText  ·  glow',
            style: TextStyle(color: _kDim, fontSize: 9, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 290,
            child: ListenableBuilder(
              listenable: _powerCtrl,
              builder: (_, __) {
                final kw = _powerCtrl.value;
                final color = _modeColor(kw);
                final label = _modeLabel(kw);
                return RadialGauge(
                  controller: _powerCtrl,
                  min: 0,
                  max: 10,
                  majorDivisions: 10,
                  minorDivisions: 5,
                  showLabels: true,
                  // ← labelFormatter: custom tick text
                  labelFormatter: (v) => '${v.toInt()}',
                  // ← unitText: appended to centre value
                  unitText: 'kW',
                  showCenterLabel: false,
                  ranges: [
                    const GaugeRange(min: 0, max: 3.5, color: Color(0x3366BB6A)),
                    const GaugeRange(min: 3.5, max: 7.0, color: Color(0x33FFCA28)),
                    const GaugeRange(min: 7.0, max: 10, color: Color(0x33FF7043)),
                  ],
                  // ← annotations: zone labels pinned on the arc
                  annotations: [
                    GaugeAnnotation(
                      value: 1.0,
                      radiusFraction: 0.78,
                      widget: _ZoneLabel('ECO', _kEco),
                    ),
                    GaugeAnnotation(
                      value: 5.0,
                      radiusFraction: 0.78,
                      widget: _ZoneLabel('NORM', _kNormal),
                    ),
                    GaugeAnnotation(
                      value: 9.0,
                      radiusFraction: 0.78,
                      widget: _ZoneLabel('PEAK', _kPeak),
                    ),
                  ],
                  style: _GlowStyle(color: color, trackWidth: 10),
                  // ← child: Flutter widget centered on the gauge face
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: color, size: 22),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('GENERATION & STORAGE'),
          const SizedBox(height: 4),
          const Text(
            'ArcGauge · child  ·  header/footer  ·  fillColor  ·  widgetIndicator  ·  reverse  ·  unitText',
            style: TextStyle(color: _kDim, fontSize: 9, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Solar: child + header/footer ──────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'child + header/footer',
                      style: TextStyle(color: _kDim, fontSize: 8, letterSpacing: 0.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 170,
                      child: ArcGauge(
                        controller: _solarCtrl,
                        min: 0,
                        max: 6,
                        showValue: true,
                        unitText: 'kW',
                        style: _GlowStyle(color: _kSolar, trackWidth: 9),
                        // ← header above the arc
                        header: const Text(
                          'SOLAR',
                          style: TextStyle(
                            color: _kDim,
                            fontSize: 9,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // ← footer below the arc
                        footer: const Text(
                          'Generation',
                          style: TextStyle(color: _kDim, fontSize: 9),
                        ),
                        // ← child in the centre
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          color: _kSolar,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── Battery: fillColor + widgetIndicator ──────────────────────
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'fillColor + widgetIndicator',
                      style: TextStyle(color: _kDim, fontSize: 8, letterSpacing: 0.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 170,
                      child: ArcGauge(
                        controller: _batteryCtrl,
                        min: 0,
                        max: 100,
                        showValue: true,
                        unitText: '%',
                        // ← fillColor: tints the inner circle
                        fillColor: const Color(0xFF0B1F0F),
                        style: _GlowStyle(color: _kBattery, trackWidth: 9),
                        // ← widgetIndicator: dot tracks the arc tip
                        widgetIndicator: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _kBattery,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _kBattery.withValues(alpha: 0.55),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── Grid: reverse + child ─────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'reverse + child',
                      style: TextStyle(color: _kDim, fontSize: 8, letterSpacing: 0.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 170,
                      child: ArcGauge(
                        controller: _gridCtrl,
                        min: 0,
                        max: 5,
                        // ← reverse: fills from the far end (budget remaining)
                        reverse: true,
                        showValue: false,
                        style: _GlowStyle(color: _kGrid, trackWidth: 9),
                        header: const Text(
                          'GRID',
                          style: TextStyle(
                            color: _kDim,
                            fontSize: 9,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        footer: const Text(
                          'Budget left',
                          style: TextStyle(color: _kDim, fontSize: 9),
                        ),
                        child: ListenableBuilder(
                          listenable: _gridCtrl,
                          builder: (_, __) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, color: _kGrid, size: 18),
                              Text(
                                '${_gridCtrl.value.toStringAsFixed(1)}kW',
                                style: const TextStyle(
                                  color: _kGrid,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildRoomSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel("TODAY'S ROOM USAGE"),
          const SizedBox(height: 4),
          const Text(
            'LinearGauge · leading  ·  trailing  ·  center  ·  widgetIndicator  ·  barRadius  ·  showValue',
            style: TextStyle(color: _kDim, fontSize: 9, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          const Text(
            'Budget: 5 kWh / room / day',
            style: TextStyle(color: _kDim, fontSize: 10),
          ),
          const SizedBox(height: 16),
          // Living room — leading + widgetIndicator
          _RoomRow(
            icon: Icons.weekend,
            label: 'Living Room',
            hint: 'widgetIndicator',
            ctrl: _livingCtrl,
            color: _kLiving,
            widgetIndicator: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _kLiving,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kLiving.withValues(alpha: 0.55),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bedroom — leading + trailing
          _RoomRow(
            icon: Icons.bed,
            label: 'Bedroom',
            hint: 'trailing',
            ctrl: _bedroomCtrl,
            color: _kBedroom,
            trailing: const Icon(Icons.nightlight_round, color: _kDim, size: 16),
          ),
          const SizedBox(height: 12),
          // Kitchen — leading + center overlay
          _RoomRowWithCenter(
            icon: Icons.kitchen,
            label: 'Kitchen',
            hint: 'center overlay',
            ctrl: _kitchenCtrl,
            color: _kKitchen,
          ),
          const SizedBox(height: 12),
          // Garage — leading + showValue
          _RoomRow(
            icon: Icons.electric_car,
            label: 'Garage / EV',
            hint: 'showValue + unitText',
            ctrl: _garageCtrl,
            color: _kGarage,
            showValue: true,
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _GlowStyle extends GaugeStyle {
  const _GlowStyle({required this.color, this.glowRadius = 8.0, this.trackWidth = 10.0});
  final Color color;
  final double glowRadius;
  final double trackWidth;

  @override
  GaugeTokens resolve(BuildContext context, GaugeMode mode) {
    return GaugeTokens(
      trackColor: const Color(0xFF21262D),
      trackStrokeWidth: trackWidth,
      trackStrokeCap: StrokeCap.round,
      valueColor: color,
      valueStrokeWidth: trackWidth + 2,
      valueGlowRadius: glowRadius,
      valueGlowColor: color.withValues(alpha: 0.32),
      needleColor: color,
      knobColor: color,
      knobRadius: 6,
      knobBorderWidth: 0,
      labelStyle: const TextStyle(color: _kDim, fontSize: 10),
      majorTick: const GaugeTickStyle(color: Color(0xFF444D56), strokeWidth: 1.5, length: 10),
      minorTick: const GaugeTickStyle(color: Color(0xFF2D333B), strokeWidth: 1.0, length: 5),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _kBattery,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, this.icon, this.color);
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.icon,
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.color,
    this.trailing,
    this.widgetIndicator,
    this.showValue = false,
  });

  final IconData icon;
  final String label;
  final String hint;
  final GaugeController ctrl;
  final Color color;
  final Widget? trailing;
  final Widget? widgetIndicator;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: _kDim, fontSize: 11)),
            const SizedBox(width: 6),
            Text(
              '($hint)',
              style: const TextStyle(color: Color(0xFF484F58), fontSize: 9),
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: ctrl,
              builder: (_, __) => Text(
                '${ctrl.value.toStringAsFixed(1)} kWh',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 26,
          child: LinearGauge(
            controller: ctrl,
            min: 0,
            max: 5,
            showLabels: false,
            showTicks: false,
            barRadius: 8,
            showValue: showValue,
            unitText: showValue ? 'kWh' : null,
            trailing: trailing,
            widgetIndicator: widgetIndicator,
            ranges: [
              GaugeRange(min: 4.0, max: 5.0, color: _kKitchen.withValues(alpha: 0.55)),
            ],
            style: _GlowStyle(color: color, trackWidth: 14, glowRadius: 0),
          ),
        ),
      ],
    );
  }
}

class _RoomRowWithCenter extends StatelessWidget {
  const _RoomRowWithCenter({
    required this.icon,
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String hint;
  final GaugeController ctrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: _kDim, fontSize: 11)),
            const SizedBox(width: 6),
            Text(
              '($hint)',
              style: const TextStyle(color: Color(0xFF484F58), fontSize: 9),
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: ctrl,
              builder: (_, __) => Text(
                '${ctrl.value.toStringAsFixed(1)} kWh',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 26,
          child: LinearGauge(
            controller: ctrl,
            min: 0,
            max: 5,
            showLabels: false,
            showTicks: false,
            barRadius: 8,
            showValue: false,
            ranges: [
              GaugeRange(min: 4.0, max: 5.0, color: _kKitchen.withValues(alpha: 0.55)),
            ],
            style: _GlowStyle(color: color, trackWidth: 14, glowRadius: 0),
            // ← center: overlay widget — shows warning when usage is high
            center: ListenableBuilder(
              listenable: ctrl,
              builder: (_, __) => ctrl.value >= 4.0
                  ? const Text(
                      '⚠  HIGH USAGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
