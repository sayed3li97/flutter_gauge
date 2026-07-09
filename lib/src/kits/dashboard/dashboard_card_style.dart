import 'package:flutter/material.dart';

/// Shared "card chrome" for the dashboard stat card kit — background,
/// border, corner radius, padding, and text styles.
///
/// This governs the container around a gauge, not the gauge canvas itself
/// (see [GaugeStyle]/[GaugeTokens] for that). The defaults match a dark
/// "smart car dashboard" aesthetic: a near-black glass card with a faint
/// white edge. Override any field to match your own brand, or build a
/// light-theme variant with [copyWith].
///
/// ```dart
/// const lightCard = DashboardCardStyle(
///   backgroundColor: Colors.white,
///   borderColor: Color(0x14000000),
///   labelStyle: TextStyle(color: Colors.black54, fontSize: 11),
///   valueStyle: TextStyle(color: Colors.black87, fontSize: 30),
/// );
/// ```
class DashboardCardStyle {
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
  /// dark [backgroundColor] default — override this alongside
  /// [backgroundColor] for a light theme, e.g. `Color(0x14000000)`, or the
  /// track becomes invisible against a white card.
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
