import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show BuildContext;

import '../../core/gauge_mode.dart';
import '../../core/gauge_tick_style.dart';
import '../gauge_style.dart';
import '../gauge_tokens.dart';

/// Executive / dark-panel industrial gauge style.
/// Black background, chrome accents, amber needle — no Flutter theme dependency.
class ExecutiveGaugeStyle extends GaugeStyle {
  const ExecutiveGaugeStyle();

  static const _chrome = Color(0xFFD4D0C8);
  static const _amber = Color(0xFFFFB300);
  static const _dimText = Color(0xFF9E9E9E);

  @override
  GaugeTokens resolve(BuildContext context, GaugeMode mode) {
    final isInstrument = mode == GaugeMode.instrument;

    return GaugeTokens(
      trackColor: const Color(0xFF2C2C2C),
      trackStrokeWidth: isInstrument ? 6 : 8,
      trackStrokeCap: StrokeCap.butt,
      trackBorderRadius: 0,
      valueColor: _amber,
      valueStrokeWidth: isInstrument ? 6 : 8,
      valueGradient: const LinearGradient(
        colors: [Color(0xFFFF8F00), Color(0xFFFFD54F)],
      ),
      needleColor: _amber,
      needleWidth: isInstrument ? 2.5 : 3,
      needleTipStyle: NeedleTipStyle.sharp,
      needleDropShadow: true,
      knobColor: _chrome,
      knobRadius: isInstrument ? 6 : 9,
      knobBorderColor: const Color(0xFF1A1A1A),
      knobBorderWidth: 2,
      majorTick: GaugeTickStyle(
        color: _chrome,
        strokeWidth: isInstrument ? 1.5 : 2,
        length: isInstrument ? 10 : 14,
      ),
      minorTick: GaugeTickStyle(
        color: _dimText,
        strokeWidth: 1,
        length: isInstrument ? 5 : 7,
      ),
      labelStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 11,
        color: _chrome,
        letterSpacing: 0.5,
        fontFeatures:
            isInstrument ? const [FontFeature.tabularFigures()] : null,
      ),
      labelOffset: 18,
      zoneNormal: const Color(0xFF0077BB),
      zoneWarning: const Color(0xFFEE7733),
      zoneDanger: const Color(0xFFCC3311),
      annotationTextStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        color: _dimText,
      ),
      dragOverlayColor: _amber.withValues(alpha: 0.2),
      dragOverlayRadius: 22,
      animationDuration: isInstrument
          ? const Duration(milliseconds: 250)
          : const Duration(milliseconds: 500),
      animationCurve: Curves.easeOut,
    );
  }
}
