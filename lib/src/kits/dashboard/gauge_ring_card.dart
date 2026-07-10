import 'package:flutter/material.dart';

import '../../core/gauge_controller.dart';
import '../../core/gauge_mode.dart';
import '../../styles/gauge_style.dart';
import '../../widgets/arc_gauge.dart';
import 'dashboard_card.dart';
import 'dashboard_card_style.dart';

/// A rounded "glass" card with a circular/arc progress ring and a large
/// numeral centred inside it.
///
/// The workhorse card of the dashboard kit — used for battery %, range,
/// eco score, cabin temperature, or any percentage-style stat. Internally
/// wraps [ArcGauge]; pass [gaugeStyle] for full token-level control, or
/// rely on [accentColor] alone for the common case.
///
/// ```dart
/// GaugeRingCard(
///   controller: batteryCtrl,
///   label: 'BATTERY',
///   icon: Icons.battery_charging_full,
///   accentColor: const Color(0xFF34D399),
///   unitText: '%',
/// )
/// ```
///
/// See also the ready-made presets built on top of this widget:
/// [BatteryStatCard], [RangeStatCard], [EcoScoreStatCard], [ClimateStatCard],
/// and [SpeedStatCard].
class GaugeRingCard extends StatelessWidget {
  const GaugeRingCard({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.min = 0,
    this.max = 100,
    this.unitText,
    this.valueFormatter,
    this.ringSize = 96,
    this.trackWidth = 10,
    this.startAngleDeg = 135,
    this.sweepAngleDeg = 270,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.gaugeStyle,
    this.mode,
    this.semanticsLabel,
    this.colorForValue,
  });

  /// Drives the ring fill and the centred numeral.
  final GaugeController controller;

  /// Small uppercase label shown in the card header.
  final String label;

  /// Icon shown in a tinted badge next to [label].
  final IconData icon;

  /// Accent colour used for the ring, its glow, and the icon badge —
  /// unless overridden per-frame by [colorForValue].
  final Color accentColor;

  /// Minimum scale value.
  final double min;

  /// Maximum scale value.
  final double max;

  /// Unit suffix appended to the centred numeral (e.g. `'%'`, `'km'`).
  final String? unitText;

  /// Custom formatter for the centred numeral. Defaults to a rounded
  /// whole-number display.
  final String Function(double)? valueFormatter;

  /// Diameter of the ring gauge in logical pixels.
  final double ringSize;

  /// Stroke width of the ring track and value arc.
  final double trackWidth;

  /// Arc start angle in degrees.
  final double startAngleDeg;

  /// Arc sweep in degrees.
  final double sweepAngleDeg;

  /// Whether to cast an accent-tinted glow behind the card and along the
  /// value arc.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Escape hatch for full token-level control over the ring gauge. When
  /// provided, this replaces the kit's built-in accent-colour styling
  /// entirely.
  final GaugeStyle? gaugeStyle;

  /// Ambient or instrument rendering mode for the underlying [ArcGauge].
  final GaugeMode? mode;

  /// Accessibility label for the ring gauge. Defaults to [label].
  final String? semanticsLabel;

  /// Optional callback recomputing the accent colour from the current
  /// value — e.g. to flag a critically low battery in red. When omitted,
  /// [accentColor] is used unconditionally.
  final Color Function(double value)? colorForValue;

  String _formatValue(double v) {
    if (valueFormatter != null) return valueFormatter!(v);
    return v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final effectiveColor =
            colorForValue?.call(controller.value) ?? accentColor;
        final resolvedGaugeStyle = gaugeStyle ??
            const DefaultGaugeStyle().override(
              GaugeTokensOverride(
                trackColor: cardStyle.trackColor,
                valueColor: effectiveColor,
                valueGradient: LinearGradient(
                  colors: [
                    effectiveColor,
                    effectiveColor.withValues(alpha: 0.55),
                  ],
                ),
                valueStrokeWidth: trackWidth,
                valueGlowRadius: showGlow ? 10 : 0,
                valueGlowColor: effectiveColor.withValues(alpha: 0.6),
              ),
            );

        return DashboardCard(
          accentColor: effectiveColor,
          showGlow: showGlow,
          style: cardStyle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DashboardCardHeader(
                label: label,
                icon: icon,
                accentColor: effectiveColor,
                style: cardStyle,
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: ArcGauge(
                    controller: controller,
                    min: min,
                    max: max,
                    startAngleDeg: startAngleDeg,
                    sweepAngleDeg: sweepAngleDeg,
                    style: resolvedGaugeStyle,
                    mode: mode,
                    semanticsLabel: semanticsLabel ?? label,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatValue(controller.value),
                          style: cardStyle.valueStyle,
                        ),
                        if (unitText != null)
                          Text(unitText!, style: cardStyle.unitStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
