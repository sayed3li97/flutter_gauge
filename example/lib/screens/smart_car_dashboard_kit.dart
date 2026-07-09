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
    return Scaffold(
      backgroundColor: const Color(0xFF07080C),
      body: SafeArea(
        child: Column(
          children: [
            _Header(tripStarted: _tripStarted),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: StatCardGrid(
                  hero: SpeedStatCard(controller: _speedCtrl, max: 240),
                  children: [
                    BatteryStatCard(controller: _batteryCtrl),
                    RangeStatCard(controller: _rangeCtrl, maxRangeKm: 500),
                    EcoScoreStatCard(controller: _ecoCtrl),
                    ClimateStatCard(controller: _climateCtrl),
                    TirePressureStatCard(controller: _tireCtrl),
                    FuelStatCard(controller: _fuelCtrl),
                    TripStatCard(controller: _tripCtrl, targetKm: 50),
                  ],
                ),
              ),
            ),
            _TripActionBar(
              tripStarted: _tripStarted,
              onToggle: () => setState(() => _tripStarted = !_tripStarted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tripStarted});

  final bool tripStarted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4F8CFF).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car_filled_rounded,
                color: Color(0xFF4F8CFF), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aurora GT · Model 3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Downtown Garage · Bay 12',
                  style: TextStyle(
                    color: Color(0xFF8A8F98),
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
              color: (tripStarted ? const Color(0xFF4ADE80) : Colors.white)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (tripStarted ? const Color(0xFF4ADE80) : Colors.white)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: tripStarted
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF8A8F98),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tripStarted ? 'ON TRIP' : 'PARKED',
                  style: TextStyle(
                    color: tripStarted
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF8A8F98),
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
  const _TripActionBar({required this.tripStarted, required this.onToggle});

  final bool tripStarted;
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
                tripStarted ? const Color(0xFF1A1D26) : const Color(0xFF4F8CFF),
            foregroundColor: Colors.white,
            side: tripStarted
                ? const BorderSide(color: Color(0x1FFFFFFF))
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
