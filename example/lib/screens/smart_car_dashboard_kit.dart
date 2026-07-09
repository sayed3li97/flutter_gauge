import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';
import 'package:gauge_kit/gauge_kit_dashboard_kit.dart';

/// Recreates the "smart car booking dashboard" genre popular on Dribbble —
/// a dark bento grid of glassmorphic gradient-ring stat cards — using only
/// the high-level Dashboard Kit widgets (`StatCardGrid` + presets). No
/// low-level `GaugeStyle`/`GaugeTokens` code appears in this file; every
/// visual is produced by the abstraction layer shipped in
/// `gauge_kit_dashboard_kit.dart`.
///
/// Four switchable [_KitStyle] presets — reachable via the chip row under
/// the header — prove the same eight stat-card widgets can be reskinned
/// entirely through [DashboardCardStyle] and `accentColor`/`lowColor`/
/// `criticalColor` params, with no engine-level code involved.
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
  int _styleIndex = 0;

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
    final style = _kitStyles[_styleIndex];

    return Scaffold(
      backgroundColor: style.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(tripStarted: _tripStarted, style: style),
            _StylePicker(
              selectedIndex: _styleIndex,
              onSelected: (i) => setState(() => _styleIndex = i),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: StatCardGrid(
                  hero: SpeedStatCard(
                    controller: _speedCtrl,
                    max: 240,
                    accentColor: style.speedColor,
                    cardStyle: style.cardStyle,
                  ),
                  children: [
                    BatteryStatCard(
                      controller: _batteryCtrl,
                      accentColor: style.batteryColor,
                      lowColor: style.warnColor,
                      criticalColor: style.dangerColor,
                      cardStyle: style.cardStyle,
                    ),
                    RangeStatCard(
                      controller: _rangeCtrl,
                      maxRangeKm: 500,
                      accentColor: style.rangeColor,
                      cardStyle: style.cardStyle,
                    ),
                    EcoScoreStatCard(
                      controller: _ecoCtrl,
                      accentColor: style.ecoColor,
                      cardStyle: style.cardStyle,
                    ),
                    ClimateStatCard(
                      controller: _climateCtrl,
                      accentColor: style.climateColor,
                      cardStyle: style.cardStyle,
                    ),
                    TirePressureStatCard(
                      controller: _tireCtrl,
                      accentColor: style.tireColor,
                      criticalColor: style.dangerColor,
                      cardStyle: style.cardStyle,
                    ),
                    FuelStatCard(
                      controller: _fuelCtrl,
                      accentColor: style.fuelColor,
                      lowColor: style.dangerColor,
                      cardStyle: style.cardStyle,
                    ),
                    TripStatCard(
                      controller: _tripCtrl,
                      targetKm: 50,
                      accentColor: style.tripColor,
                      cardStyle: style.cardStyle,
                    ),
                  ],
                ),
              ),
            ),
            _TripActionBar(
              tripStarted: _tripStarted,
              style: style,
              onToggle: () => setState(() => _tripStarted = !_tripStarted),
            ),
          ],
        ),
      ),
    );
  }
}

/// One switchable visual theme for the dashboard — everything here is a
/// plain configuration value fed into stock Dashboard Kit widgets, not a
/// new rendering path.
class _KitStyle {
  const _KitStyle({
    required this.name,
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

  final String name;
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

final _kitStyles = <_KitStyle>[
  // Midnight — the library's own defaults; every card below omits
  // `accentColor`/`cardStyle` in spirit (values just mirror the presets'
  // built-in defaults so the picker has something to switch away from).
  const _KitStyle(
    name: 'Midnight',
    background: Color(0xFF07080C),
    cardStyle: DashboardCardStyle(),
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
  ),

  // Luxury Gold — the black-and-gold palette of the reference "Luxury Car
  // Booking Dashboard" Dribbble genre: warm near-black cards, a gold hero
  // ring, and a cohesive champagne/bronze accent family.
  _KitStyle(
    name: 'Luxury Gold',
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
  ),

  // Neon Aurora — a cyberpunk take: near-black violet background, bright
  // saturated accents, and a much stronger card glow than the other three.
  _KitStyle(
    name: 'Neon Aurora',
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
  ),

  // Daylight — a light-cabin variant for a sun-visor display or a
  // rental-booking screen rather than a night drive; proves the kit isn't
  // dark-theme-only.
  _KitStyle(
    name: 'Daylight',
    background: const Color(0xFFF3F4F7),
    cardStyle: const DashboardCardStyle(
      backgroundColor: Colors.white,
      borderColor: Color(0x14000000),
      labelStyle: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
      valueStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.0,
      ),
      unitStyle: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      glowOpacity: 0.12,
    ),
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
  ),
];

class _StylePicker extends StatelessWidget {
  const _StylePicker({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _kitStyles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final style = _kitStyles[i];
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? style.headerAccent.withValues(alpha: 0.18)
                    : style.cardStyle.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? style.headerAccent
                      : style.cardStyle.borderColor,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                style.name,
                style: TextStyle(
                  color: selected ? style.headerAccent : style.subtitleColor,
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
  const _Header({required this.tripStarted, required this.style});

  final bool tripStarted;
  final _KitStyle style;

  @override
  Widget build(BuildContext context) {
    final statusColor = tripStarted ? style.okColor : style.subtitleColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.headerAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_car_filled_rounded,
                color: style.headerAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aurora GT · Model 3',
                  style: TextStyle(
                    color: style.titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Downtown Garage · Bay 12',
                  style: TextStyle(
                    color: style.subtitleColor,
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

class _TripActionBar extends StatelessWidget {
  const _TripActionBar({
    required this.tripStarted,
    required this.style,
    required this.onToggle,
  });

  final bool tripStarted;
  final _KitStyle style;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                tripStarted ? style.cardStyle.backgroundColor : style.ctaColor,
            foregroundColor:
                tripStarted ? style.subtitleColor : style.ctaOnColor,
            side: tripStarted
                ? BorderSide(color: style.cardStyle.borderColor)
                : BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tripStarted
                  ? Icons.stop_circle_rounded
                  : Icons.play_circle_fill_rounded),
              const SizedBox(width: 8),
              Text(
                tripStarted ? 'End Trip' : 'Start Trip',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
