import 'package:flutter/material.dart';

import '../../core/gauge_controller.dart';
import '../../core/gauge_mode.dart';
import 'dashboard_card_style.dart';
import 'gauge_bar_card.dart';
import 'gauge_ring_card.dart';

/// Pre-styled speed card — a large ring gauge with the current speed
/// centred inside it. Typically used as the hero card in a
/// [StatCardGrid].
///
/// ```dart
/// SpeedStatCard(controller: speedCtrl, max: 240)
/// ```
class SpeedStatCard extends StatelessWidget {
  const SpeedStatCard({
    super.key,
    required this.controller,
    this.max = 240,
    this.unitText = 'km/h',
    this.label = 'SPEED',
    this.accentColor = const Color(0xFF4F8CFF),
    this.ringSize = 140,
    this.trackWidth = 10,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the ring fill and the centred numeral.
  final GaugeController controller;

  /// Maximum speed on the scale.
  final double max;

  /// Unit suffix appended to the centred numeral.
  final String unitText;

  /// Small uppercase card label.
  final String label;

  /// Accent colour for the ring, glow, and icon badge.
  final Color accentColor;

  /// Diameter of the ring gauge in logical pixels.
  final double ringSize;

  /// Stroke width of the ring track and value arc. Scale this up alongside
  /// [ringSize] for an oversized hero dial.
  final double trackWidth;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeRingCard(
      controller: controller,
      label: label,
      icon: Icons.speed_rounded,
      accentColor: accentColor,
      min: 0,
      max: max,
      unitText: unitText,
      ringSize: ringSize,
      trackWidth: trackWidth,
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
    );
  }
}

/// Pre-styled battery card — ring gauge showing charge percentage, turning
/// [lowColor] then [criticalColor] as the charge drops below
/// [lowThreshold]/[criticalThreshold].
///
/// ```dart
/// BatteryStatCard(controller: batteryCtrl)
/// ```
class BatteryStatCard extends StatelessWidget {
  const BatteryStatCard({
    super.key,
    required this.controller,
    this.label = 'BATTERY',
    this.accentColor = const Color(0xFF34D399),
    this.lowColor = const Color(0xFFFBBF24),
    this.criticalColor = const Color(0xFFEF4444),
    this.lowThreshold = 30,
    this.criticalThreshold = 15,
    this.ringSize = 96,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the ring fill (0–100 %).
  final GaugeController controller;

  /// Small uppercase card label.
  final String label;

  /// Accent colour above [lowThreshold].
  final Color accentColor;

  /// Accent colour between [criticalThreshold] and [lowThreshold].
  final Color lowColor;

  /// Accent colour at or below [criticalThreshold].
  final Color criticalColor;

  /// Charge percentage below which [lowColor] is used.
  final double lowThreshold;

  /// Charge percentage below which [criticalColor] is used.
  final double criticalThreshold;

  /// Diameter of the ring gauge in logical pixels.
  final double ringSize;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeRingCard(
      controller: controller,
      label: label,
      icon: Icons.battery_charging_full_rounded,
      accentColor: accentColor,
      min: 0,
      max: 100,
      unitText: '%',
      ringSize: ringSize,
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
      colorForValue: (v) {
        if (v <= criticalThreshold) return criticalColor;
        if (v <= lowThreshold) return lowColor;
        return accentColor;
      },
    );
  }
}

/// Pre-styled driving-range card — ring gauge showing remaining range as a
/// fraction of [maxRangeKm], with the absolute kilometre figure centred.
///
/// ```dart
/// RangeStatCard(controller: rangeCtrl, maxRangeKm: 480)
/// ```
class RangeStatCard extends StatelessWidget {
  const RangeStatCard({
    super.key,
    required this.controller,
    this.maxRangeKm = 500,
    this.label = 'RANGE',
    this.accentColor = const Color(0xFFA78BFA),
    this.ringSize = 96,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the ring fill; the controller's value is the remaining range
  /// in kilometres.
  final GaugeController controller;

  /// Full-tank/full-charge range used as the gauge's maximum.
  final double maxRangeKm;

  /// Small uppercase card label.
  final String label;

  /// Accent colour for the ring, glow, and icon badge.
  final Color accentColor;

  /// Diameter of the ring gauge in logical pixels.
  final double ringSize;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeRingCard(
      controller: controller,
      label: label,
      icon: Icons.route_rounded,
      accentColor: accentColor,
      min: 0,
      max: maxRangeKm,
      unitText: 'km',
      ringSize: ringSize,
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
    );
  }
}

/// Pre-styled eco-driving score card — ring gauge, 0–100 score.
///
/// ```dart
/// EcoScoreStatCard(controller: ecoCtrl)
/// ```
class EcoScoreStatCard extends StatelessWidget {
  const EcoScoreStatCard({
    super.key,
    required this.controller,
    this.label = 'ECO SCORE',
    this.accentColor = const Color(0xFF4ADE80),
    this.ringSize = 96,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the ring fill (0–100 score).
  final GaugeController controller;

  /// Small uppercase card label.
  final String label;

  /// Accent colour for the ring, glow, and icon badge.
  final Color accentColor;

  /// Diameter of the ring gauge in logical pixels.
  final double ringSize;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeRingCard(
      controller: controller,
      label: label,
      icon: Icons.eco_rounded,
      accentColor: accentColor,
      min: 0,
      max: 100,
      ringSize: ringSize,
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
    );
  }
}

/// Pre-styled cabin-temperature card — ring gauge in °C.
///
/// ```dart
/// ClimateStatCard(controller: climateCtrl)
/// ```
class ClimateStatCard extends StatelessWidget {
  const ClimateStatCard({
    super.key,
    required this.controller,
    this.min = 16,
    this.max = 30,
    this.label = 'CABIN TEMP',
    this.accentColor = const Color(0xFF38BDF8),
    this.ringSize = 96,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the ring fill; the controller's value is the temperature in °C.
  final GaugeController controller;

  /// Minimum temperature on the scale.
  final double min;

  /// Maximum temperature on the scale.
  final double max;

  /// Small uppercase card label.
  final String label;

  /// Accent colour for the ring, glow, and icon badge.
  final Color accentColor;

  /// Diameter of the ring gauge in logical pixels.
  final double ringSize;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeRingCard(
      controller: controller,
      label: label,
      icon: Icons.thermostat_rounded,
      accentColor: accentColor,
      min: min,
      max: max,
      unitText: '°C',
      valueFormatter: (v) => v.toStringAsFixed(1),
      ringSize: ringSize,
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
    );
  }
}

/// Pre-styled tyre-pressure card — pill-shaped bar gauge in PSI, turning
/// [criticalColor] outside the [safeMin]–[safeMax] range.
///
/// ```dart
/// TirePressureStatCard(controller: tireCtrl)
/// ```
class TirePressureStatCard extends StatelessWidget {
  const TirePressureStatCard({
    super.key,
    required this.controller,
    this.min = 20,
    this.max = 40,
    this.safeMin = 30,
    this.safeMax = 36,
    this.label = 'TYRE PRESSURE',
    this.accentColor = const Color(0xFFFBBF24),
    this.criticalColor = const Color(0xFFEF4444),
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the bar fill; the controller's value is the pressure in PSI.
  final GaugeController controller;

  /// Minimum pressure on the scale.
  final double min;

  /// Maximum pressure on the scale.
  final double max;

  /// Lower bound of the safe pressure range.
  final double safeMin;

  /// Upper bound of the safe pressure range.
  final double safeMax;

  /// Small uppercase card label.
  final String label;

  /// Accent colour within the safe range.
  final Color accentColor;

  /// Accent colour outside the safe range.
  final Color criticalColor;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeBarCard(
      controller: controller,
      label: label,
      icon: Icons.tire_repair_rounded,
      accentColor: accentColor,
      min: min,
      max: max,
      unitText: 'PSI',
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
      colorForValue: (v) =>
          (v < safeMin || v > safeMax) ? criticalColor : accentColor,
    );
  }
}

/// Pre-styled fuel-level card — pill-shaped bar gauge, percentage, turning
/// [lowColor] below [lowThreshold].
///
/// ```dart
/// FuelStatCard(controller: fuelCtrl)
/// ```
class FuelStatCard extends StatelessWidget {
  const FuelStatCard({
    super.key,
    required this.controller,
    this.label = 'FUEL',
    this.accentColor = const Color(0xFFFB7185),
    this.lowColor = const Color(0xFFEF4444),
    this.lowThreshold = 15,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the bar fill (0–100 %).
  final GaugeController controller;

  /// Small uppercase card label.
  final String label;

  /// Accent colour above [lowThreshold].
  final Color accentColor;

  /// Accent colour at or below [lowThreshold].
  final Color lowColor;

  /// Fuel percentage below which [lowColor] is used.
  final double lowThreshold;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeBarCard(
      controller: controller,
      label: label,
      icon: Icons.local_gas_station_rounded,
      accentColor: accentColor,
      min: 0,
      max: 100,
      unitText: '%',
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
      colorForValue: (v) => v <= lowThreshold ? lowColor : accentColor,
    );
  }
}

/// Pre-styled trip-distance card — pill-shaped bar gauge showing progress
/// toward [targetKm].
///
/// ```dart
/// TripStatCard(controller: tripCtrl, targetKm: 50)
/// ```
class TripStatCard extends StatelessWidget {
  const TripStatCard({
    super.key,
    required this.controller,
    this.targetKm = 50,
    this.label = 'TRIP',
    this.accentColor = const Color(0xFFA3E635),
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.mode,
  });

  /// Drives the bar fill; the controller's value is the distance travelled
  /// in kilometres.
  final GaugeController controller;

  /// Target/full-trip distance used as the gauge's maximum.
  final double targetKm;

  /// Small uppercase card label.
  final String label;

  /// Accent colour for the bar, glow, and icon badge.
  final Color accentColor;

  /// Whether to cast an accent-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Ambient or instrument rendering mode.
  final GaugeMode? mode;

  @override
  Widget build(BuildContext context) {
    return GaugeBarCard(
      controller: controller,
      label: label,
      icon: Icons.route_rounded,
      accentColor: accentColor,
      min: 0,
      max: targetKm,
      unitText: 'km',
      valueFormatter: (v) => v.toStringAsFixed(1),
      showGlow: showGlow,
      cardStyle: cardStyle,
      mode: mode,
      semanticsLabel: label,
    );
  }
}
