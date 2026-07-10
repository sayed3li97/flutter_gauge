import 'package:flutter/material.dart';

import '../../core/gauge_controller.dart';
import '../../core/gauge_mode.dart';
import '../../styles/gauge_style.dart';
import '../../widgets/linear_gauge.dart';
import 'dashboard_card_style.dart';

/// A full-width horizontal row: icon badge, label + big value on the left,
/// a slim inline progress indicator on the right.
///
/// Where [GaugeRingCard]/[GaugeBarCard] are boxed tiles for a grid, this is
/// the row primitive for a *list*-style dashboard — a settings-style
/// grouped list rather than a bento grid. Typically several are stacked
/// inside one [DashboardCard] with a divider between each, so the group
/// reads as a single card:
///
/// ```dart
/// DashboardCard(
///   child: Column(
///     children: [
///       GaugeListTile(controller: batteryCtrl, label: 'BATTERY',
///           icon: Icons.battery_charging_full, accentColor: Colors.green,
///           unitText: '%'),
///       const Divider(height: 1),
///       GaugeListTile(controller: rangeCtrl, label: 'RANGE',
///           icon: Icons.route, accentColor: Colors.purple, unitText: 'km',
///           max: 500),
///     ],
///   ),
/// )
/// ```
class GaugeListTile extends StatelessWidget {
  const GaugeListTile({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.min = 0,
    this.max = 100,
    this.unitText,
    this.valueFormatter,
    this.cardStyle = const DashboardCardStyle(),
    this.gaugeStyle,
    this.mode,
    this.semanticsLabel,
    this.colorForValue,
    this.showTrailingIndicator = true,
    this.trailingIndicatorWidth = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
  });

  /// Drives the value text and the trailing indicator fill.
  final GaugeController controller;

  /// Small uppercase label shown above the value.
  final String label;

  /// Icon shown in a tinted badge at the start of the row.
  final IconData icon;

  /// Accent colour used for the trailing indicator and the icon badge —
  /// unless overridden per-frame by [colorForValue].
  final Color accentColor;

  /// Minimum scale value.
  final double min;

  /// Maximum scale value.
  final double max;

  /// Unit suffix appended to the value (e.g. `'%'`, `'km'`).
  final String? unitText;

  /// Custom formatter for the value. Defaults to a rounded whole-number
  /// display.
  final String Function(double)? valueFormatter;

  /// Row chrome — only the text styles are used here (no background/border,
  /// since the row is meant to sit inside a parent [DashboardCard]).
  final DashboardCardStyle cardStyle;

  /// Escape hatch for full token-level control over the trailing indicator.
  final GaugeStyle? gaugeStyle;

  /// Ambient or instrument rendering mode for the trailing indicator.
  final GaugeMode? mode;

  /// Accessibility label for the trailing indicator. Defaults to [label].
  final String? semanticsLabel;

  /// Optional callback recomputing the accent colour from the current
  /// value — e.g. to flag a critical reading in red.
  final Color Function(double value)? colorForValue;

  /// Whether to show the slim pill-bar indicator at the end of the row.
  final bool showTrailingIndicator;

  /// Width of the trailing indicator bar.
  final double trailingIndicatorWidth;

  /// Row padding.
  final EdgeInsetsGeometry padding;

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

        return Padding(
          padding: padding,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: effectiveColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: cardStyle.labelStyle),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatValue(controller.value),
                          style: cardStyle.valueStyle.copyWith(fontSize: 20),
                        ),
                        if (unitText != null) ...[
                          const SizedBox(width: 3),
                          Text(unitText!, style: cardStyle.unitStyle),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (showTrailingIndicator) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: trailingIndicatorWidth,
                  height: 6,
                  child: LinearGauge(
                    controller: controller,
                    min: min,
                    max: max,
                    showLabels: false,
                    showTicks: false,
                    barRadius: 3,
                    style: gaugeStyle ??
                        const DefaultGaugeStyle().override(
                          GaugeTokensOverride(
                            trackColor: cardStyle.trackColor,
                            valueColor: effectiveColor,
                          ),
                        ),
                    mode: mode,
                    semanticsLabel: semanticsLabel ?? label,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
