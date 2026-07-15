import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';
import 'package:gauge_kit/gauge_kit_dashboard_kit.dart';

/// Recreates the "smart car booking dashboard" genre popular on Dribbble —
/// using only the high-level Dashboard Kit widgets (`StatCardGrid`,
/// `GaugeListTile`, `DashboardCard`, and the eight stat-card presets). No
/// low-level `GaugeStyle`/`GaugeTokens` code appears in this file; every
/// visual is produced by the abstraction layer shipped in
/// `gauge_kit_dashboard_kit.dart`.
///
/// A picker under the header switches between four *structurally* distinct
/// compositions — not just a recolor of the same grid:
///
/// - **Bento Grid** — hero ring + a responsive card grid (`StatCardGrid`).
/// - **Grouped List** — a compact hero banner atop one grouped list of
///   `GaugeListTile` rows, the settings-screen reading pattern instead of
///   tiles.
/// - **Carousel Cluster** — an oversized centred hero dial with a
///   horizontally swipeable strip of secondary cards beneath it.
/// - **Split Console** — a wide dual-pane layout (hero left, scrollable
///   stat list right), the shape of an actual in-car centre console rather
///   than a phone screen.
class SmartCarDashboardKitScreen extends StatefulWidget {
  const SmartCarDashboardKitScreen({super.key});

  @override
  State<SmartCarDashboardKitScreen> createState() =>
      _SmartCarDashboardKitScreenState();
}

