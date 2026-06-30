import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0D1117);
const _kCard = Color(0xFF161B22);
const _kBorder = Color(0xFF30363D);
const _kDim = Color(0xFF8B949E);
const _kText = Color(0xFFCDD9E5);

const _kSolar = Color(0xFFFFCA28);
const _kBattery = Color(0xFF4CAF50);
const _kGrid = Color(0xFFFF7043);
const _kLiving = Color(0xFF42A5F5);
const _kBedroom = Color(0xFFAB47BC);
const _kKitchen = Color(0xFFEF5350); // red — distinct from orange grid
const _kGarage = Color(0xFF26C6DA); // cyan — distinct from yellow solar

const _kEco = Color(0xFF4CAF50);
const _kNormal = Color(0xFFFFCA28);
const _kPeak = Color(0xFFEF5350);
const _kWarning = Color(0xFFF57C00); // amber, for room budget warnings

// ── Configuration ─────────────────────────────────────────────────────────────

/// Customisation knobs for the Smart Home Energy Monitor dashboard.
/// All fields have sensible defaults; pass a custom instance to [SmartHomeScreen]
/// to adjust capacity limits, thresholds, and visual style.
class SmartHomeConfig {
  const SmartHomeConfig({
    this.powerMax = 10.0,
    this.solarMax = 6.0,
    this.gridMax = 5.0,
    this.roomBudgetKwh = 5.0,
    this.warningFraction = 0.80,
    this.ecoThreshold = 3.5,
    this.peakThreshold = 7.0,
    this.gaugeTrackWidth = 9.0,
    this.gaugeGlowRadius = 7.0,
    this.barHeight = 28.0,
    this.barRadius = 10.0,
  });

  /// Maximum whole-house power on the RadialGauge (kW).
  final double powerMax;

  /// Maximum solar generation on the Solar ArcGauge (kW).
  final double solarMax;

  /// Maximum grid import on the Grid ArcGauge (kW).
  final double gridMax;

  /// Per-room daily energy budget (kWh) — the LinearGauge max.
  final double roomBudgetKwh;

  /// Fraction of [roomBudgetKwh] at which the HIGH USAGE warning appears (0–1).
  final double warningFraction;

  /// Power (kW) below which the house is in Eco mode.
  final double ecoThreshold;

  /// Power (kW) above which the house enters Peak mode.
  final double peakThreshold;

  /// Arc/needle gauge track stroke width in logical pixels.
  final double gaugeTrackWidth;

  /// Outer glow blur radius (0 = no glow).
  final double gaugeGlowRadius;

  /// Height of each room LinearGauge bar in logical pixels.
  final double barHeight;

  /// Corner radius of the filled LinearGauge bar.
  final double barRadius;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({
    super.key,
    this.config = const SmartHomeConfig(),
  });

  /// Dashboard configuration — thresholds, gauge sizes, etc.
  final SmartHomeConfig config;

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  SmartHomeConfig get cfg => widget.config;

