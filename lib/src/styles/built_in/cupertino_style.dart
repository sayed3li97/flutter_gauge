import 'package:flutter/cupertino.dart';

import '../../core/gauge_mode.dart';
import '../../core/gauge_tick_style.dart';
import '../gauge_style.dart';
import '../gauge_tokens.dart';

/// iOS / Cupertino gauge style. Uses CupertinoTheme colors.
class CupertinoGaugeStyle extends GaugeStyle {
  const CupertinoGaugeStyle();

  @override
  GaugeTokens resolve(BuildContext context, GaugeMode mode) {
    
    final ct = CupertinoTheme.of(context);
    final isInstrument = mode == GaugeMode.instrument;
    final brightness = CupertinoTheme.brightnessOf(context);
    final isDark = brightness == Brightness.dark;

    final trackColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE5E5EA);
    final onSurface = isDark
        ? const Color(0xFFAEAEB2)
        : const Color(0xFF636366);

    return GaugeTokens(
      trackColor: trackColor,
      trackStrokeWidth: isInstrument ? 6 : 10,
      trackStrokeCap: isInstrument ? StrokeCap.butt : StrokeCap.round,
      trackBorderRadius: 5,
      valueColor: ct.primaryColor,
      valueStrokeWidth: isInstrument ? 6 : 10,
      needleColor: ct.primaryColor,
      needleWidth: isInstrument ? 2 : 2.5,
      needleTipStyle: NeedleTipStyle.sharp,
      needleDropShadow: false,
      knobColor: ct.primaryColor,
      knobRadius: isInstrument ? 5 : 7,
      knobBorderColor: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
      knobBorderWidth: 2,
      majorTick: GaugeTickStyle(
        color: onSurface,
        strokeWidth: 1.5,
        length: isInstrument ? 9 : 11,
      ),
      minorTick: GaugeTickStyle(
        color: onSurface.withValues(alpha: 0.5),
        strokeWidth: 1,
        length: isInstrument ? 4 : 5,
      ),
      labelStyle: TextStyle(
        fontFamily: '.SF Pro Rounded',
        fontSize: 11,
        color: onSurface,
        fontFeatures: isInstrument
            ? const [FontFeature.tabularFigures()]
            : null,
      ),
      labelOffset: 14,
      zoneNormal: const Color(0xFF0077BB),
      zoneWarning: const Color(0xFFEE7733),
      zoneDanger: const Color(0xFFCC3311),
      annotationTextStyle: TextStyle(
        fontFamily: '.SF Pro Rounded',
        fontSize: 10,
        color: onSurface,
      ),
      dragOverlayColor: ct.primaryColor.withValues(alpha: 0.15),
      dragOverlayRadius: 18,
      animationDuration: isInstrument
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 500),
      animationCurve: isInstrument ? Curves.easeOut : Curves.easeInOut,
    );
  }
}