class _SmartCarDashboardKitScreenState
    extends State<SmartCarDashboardKitScreen> {
  final _speedCtrl = GaugeController(initialValue: 0);
  final _batteryCtrl = GaugeController(initialValue: 78);
  final _rangeCtrl = GaugeController(initialValue: 372);
  final _ecoCtrl = GaugeController(initialValue: 84);
  final _climateCtrl = GaugeController(initialValue: 21.5);
  final _tireCtrl = GaugeController(initialValue: 33);
  final _fuelCtrl = GaugeController(initialValue: 62);
  final _tripCtrl = GaugeController(initialValue: 4.2);

  Timer? _timer;
  double _phase = 0;
  double _battery = 78;
  double _trip = 4.2;
  bool _tripStarted = false;
  int _variantIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      _phase += 0.15;
      final speed = _tripStarted
          ? (58 + 42 * sin(_phase) + 8 * sin(_phase * 2.1)).clamp(0.0, 240.0)
          : 0.0;
      _speedCtrl.value = speed;

      if (_tripStarted) {
        _battery -= 0.03;
        if (_battery < 20) _battery = 20;
        _batteryCtrl.value = _battery;
        _rangeCtrl.value = _battery * 4.77;

        _trip += speed / 3600 * 0.4;
        _tripCtrl.value = _trip;
      }

      _climateCtrl.value = 21.5 + 0.6 * sin(_phase * 0.4);
      _tireCtrl.value = 33 + 0.8 * sin(_phase * 0.25);
      _fuelCtrl.value =
          (62.0 - (_tripStarted ? _trip * 0.3 : 0.0)).clamp(0.0, 100.0);
      _ecoCtrl.value = (84 + 6 * sin(_phase * 0.2)).clamp(0.0, 100.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speedCtrl.dispose();
    _batteryCtrl.dispose();
    _rangeCtrl.dispose();
    _ecoCtrl.dispose();
    _climateCtrl.dispose();
    _tireCtrl.dispose();
    _fuelCtrl.dispose();
    _tripCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final variant = _variants[_variantIndex];
    final palette = variant.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(tripStarted: _tripStarted, palette: palette),
            _VariantPicker(
              selectedIndex: _variantIndex,
              onSelected: (i) => setState(() => _variantIndex = i),
            ),
            Expanded(
              child: variant.builder(_DashboardData(
                speedCtrl: _speedCtrl,
                batteryCtrl: _batteryCtrl,
                rangeCtrl: _rangeCtrl,
                ecoCtrl: _ecoCtrl,
                climateCtrl: _climateCtrl,
                tireCtrl: _tireCtrl,
                fuelCtrl: _fuelCtrl,
                tripCtrl: _tripCtrl,
                palette: palette,
                tripStarted: _tripStarted,
                onToggleTrip: () =>
                    setState(() => _tripStarted = !_tripStarted),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

/// Colour palette shared by a single design variant.
class _Palette {
  const _Palette({
    required this.background,
    required this.cardStyle,
    required this.headerAccent,
    required this.titleColor,
    required this.subtitleColor,
    required this.okColor,
    required this.warnColor,
    required this.dangerColor,
    required this.ctaColor,
    required this.ctaOnColor,
    required this.speedColor,
    required this.batteryColor,
    required this.rangeColor,
    required this.ecoColor,
    required this.climateColor,
    required this.tireColor,
    required this.fuelColor,
    required this.tripColor,
  });

  final Color background;
  final DashboardCardStyle cardStyle;
  final Color headerAccent;
  final Color titleColor;
  final Color subtitleColor;
  final Color okColor;
  final Color warnColor;
  final Color dangerColor;
  final Color ctaColor;
  final Color ctaOnColor;
  final Color speedColor;
  final Color batteryColor;
  final Color rangeColor;
  final Color ecoColor;
  final Color climateColor;
  final Color tireColor;
  final Color fuelColor;
  final Color tripColor;
}

const _midnight = _Palette(
  background: Color(0xFF07080C),
  cardStyle: DashboardCardStyle.dark(),
  headerAccent: Color(0xFF4F8CFF),
  titleColor: Colors.white,
  subtitleColor: Color(0xFF8A8F98),
  okColor: Color(0xFF4ADE80),
  warnColor: Color(0xFFFBBF24),
  dangerColor: Color(0xFFEF4444),
  ctaColor: Color(0xFF4F8CFF),
  ctaOnColor: Colors.white,
  speedColor: Color(0xFF4F8CFF),
  batteryColor: Color(0xFF34D399),
  rangeColor: Color(0xFFA78BFA),
  ecoColor: Color(0xFF4ADE80),
  climateColor: Color(0xFF38BDF8),
  tireColor: Color(0xFFFBBF24),
  fuelColor: Color(0xFFFB7185),
  tripColor: Color(0xFFA3E635),
);

final _luxuryGold = _Palette(
  background: const Color(0xFF0C0A08),
  cardStyle: const DashboardCardStyle(
    backgroundColor: Color(0xFF1A140D),
    borderColor: Color(0x33D4AF37),
    labelStyle: TextStyle(
      color: Color(0xFFB8A177),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
    ),
    valueStyle: TextStyle(
      color: Color(0xFFF5E9D3),
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
    unitStyle: TextStyle(
      color: Color(0xFFB8A177),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    glowOpacity: 0.4,
  ),
  headerAccent: const Color(0xFFD4AF37),
  titleColor: const Color(0xFFF5E9D3),
  subtitleColor: const Color(0xFFB8A177),
  okColor: const Color(0xFFD4AF37),
  warnColor: const Color(0xFFE8B355),
  dangerColor: const Color(0xFFE2574C),
  ctaColor: const Color(0xFFD4AF37),
  ctaOnColor: const Color(0xFF1A140D),
  speedColor: const Color(0xFFD4AF37),
  batteryColor: const Color(0xFFC9A66B),
  rangeColor: const Color(0xFFE0C68A),
  ecoColor: const Color(0xFFC9D6A3),
  climateColor: const Color(0xFFE3B8A0),
  tireColor: const Color(0xFFD9A441),
  fuelColor: const Color(0xFFD97757),
  tripColor: const Color(0xFFB9C48B),
);

final _neonAurora = _Palette(
  background: const Color(0xFF07030F),
  cardStyle: const DashboardCardStyle(
    backgroundColor: Color(0xFF120B24),
    borderColor: Color(0x40FF2E9A),
    labelStyle: TextStyle(
      color: Color(0xFF9C8FC9),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
    valueStyle: TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
    unitStyle: TextStyle(
      color: Color(0xFF9C8FC9),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    glowOpacity: 0.55,
  ),
  headerAccent: const Color(0xFF00F5FF),
  titleColor: Colors.white,
  subtitleColor: const Color(0xFF9C8FC9),
  okColor: const Color(0xFF39FF88),
  warnColor: const Color(0xFFFFD23F),
  dangerColor: const Color(0xFFFF2E63),
  ctaColor: const Color(0xFFFF2E9A),
  ctaOnColor: Colors.white,
  speedColor: const Color(0xFF00F5FF),
  batteryColor: const Color(0xFF39FF88),
  rangeColor: const Color(0xFFB388FF),
  ecoColor: const Color(0xFFC6FF3D),
  climateColor: const Color(0xFF4DD8FF),
  tireColor: const Color(0xFFFFC93D),
  fuelColor: const Color(0xFFFF2E9A),
  tripColor: const Color(0xFF9D4EFF),
);

final _daylight = _Palette(
  background: const Color(0xFFF3F4F7),
  // The whole light-card chrome — background, border, slate text, subtle
  // glow, and the dark-tuned track colour — in one named constructor.
  cardStyle: const DashboardCardStyle.light(),
  headerAccent: const Color(0xFF2563EB),
  titleColor: const Color(0xFF0F172A),
  subtitleColor: const Color(0xFF64748B),
  okColor: const Color(0xFF16A34A),
  warnColor: const Color(0xFFD97706),
  dangerColor: const Color(0xFFDC2626),
  ctaColor: const Color(0xFF2563EB),
  ctaOnColor: Colors.white,
  speedColor: const Color(0xFF2563EB),
  batteryColor: const Color(0xFF16A34A),
  rangeColor: const Color(0xFF7C3AED),
  ecoColor: const Color(0xFF059669),
  climateColor: const Color(0xFF0891B2),
  tireColor: const Color(0xFFD97706),
  fuelColor: const Color(0xFFE11D48),
  tripColor: const Color(0xFF65A30D),
);

/// Everything a variant layout needs to build itself.
class _DashboardData {
  const _DashboardData({
    required this.speedCtrl,
    required this.batteryCtrl,
    required this.rangeCtrl,
    required this.ecoCtrl,
    required this.climateCtrl,
    required this.tireCtrl,
    required this.fuelCtrl,
    required this.tripCtrl,
    required this.palette,
    required this.tripStarted,
    required this.onToggleTrip,
  });

  final GaugeController speedCtrl;
  final GaugeController batteryCtrl;
  final GaugeController rangeCtrl;
  final GaugeController ecoCtrl;
  final GaugeController climateCtrl;
  final GaugeController tireCtrl;
  final GaugeController fuelCtrl;
  final GaugeController tripCtrl;
  final _Palette palette;
  final bool tripStarted;
  final VoidCallback onToggleTrip;
}

class _Variant {
  const _Variant({
    required this.name,
    required this.palette,
    required this.builder,
  });

  final String name;
  final _Palette palette;
  final Widget Function(_DashboardData data) builder;
}

final _variants = <_Variant>[
  _Variant(name: 'Bento Grid', palette: _midnight, builder: _bentoGrid),
  _Variant(name: 'List', palette: _luxuryGold, builder: _groupedList),
  _Variant(name: 'Carousel', palette: _neonAurora, builder: _carouselCluster),
  _Variant(name: 'Split Console', palette: _daylight, builder: _splitConsole),
];

// ── Variant 1 — Bento Grid: hero ring + responsive card grid ───────────────
Widget _bentoGrid(_DashboardData d) {
  final p = d.palette;
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: StatCardGrid(
            hero: SpeedStatCard(
              controller: d.speedCtrl,
              max: 240,
              accentColor: p.speedColor,
              cardStyle: p.cardStyle,
            ),
            children: [
              BatteryStatCard(
                controller: d.batteryCtrl,
                accentColor: p.batteryColor,
                lowColor: p.warnColor,
                criticalColor: p.dangerColor,
                cardStyle: p.cardStyle,
              ),
              RangeStatCard(
                controller: d.rangeCtrl,
                maxRangeKm: 500,
                accentColor: p.rangeColor,
                cardStyle: p.cardStyle,
              ),
              EcoScoreStatCard(
                controller: d.ecoCtrl,
                accentColor: p.ecoColor,
                cardStyle: p.cardStyle,
              ),
              ClimateStatCard(
                controller: d.climateCtrl,
                accentColor: p.climateColor,
                cardStyle: p.cardStyle,
              ),
              TirePressureStatCard(
                controller: d.tireCtrl,
                accentColor: p.tireColor,
                criticalColor: p.dangerColor,
                cardStyle: p.cardStyle,
              ),
              FuelStatCard(
                controller: d.fuelCtrl,
                accentColor: p.fuelColor,
                lowColor: p.dangerColor,
                cardStyle: p.cardStyle,
              ),
              TripStatCard(
                controller: d.tripCtrl,
                targetKm: 50,
                accentColor: p.tripColor,
                cardStyle: p.cardStyle,
              ),
            ],
          ),
        ),
      ),
      _CtaBar(data: d, style: _CtaStyle.fullWidth),
    ],
  );
}

// ── Variant 2 — Grouped List: compact hero banner + one row-list card ──────
Widget _groupedList(_DashboardData d) {
  final p = d.palette;
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SpeedStatCard(
                controller: d.speedCtrl,
                max: 240,
                accentColor: p.speedColor,
                ringSize: 96,
                cardStyle: p.cardStyle,
              ),
              const SizedBox(height: 16),
              DashboardCard(
                style: p.cardStyle,
                showGlow: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GaugeListTile(
                      controller: d.batteryCtrl,
                      label: 'BATTERY',
                      icon: Icons.battery_charging_full_rounded,
                      accentColor: p.batteryColor,
                      unitText: '%',
                      cardStyle: p.cardStyle,
                    ),
                    Divider(height: 1, color: p.cardStyle.borderColor),
                    GaugeListTile(
                      controller: d.rangeCtrl,
                      label: 'RANGE',
                      icon: Icons.route_rounded,
                      accentColor: p.rangeColor,
                      unitText: 'km',
                      max: 500,
                      cardStyle: p.cardStyle,
                    ),
                    Divider(height: 1, color: p.cardStyle.borderColor),
                    GaugeListTile(
                      controller: d.ecoCtrl,
                      label: 'ECO SCORE',
                      icon: Icons.eco_rounded,
                      accentColor: p.ecoColor,
                      cardStyle: p.cardStyle,
                    ),
                    Divider(height: 1, color: p.cardStyle.borderColor),
                    GaugeListTile(
                      controller: d.climateCtrl,
                      label: 'CABIN TEMP',
                      icon: Icons.thermostat_rounded,
                      accentColor: p.climateColor,
                      unitText: '°C',
                      min: 16,
                      max: 30,
                      valueFormatter: (v) => v.toStringAsFixed(1),
                      cardStyle: p.cardStyle,
                    ),
                    Divider(height: 1, color: p.cardStyle.borderColor),
                    GaugeListTile(
                      controller: d.tireCtrl,
                      label: 'TYRE PRESSURE',
                      icon: Icons.tire_repair_rounded,
                      accentColor: p.tireColor,
                      unitText: 'PSI',
                      min: 20,
                      max: 40,
                      cardStyle: p.cardStyle,
                    ),
                    Divider(height: 1, color: p.cardStyle.borderColor),
                    GaugeListTile(
                      controller: d.fuelCtrl,
                      label: 'FUEL',
                      icon: Icons.local_gas_station_rounded,
                      accentColor: p.fuelColor,
                      unitText: '%',
                      cardStyle: p.cardStyle,
                    ),
                    Divider(height: 1, color: p.cardStyle.borderColor),
                    GaugeListTile(
                      controller: d.tripCtrl,
                      label: 'TRIP',
                      icon: Icons.route_rounded,
                      accentColor: p.tripColor,
                      unitText: 'km',
                      max: 50,
                      valueFormatter: (v) => v.toStringAsFixed(1),
                      cardStyle: p.cardStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      _CtaBar(data: d, style: _CtaStyle.fullWidth),
    ],
  );
}

// ── Variant 3 — Carousel Cluster: dominant hero + swipeable strip ──────────
Widget _carouselCluster(_DashboardData d) {
  final p = d.palette;
  return Column(
    children: [
      Expanded(
        child: Center(
          child: SpeedStatCard(
            controller: d.speedCtrl,
            max: 240,
            accentColor: p.speedColor,
            ringSize: 210,
            trackWidth: 14,
            cardStyle: p.cardStyle,
          ),
        ),
      ),
      SizedBox(
        height: 168,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(
              width: 150,
              child: BatteryStatCard(
                controller: d.batteryCtrl,
                accentColor: p.batteryColor,
                lowColor: p.warnColor,
                criticalColor: p.dangerColor,
                ringSize: 76,
                cardStyle: p.cardStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: RangeStatCard(
                controller: d.rangeCtrl,
                maxRangeKm: 500,
                accentColor: p.rangeColor,
                ringSize: 76,
                cardStyle: p.cardStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: EcoScoreStatCard(
                controller: d.ecoCtrl,
                accentColor: p.ecoColor,
                ringSize: 76,
                cardStyle: p.cardStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: ClimateStatCard(
                controller: d.climateCtrl,
                accentColor: p.climateColor,
                ringSize: 76,
                cardStyle: p.cardStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: TirePressureStatCard(
                controller: d.tireCtrl,
                accentColor: p.tireColor,
                criticalColor: p.dangerColor,
                cardStyle: p.cardStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: FuelStatCard(
                controller: d.fuelCtrl,
                accentColor: p.fuelColor,
                lowColor: p.dangerColor,
                cardStyle: p.cardStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: TripStatCard(
                controller: d.tripCtrl,
                targetKm: 50,
                accentColor: p.tripColor,
                cardStyle: p.cardStyle,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      _CtaBar(data: d, style: _CtaStyle.fullWidth),
    ],
  );
}

// ── Variant 4 — Split Console: wide dual-pane, hero left / list right ──────
Widget _splitConsole(_DashboardData d) {
  final p = d.palette;
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      child: SpeedStatCard(
                        controller: d.speedCtrl,
                        max: 240,
                        accentColor: p.speedColor,
                        ringSize: 128,
                        cardStyle: p.cardStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CtaBar(data: d, style: _CtaStyle.compact),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: DashboardCard(
                    style: p.cardStyle,
                    showGlow: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GaugeListTile(
                          controller: d.batteryCtrl,
                          label: 'BATTERY',
                          icon: Icons.battery_charging_full_rounded,
                          accentColor: p.batteryColor,
                          unitText: '%',
                          cardStyle: p.cardStyle,
                          trailingIndicatorWidth: 40,
                        ),
                        Divider(height: 1, color: p.cardStyle.borderColor),
                        GaugeListTile(
                          controller: d.rangeCtrl,
                          label: 'RANGE',
                          icon: Icons.route_rounded,
                          accentColor: p.rangeColor,
                          unitText: 'km',
                          max: 500,
                          cardStyle: p.cardStyle,
                          trailingIndicatorWidth: 40,
                        ),
                        Divider(height: 1, color: p.cardStyle.borderColor),
                        GaugeListTile(
                          controller: d.climateCtrl,
                          label: 'CABIN TEMP',
                          icon: Icons.thermostat_rounded,
                          accentColor: p.climateColor,
                          unitText: '°C',
                          min: 16,
                          max: 30,
                          valueFormatter: (v) => v.toStringAsFixed(1),
                          cardStyle: p.cardStyle,
                          trailingIndicatorWidth: 40,
                        ),
                        Divider(height: 1, color: p.cardStyle.borderColor),
                        GaugeListTile(
                          controller: d.tireCtrl,
                          label: 'TYRE PRESSURE',
                          icon: Icons.tire_repair_rounded,
                          accentColor: p.tireColor,
                          unitText: 'PSI',
                          min: 20,
                          max: 40,
                          cardStyle: p.cardStyle,
                          trailingIndicatorWidth: 40,
                        ),
                        Divider(height: 1, color: p.cardStyle.borderColor),
                        GaugeListTile(
                          controller: d.fuelCtrl,
                          label: 'FUEL',
                          icon: Icons.local_gas_station_rounded,
                          accentColor: p.fuelColor,
                          unitText: '%',
                          cardStyle: p.cardStyle,
                          trailingIndicatorWidth: 40,
                        ),
                        Divider(height: 1, color: p.cardStyle.borderColor),
                        GaugeListTile(
                          controller: d.ecoCtrl,
                          label: 'ECO SCORE',
                          icon: Icons.eco_rounded,
                          accentColor: p.ecoColor,
                          cardStyle: p.cardStyle,
                          trailingIndicatorWidth: 40,
                        ),
                        Divider(height: 1, color: p.cardStyle.borderColor),
                        GaugeListTile(
                          controller: d.tripCtrl,
                          label: 'TRIP',
                          icon: Icons.route_rounded,
                          accentColor: p.tripColor,
                          unitText: 'km',
                          max: 50,
                          valueFormatter: (v) => v.toStringAsFixed(1),
                          cardStyle: p.cardStyle,
                          trailingIndicatorWidth: 40,
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
  );
}

enum _CtaStyle { fullWidth, compact }

class _CtaBar extends StatelessWidget {
  const _CtaBar({required this.data, required this.style});

  final _DashboardData data;
  final _CtaStyle style;

  @override
  Widget build(BuildContext context) {
    final p = data.palette;
    final button = ElevatedButton(
      onPressed: data.onToggleTrip,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            data.tripStarted ? p.cardStyle.backgroundColor : p.ctaColor,
        foregroundColor: data.tripStarted ? p.subtitleColor : p.ctaOnColor,
        side: data.tripStarted
            ? BorderSide(color: p.cardStyle.borderColor)
            : BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data.tripStarted
                ? Icons.stop_circle_rounded
                : Icons.play_circle_fill_rounded,
            size: style == _CtaStyle.compact ? 18 : 24,
          ),
          const SizedBox(width: 8),
          Text(
            data.tripStarted ? 'End Trip' : 'Start Trip',
            style: TextStyle(
              fontSize: style == _CtaStyle.compact ? 13 : 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (style == _CtaStyle.compact) {
      return SizedBox(height: 40, width: double.infinity, child: button);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(height: 54, width: double.infinity, child: button),
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _variants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final variant = _variants[i];
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? variant.palette.headerAccent.withValues(alpha: 0.18)
                    : variant.palette.cardStyle.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? variant.palette.headerAccent
                      : variant.palette.cardStyle.borderColor,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                variant.name,
                style: TextStyle(
                  color: selected
                      ? variant.palette.headerAccent
                      : variant.palette.subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tripStarted, required this.palette});

  final bool tripStarted;
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    final statusColor = tripStarted ? palette.okColor : palette.subtitleColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.headerAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_car_filled_rounded,
                color: palette.headerAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aurora GT · Model 3',
                  style: TextStyle(
                    color: palette.titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Downtown Garage · Bay 12',
                  style: TextStyle(
                    color: palette.subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  tripStarted ? 'ON TRIP' : 'PARKED',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
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
