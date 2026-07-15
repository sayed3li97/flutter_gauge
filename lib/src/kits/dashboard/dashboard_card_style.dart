import 'package:flutter/material.dart';

/// Shared "card chrome" for the dashboard stat card kit — background,
/// border, corner radius, padding, and text styles.
///
/// This governs the container around a gauge, not the gauge canvas itself
/// (see [GaugeStyle]/[GaugeTokens] for that). The defaults match a dark
/// "smart car dashboard" aesthetic: a near-black glass card with a faint
/// white edge.
///
/// For a light theme, prefer the [DashboardCardStyle.light] constructor over
/// hand-overriding fields — it sets a coherent set of light-appropriate
/// colours (including [trackColor], which is easy to forget and renders the
/// gauge's empty track invisible against a white card if left dark-tuned):
///
/// ```dart
/// // Light cabin / rental-booking theme:
/// const style = DashboardCardStyle.light();
///
/// // The dark default is also available by name for symmetry:
/// const style = DashboardCardStyle.dark();
///
/// // Either constructor still takes per-field overrides:
/// const branded = DashboardCardStyle.light(cornerRadius: 12);
/// ```
class DashboardCardStyle {
  /// The default (dark) card chrome — a near-black glass card with a faint
  /// white edge. Every field is overridable.
  const DashboardCardStyle({
    this.backgroundColor = const Color(0xFF12151C),
    this.borderColor = const Color(0x14FFFFFF),
    this.borderWidth = 1.0,
    this.cornerRadius = 24.0,
    this.padding = const EdgeInsets.all(16),
    this.labelStyle = const TextStyle(
      color: Color(0xFF8A8F98),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
    this.valueStyle = const TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
    this.unitStyle = const TextStyle(
      color: Color(0xFF8A8F98),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    this.glowOpacity = 0.35,
    this.trackColor = const Color(0x14FFFFFF),
  });

  /// A dark card chrome — a named alias for the default unnamed constructor,
  /// provided for symmetry with [DashboardCardStyle.light] so the theme
  /// choice reads explicitly at the call site.
  ///
  /// This redirects to the default constructor rather than re-listing the
  /// dark defaults, so the two can never drift apart. If you need to tweak
  /// individual fields on a dark card, use the default constructor (which is
  /// already the dark theme) or [copyWith].
  const DashboardCardStyle.dark() : this();

  /// A light card chrome — a white card with a faint dark edge, slate text,
  /// and a subtle glow, for a sun-visor display or a rental-booking screen.
  ///
  /// Crucially this also flips [trackColor] to a low-alpha *dark* wash so the
  /// gauge's empty track stays visible against the white card — the field
  /// most easily forgotten when hand-building a light variant. Every field is
  /// overridable.
  const DashboardCardStyle.light({
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0x14000000),
    this.borderWidth = 1.0,
    this.cornerRadius = 24.0,
    this.padding = const EdgeInsets.all(16),
    this.labelStyle = const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
    this.valueStyle = const TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
    this.unitStyle = const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    this.glowOpacity = 0.12,
    this.trackColor = const Color(0x14000000),
  });

  /// Card fill colour.
  final Color backgroundColor;

  /// Card edge colour — a faint stroke that reads as "glass" on a dark
  /// background.
  final Color borderColor;

  /// Card edge stroke width.
  final double borderWidth;

  /// Card corner radius.
  final double cornerRadius;

  /// Inner padding between the card edge and its content.
  final EdgeInsetsGeometry padding;

  /// Text style for the small uppercase label in the card header.
  final TextStyle labelStyle;

  /// Text style for the large primary value numeral.
  final TextStyle valueStyle;

  /// Text style for the unit suffix beside the value numeral.
  final TextStyle unitStyle;

  /// Opacity of the accent-coloured glow cast behind a card when its
  /// `showGlow` is `true`. `0` disables the glow shadow.
  final double glowOpacity;

  /// Colour of the *unfilled* portion of a ring or bar gauge inside the
  /// card. The default (a faint white wash) reads as "empty track" on the
  /// dark [backgroundColor] default. For a light theme, prefer the
  /// [DashboardCardStyle.light] constructor, which flips this to a dark wash
  /// (`Color(0x14000000)`) for you — otherwise the track becomes invisible
  /// against a white card.
  final Color trackColor;

  /// Returns a copy with the given fields replaced.
  DashboardCardStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? cornerRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    TextStyle? unitStyle,
    double? glowOpacity,
    Color? trackColor,
  }) {
    return DashboardCardStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      padding: padding ?? this.padding,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      unitStyle: unitStyle ?? this.unitStyle,
      glowOpacity: glowOpacity ?? this.glowOpacity,
      trackColor: trackColor ?? this.trackColor,
    );
  }
}
