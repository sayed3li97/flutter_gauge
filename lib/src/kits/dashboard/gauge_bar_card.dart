import 'package:flutter/material.dart';

import '../../core/gauge_controller.dart';
import '../../core/gauge_mode.dart';
import '../../styles/gauge_style.dart';
import '../../widgets/linear_gauge.dart';
import 'dashboard_card.dart';
import 'dashboard_card_style.dart';

/// A rounded "glass" card with a large numeral and a pill-shaped gradient
/// progress bar beneath it.
///
/// Used for level-style stats where a linear bar reads more naturally than
/// a ring — tyre pressure, fuel, or trip distance. Internally wraps
/// [LinearGauge]; pass [gaugeStyle] for full token-level control, or rely
/// on [accentColor] alone for the common case.
///
/// ```dart
/// GaugeBarCard(
///   controller: fuelCtrl,
///   label: 'FUEL',
///   icon: Icons.local_gas_station,
///   accentColor: const Color(0xFFFB7185),
///   unitText: '%',
/// )
/// ```
///
/// See also the ready-made presets built on top of this widget:
/// [TirePressureStatCard], [FuelStatCard], and [TripStatCard].
class GaugeBarCard extends StatelessWidget {
  const GaugeBarCard({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.min = 0,
    this.max = 100,
    this.unitText,
    this.valueFormatter,
    this.barHeight = 14,
    this.showGlow = true,
    this.cardStyle = const DashboardCardStyle(),
    this.gaugeStyle,
    this.mode,
    this.semanticsLabel,
    this.colorForValue,
  });

  /// Drives the bar fill and the numeral above it.
  final GaugeController controller;

  /// Small uppercase label shown in the card header.
  final String label;

  /// Icon shown in a tinted badge next to [label].
  final IconData icon;

  /// Accent colour used for the bar, its glow, and the icon badge —
  /// unless overridden per-frame by [colorForValue].
  final Color accentColor;

  /// Minimum scale value.
  final double min;

  /// Maximum scale value.
  final double max;

  /// Unit suffix appended to the numeral (e.g. `'%'`, `'PSI'`).
  final String? unitText;

  /// Custom formatter for the numeral. Defaults to a rounded whole-number
  /// display.
  final String Function(double)? valueFormatter;

  /// Height of the pill-shaped bar in logical pixels.
  final double barHeight;

  /// Whether to cast an accent-tinted glow behind the card and along the
  /// value bar.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle cardStyle;

  /// Escape hatch for full token-level control over the bar gauge. When
  /// provided, this replaces the kit's built-in accent-colour styling
  /// entirely.
  final GaugeStyle? gaugeStyle;

  /// Ambient or instrument rendering mode for the underlying [LinearGauge].
  final GaugeMode? mode;

  /// Accessibility label for the bar gauge. Defaults to [label].
  final String? semanticsLabel;

  /// Optional callback recomputing the accent colour from the current
  /// value — e.g. to flag a critical tyre-pressure reading in red. When
  /// omitted, [accentColor] is used unconditionally.
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
                trackStrokeWidth: barHeight,
                valueGlowRadius: showGlow ? 8 : 0,
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
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatValue(controller.value),
                    style: cardStyle.valueStyle,
                  ),
                  if (unitText != null) ...[
                    const SizedBox(width: 4),
                    Text(unitText!, style: cardStyle.unitStyle),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: barHeight,
                child: LinearGauge(
                  controller: controller,
                  min: min,
                  max: max,
                  showLabels: false,
                  showTicks: false,
                  barRadius: barHeight / 2,
                  style: resolvedGaugeStyle,
                  mode: mode,
                  semanticsLabel: semanticsLabel ?? label,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
