import 'package:flutter/material.dart';

import 'dashboard_card_style.dart';

/// The rounded "glass card" chrome shared by every dashboard stat card —
/// background, border, corner radius, and an optional accent-coloured glow
/// shadow.
///
/// Exposed publicly so a fully custom card can reuse the same chrome as
/// [GaugeRingCard] and [GaugeBarCard].
///
/// ```dart
/// DashboardCard(
///   accentColor: Colors.cyan,
///   child: Column(children: [ /* anything */ ]),
/// )
/// ```
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.accentColor,
    this.showGlow = true,
    this.style = const DashboardCardStyle(),
  });

  /// Card content.
  final Widget child;

  /// Colour of the glow shadow cast behind the card when [showGlow] is
  /// `true`. Has no effect if `null`.
  final Color? accentColor;

  /// Whether to cast an [accentColor]-tinted glow behind the card.
  final bool showGlow;

  /// Card chrome (background, border, corner radius, text styles).
  final DashboardCardStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: style.padding,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(style.cornerRadius),
        border: Border.all(color: style.borderColor, width: style.borderWidth),
        boxShadow: showGlow && accentColor != null && style.glowOpacity > 0
            ? [
                BoxShadow(
                  color: accentColor!.withValues(alpha: style.glowOpacity),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// The icon-badge + label row used as the header of every dashboard stat
/// card.
///
/// Exposed publicly for building fully custom cards with the same header
/// treatment as [GaugeRingCard] and [GaugeBarCard].
class DashboardCardHeader extends StatelessWidget {
  const DashboardCardHeader({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.style = const DashboardCardStyle(),
  });

  /// Small uppercase label text.
  final String label;

  /// Icon shown in a tinted circular badge.
  final IconData icon;

  /// Accent colour for the icon and its badge background.
  final Color accentColor;

  /// Card chrome — only [DashboardCardStyle.labelStyle] is used here.
  final DashboardCardStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: accentColor),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: style.labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