  final _powerCtrl = GaugeController(initialValue: 3.2);
  final _solarCtrl = GaugeController(initialValue: 4.1);
  final _gridCtrl = GaugeController(initialValue: 1.8);
  final _batteryCtrl = GaugeController(initialValue: 72.0);
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
          (4.5 + 1.5 * sin(_phase * 0.7) + _rng.nextDouble() * 0.3)
              .clamp(0, cfg.solarMax);
      _powerCtrl.value =
          (3.5 + 2.5 * sin(_phase * 0.4) + _rng.nextDouble() * 0.8)
              .clamp(0.5, cfg.powerMax);
      _gridCtrl.value =
          ((_powerCtrl.value - _solarCtrl.value).clamp(0, cfg.gridMax) +
                  _rng.nextDouble() * 0.2)
              .clamp(0, cfg.gridMax);
      final surplus = (_solarCtrl.value - _powerCtrl.value).clamp(-2.0, 2.0);
      _batteryCtrl.value = (_batteryCtrl.value + surplus * 0.4).clamp(5, 100);
      _livingCtrl.value = (_livingCtrl.value + 0.04 * _rng.nextDouble())
          .clamp(0, cfg.roomBudgetKwh);
      _kitchenCtrl.value = (_kitchenCtrl.value + 0.03 * _rng.nextDouble())
          .clamp(0, cfg.roomBudgetKwh);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [
      _powerCtrl,
      _solarCtrl,
      _gridCtrl,
      _batteryCtrl,
      _livingCtrl,
      _bedroomCtrl,
      _kitchenCtrl,
      _garageCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Color _modeColor(double kw) {
    if (kw < cfg.ecoThreshold) return _kEco;
    if (kw < cfg.peakThreshold) return _kNormal;
    return _kPeak;
  }

  String _modeLabel(double kw) {
    if (kw < cfg.ecoThreshold) return 'ECO';
    if (kw < cfg.peakThreshold) return 'NORMAL';
    return 'PEAK';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuickMetrics(),
                    const SizedBox(height: 12),
                    _buildPowerSection(),
                    const SizedBox(height: 12),
                    _buildGenerationSection(),
                    const SizedBox(height: 12),
                    _buildRoomSection(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_filled, color: _kBattery, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART HOME',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'Energy Monitor  ·  Live',
                  style: TextStyle(color: _kDim, fontSize: 10),
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: _batteryCtrl,
            builder: (_, __) {
              final pct = _batteryCtrl.value;
              final color = pct > 50
                  ? _kBattery
                  : pct > 20
                      ? _kNormal
                      : _kPeak;
              final icon = pct > 80
                  ? Icons.battery_full
                  : pct > 40
                      ? Icons.battery_4_bar
                      : Icons.battery_alert;
              return _StatusChip(
                  label: '${pct.toStringAsFixed(0)}%',
                  icon: icon,
                  color: color);
            },
          ),
        ],
      ),
    );
  }

  /// Four live metric tiles in a row — gives instant system-state overview.
  Widget _buildQuickMetrics() {
    return Row(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: _solarCtrl,
            builder: (_, __) => _MetricTile(
              icon: Icons.wb_sunny_rounded,
              label: 'Solar',
              value: '${_solarCtrl.value.toStringAsFixed(1)} kW',
              color: _kSolar,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ListenableBuilder(
            listenable: _powerCtrl,
            builder: (_, __) => _MetricTile(
              icon: Icons.bolt,
              label: 'House',
              value: '${_powerCtrl.value.toStringAsFixed(1)} kW',
              color: _modeColor(_powerCtrl.value),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ListenableBuilder(
            listenable: _gridCtrl,
            builder: (_, __) => _MetricTile(
              icon: Icons.electric_meter,
              label: 'Grid',
              value: '${_gridCtrl.value.toStringAsFixed(1)} kW',
              color: _kGrid,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ListenableBuilder(
            listenable: _batteryCtrl,
            builder: (_, __) => _MetricTile(
              icon: Icons.battery_charging_full,
              label: 'Battery',
              value: '${_batteryCtrl.value.toStringAsFixed(0)}%',
              color: _kBattery,
            ),
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
          Row(
            children: [
              const _SectionLabel('POWER CONSUMPTION'),
              const Spacer(),
              ListenableBuilder(
                listenable: _powerCtrl,
                builder: (_, __) => _StatusChip(
                  label: _modeLabel(_powerCtrl.value),
                  icon: Icons.bolt,
                  color: _modeColor(_powerCtrl.value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (ctx, constraints) {
            // Square gauge takes ~45% of the card width
            final gaugeSize = (constraints.maxWidth * 0.45).clamp(160.0, 300.0);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── RadialGauge (annotations · child · ranges · glow) ──────
                SizedBox(
                  width: gaugeSize,
                  height: gaugeSize,
                  child: ListenableBuilder(
                    listenable: _powerCtrl,
                    builder: (_, __) {
                      final kw = _powerCtrl.value;
                      final color = _modeColor(kw);
                      return RadialGauge(
                        controller: _powerCtrl,
                        min: 0,
                        max: cfg.powerMax,
                        majorDivisions: 10,
                        minorDivisions: 5,
                        showLabels: true,
                        labelFormatter: (v) => '${v.toInt()}',
                        unitText: 'kW',
                        showCenterLabel: false,
                        ranges: [
                          GaugeRange(
                            min: 0,
                            max: cfg.ecoThreshold,
                            color: const Color(0x334CAF50),
                          ),
                          GaugeRange(
                            min: cfg.ecoThreshold,
                            max: cfg.peakThreshold,
                            color: const Color(0x33FFCA28),
                          ),
                          GaugeRange(
                            min: cfg.peakThreshold,
                            max: cfg.powerMax,
                            color: const Color(0x33EF5350),
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            value: cfg.ecoThreshold * 0.28,
                            radiusFraction: 0.78,
                            widget: _ZoneLabel('ECO', _kEco),
                          ),
                          GaugeAnnotation(
                            value: (cfg.ecoThreshold + cfg.peakThreshold) / 2,
                            radiusFraction: 0.78,
                            widget: _ZoneLabel('NORM', _kNormal),
                          ),
                          GaugeAnnotation(
                            value: cfg.powerMax * 0.93,
                            radiusFraction: 0.78,
                            widget: _ZoneLabel('PEAK', _kPeak),
                          ),
                        ],
                        style: _GlowStyle(
                          color: color,
                          trackWidth: cfg.gaugeTrackWidth,
                          glowRadius: cfg.gaugeGlowRadius,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, color: color, size: 20),
                            Text(
                              _modeLabel(kw),
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // ── Stats panel fills remaining space ──────────────────────
                Expanded(child: _buildPowerStats()),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Live stats panel shown to the right of the RadialGauge.
  Widget _buildPowerStats() {
    return ListenableBuilder(
      listenable: Listenable.merge([_powerCtrl, _solarCtrl, _gridCtrl]),
      builder: (_, __) {
        final kw = _powerCtrl.value;
        final solar = _solarCtrl.value;
        final grid = _gridCtrl.value;
        final color = _modeColor(kw);
        final coveragePct =
            ((solar / kw).clamp(0.0, 1.0) * 100).toStringAsFixed(0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large live kW readout
            Text(
              kw.toStringAsFixed(2),
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
            Text(
              'kW  current draw',
              style: TextStyle(
                color: color.withValues(alpha: 0.60),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            _StatRow(
              icon: Icons.wb_sunny_rounded,
              label: 'Solar coverage',
              value: '$coveragePct%',
              color: _kSolar,
            ),
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.electric_meter,
              label: 'Grid import',
              value: '${grid.toStringAsFixed(1)} kW',
              color: _kGrid,
            ),
            const SizedBox(height: 12),
            // Zone pills — active one highlighted
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _ZonePill('ECO', _kEco, active: kw < cfg.ecoThreshold),
                _ZonePill('NORMAL', _kNormal,
                    active: kw >= cfg.ecoThreshold && kw < cfg.peakThreshold),
                _ZonePill('PEAK', _kPeak, active: kw >= cfg.peakThreshold),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenerationSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('GENERATION & STORAGE'),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Solar: child (icon + live kW) ─────────────────────────
                Expanded(
                  child: _ArcPanel(
                    title: 'SOLAR',
                    subtitle: 'Generation',
                    ctrl: _solarCtrl,
                    max: cfg.solarMax,
                    color: _kSolar,
                    trackWidth: cfg.gaugeTrackWidth,
                    glowRadius: cfg.gaugeGlowRadius,
                    child: ListenableBuilder(
                      listenable: _solarCtrl,
                      builder: (_, __) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wb_sunny_rounded,
                              color: _kSolar, size: 20),
                          const SizedBox(height: 2),
                          Text(
                            _solarCtrl.value.toStringAsFixed(1),
                            style: const TextStyle(
                              color: _kSolar,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('kW',
                              style: TextStyle(color: _kDim, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(color: _kBorder, width: 17),
                // ── Battery: showValue + widgetIndicator ──────────────────
                Expanded(
                  child: _ArcPanel(
                    title: 'BATTERY',
                    subtitle: 'State of Charge',
                    ctrl: _batteryCtrl,
                    max: 100,
                    unitText: '%',
                    color: _kBattery,
                    trackWidth: cfg.gaugeTrackWidth,
                    glowRadius: cfg.gaugeGlowRadius,
                    fillColor: const Color(0xFF0B1F0F),
                    showValue: true,
                    widgetIndicator: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _kBattery,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kBattery.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(color: _kBorder, width: 17),
                // ── Grid: reverse + child (live kW in centre) ────────────
                Expanded(
                  child: _ArcPanel(
                    title: 'GRID',
                    subtitle: 'Import',
                    ctrl: _gridCtrl,
                    max: cfg.gridMax,
                    color: _kGrid,
                    trackWidth: cfg.gaugeTrackWidth,
                    glowRadius: cfg.gaugeGlowRadius,
                    reverse: true,
                    child: ListenableBuilder(
                      listenable: _gridCtrl,
                      builder: (_, __) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.electric_meter,
                              color: _kGrid, size: 18),
                          const SizedBox(height: 2),
                          Text(
                            _gridCtrl.value.toStringAsFixed(1),
                            style: const TextStyle(
                              color: _kGrid,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('kW',
                              style: TextStyle(color: _kDim, fontSize: 9)),
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
    );
  }

  Widget _buildRoomSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _SectionLabel("TODAY'S ROOMS"),
              const Spacer(),
              // Total kWh across all rooms vs. total budget
              ListenableBuilder(
                listenable: Listenable.merge([
                  _livingCtrl,
                  _bedroomCtrl,
                  _kitchenCtrl,
                  _garageCtrl,
                ]),
                builder: (_, __) {
                  final total = _livingCtrl.value +
                      _bedroomCtrl.value +
                      _kitchenCtrl.value +
                      _garageCtrl.value;
                  final budget = cfg.roomBudgetKwh * 4;
                  return Text(
                    '${total.toStringAsFixed(1)} / ${budget.toStringAsFixed(0)} kWh',
                    style: const TextStyle(color: _kDim, fontSize: 10),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Budget: ${cfg.roomBudgetKwh.toStringAsFixed(0)} kWh / room / day',
            style: const TextStyle(color: _kDim, fontSize: 10),
          ),
          const SizedBox(height: 14),
          // ── Living Room: widgetIndicator (glowing dot at bar tip) ────────
          _RoomRow(
            icon: Icons.weekend,
            label: 'Living Room',
            ctrl: _livingCtrl,
            color: _kLiving,
            config: cfg,
            widgetIndicator: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _kLiving,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _kLiving.withValues(alpha: 0.6), blurRadius: 6),
                ],
              ),
            ),
          ),
          Divider(height: 18, color: _kBorder.withValues(alpha: 0.5)),
          // ── Bedroom: trailing icon ────────────────────────────────────────
          _RoomRow(
            icon: Icons.bed,
            label: 'Bedroom',
            ctrl: _bedroomCtrl,
            color: _kBedroom,
            config: cfg,
            trailing:
                const Icon(Icons.nightlight_round, color: _kDim, size: 14),
          ),
          Divider(height: 18, color: _kBorder.withValues(alpha: 0.5)),
          // ── Kitchen: center overlay warning text ─────────────────────────
          _RoomRow(
            icon: Icons.kitchen,
            label: 'Kitchen',
            ctrl: _kitchenCtrl,
            color: _kKitchen,
            config: cfg,
            center: ListenableBuilder(
              listenable: _kitchenCtrl,
              builder: (_, __) =>
                  _kitchenCtrl.value >= cfg.roomBudgetKwh * cfg.warningFraction
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
          Divider(height: 18, color: _kBorder.withValues(alpha: 0.5)),
          // ── Garage / EV: showValue + unitText ────────────────────────────
          _RoomRow(
            icon: Icons.electric_car,
            label: 'Garage / EV',
            ctrl: _garageCtrl,
            color: _kGarage,
            config: cfg,
            showValue: true,
          ),
        ],
      ),
    );
  }
}

// ── Configurable component widgets ────────────────────────────────────────────

/// Titled ArcGauge panel for the Generation & Storage section.
/// All gauge parameters (child, widgetIndicator, reverse, fillColor, showValue)
/// are forwarded so callers can use the full ArcGauge API.
class _ArcPanel extends StatelessWidget {
  const _ArcPanel({
    required this.title,
    required this.subtitle,
    required this.ctrl,
    required this.max,
    required this.color,
    required this.trackWidth,
    required this.glowRadius,
    this.unitText,
    this.fillColor,
    this.child,
    this.widgetIndicator,
    this.reverse = false,
    this.showValue = false,
  });

  final String title;
  final String subtitle;
  final GaugeController ctrl;
  final double max;
  final String? unitText;
  final Color color;
  final double trackWidth;
  final double glowRadius;
  final Color? fillColor;
  final Widget? child;
  final Widget? widgetIndicator;
  final bool reverse;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _kText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: _kDim, fontSize: 9),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 160,
            child: ArcGauge(
              controller: ctrl,
              min: 0,
              max: max,
              showValue: showValue,
              unitText: unitText,
              fillColor: fillColor,
              reverse: reverse,
              style: _GlowStyle(
                color: color,
                trackWidth: trackWidth,
                glowRadius: glowRadius,
              ),
              widgetIndicator: widgetIndicator,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single room-usage row: label + live value/percentage + LinearGauge.
/// All visual knobs come from [SmartHomeConfig] — no magic constants.
/// Supports the full LinearGauge overlay API: [trailing], [widgetIndicator],
/// [center], [showValue].
class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.icon,
    required this.label,
    required this.ctrl,
    required this.color,
    required this.config,
    this.trailing,
    this.widgetIndicator,
    this.center,
    this.showValue = false,
  });

  final IconData icon;
  final String label;
  final GaugeController ctrl;
  final Color color;
  final SmartHomeConfig config;
  final Widget? trailing;
  final Widget? widgetIndicator;
  final Widget? center;
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
            Text(
              label,
              style: const TextStyle(
                color: _kText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: ctrl,
              builder: (_, __) {
                final frac = ctrl.value / config.roomBudgetKwh;
                final pct = (frac * 100).round();
                final isHigh = frac >= config.warningFraction;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isHigh) ...[
                      const Icon(Icons.warning_amber_rounded,
                          color: _kWarning, size: 12),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      '${ctrl.value.toStringAsFixed(1)} kWh',
                      style: TextStyle(
                        color: isHigh ? _kWarning : color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$pct%',
                      style: const TextStyle(color: _kDim, fontSize: 10),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: config.barHeight,
          child: LinearGauge(
            controller: ctrl,
            min: 0,
            max: config.roomBudgetKwh,
            showLabels: false,
            showTicks: false,
            barRadius: config.barRadius,
            showValue: showValue,
            unitText: showValue ? 'kWh' : null,
            trailing: trailing,
            widgetIndicator: widgetIndicator,
            center: center,
            ranges: [
              GaugeRange(
                min: config.roomBudgetKwh * config.warningFraction,
                max: config.roomBudgetKwh,
                color: _kWarning.withValues(alpha: 0.35),
              ),
            ],
            style: _GlowStyle(
              color: color,
              trackWidth: config.barHeight - 2,
              glowRadius: 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Style & primitive helpers ─────────────────────────────────────────────────

class _GlowStyle extends GaugeStyle {
  const _GlowStyle({
    required this.color,
    this.glowRadius = 8.0,
    this.trackWidth = 10.0,
  });
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
      majorTick: const GaugeTickStyle(
          color: Color(0xFF444D56), strokeWidth: 1.5, length: 10),
      minorTick: const GaugeTickStyle(
          color: Color(0xFF2D333B), strokeWidth: 1.0, length: 5),
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
        color: _kText,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 11),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: _kDim, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _kDim, fontSize: 11)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ZonePill extends StatelessWidget {
  const _ZonePill(this.label, this.color, {required this.active});
  final String label;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(
            color: active ? color.withValues(alpha: 0.45) : _kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? color : _kDim,
          fontSize: 9,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          letterSpacing: 0.5,
        ),
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
          letterSpacing: 0.8),
    );
  }
}
