import 'package:flutter/material.dart';

import '../../core/gauge_mode.dart';
import '../../core/gauge_tick_style.dart';
import '../gauge_style.dart';
import '../gauge_tokens.dart';

/// Material 3 gauge style. Reads color scheme from the nearest [Theme].
class MaterialGaugeStyle extends GaugeStyle {
  const MaterialGaugeStyle();

  @override
  GaugeTokens resolve(BuildContext context, GaugeMode mode) {
    
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isInstrument = mode == GaugeMode.instrument;

    return GaugeTokens(
      trackColor: cs.surfaceContainerHighest,
      trackStrokeWidth: isInstrument ? 6 : 10,
      trackStrokeCap: isInstrument ? StrokeCap.butt : StrokeCap.round,
      trackBorderRadius: 4,
      valueColor: cs.primary,
      valueStrokeWidth: isInstrument ? 6 : 10,
      needleColor: cs.primary,
      needleWidth: isInstrument ? 2.5 : 3,
      needleTipStyle: NeedleTipStyle.sharp,
      needleDropShadow: !isInstrument,
      knobColor: cs.primary,
      knobRadius: isInstrument ? 6 : 8,
      knobBorderColor: cs.surface,
      knobBorderWidth: 2,
      majorTick: GaugeTickStyle(
        color: cs.onSurfaceVariant,
        strokeWidth: 1.5,
        length: isInstrument ? 10 : 12,
      ),
      minorTick: GaugeTickStyle(
        color: cs.outlineVariant,
        strokeWidth: 1,
        length: isInstrument ? 5 : 6,
      ),
      labelStyle: (tt.bodySmall ?? const TextStyle()).copyWith(
        color: cs.onSurfaceVariant,
        fontFeatures: isInstrument
            ? const [FontFeature.tabularFigures()]
            : null,
      ),
      labelOffset: 16,
      zoneNormal: const Color(0xFF0077BB),
      zoneWarning: const Color(0xFFEE7733),
      zoneDanger: const Color(0xFFCC3311),
      annotationTextStyle: (tt.labelSmall ?? const TextStyle()).copyWith(
        color: cs.onSurfaceVariant,
      ),
      dragOverlayColor: cs.primary.withValues(alpha: 0.2),
      dragOverlayRadius: 20,
      animationDuration: isInstrument
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 600),
      animationCurve: isInstrument ? Curves.easeOut : Curves.easeInOut,
    );
  }
}
