import 'package:flutter/widgets.dart';

import '../core/gauge_mode.dart';
import '../core/gauge_tick_style.dart';
import 'gauge_tokens.dart';
import 'gauge_tokens_override.dart';

export 'gauge_tokens_override.dart';

/// Abstract strategy that resolves [GaugeTokens] from context + mode.
/// Engine files must never import style files — they only consume [GaugeTokens].
abstract class GaugeStyle {
  const GaugeStyle();

  GaugeTokens resolve(BuildContext context, GaugeMode mode);

  /// Wraps this style with a partial [GaugeTokensOverride].
  GaugeStyle override(GaugeTokensOverride overrides) =>
      _OverrideGaugeStyle(base: this, overrides: overrides);
}

class _OverrideGaugeStyle extends GaugeStyle {
  const _OverrideGaugeStyle({
    required this.base,
    required this.overrides,
  });

  final GaugeStyle base;
  final GaugeTokensOverride overrides;

  @override
  GaugeTokens resolve(BuildContext context, GaugeMode mode) =>
      overrides.apply(base.resolve(context, mode));
}

/// Fallback style used when no [GaugeThemeExtension] is found.
class DefaultGaugeStyle extends GaugeStyle {
  const DefaultGaugeStyle();

  @override
  GaugeTokens resolve(BuildContext context, GaugeMode mode) {
    final isInstrument = mode == GaugeMode.instrument;
    return GaugeTokens(
      trackColor: const Color(0x1F000000),
      trackStrokeWidth: isInstrument ? 6 : 10,
      trackStrokeCap: isInstrument ? StrokeCap.butt : StrokeCap.round,
      trackBorderRadius: 4,
      valueColor: const Color(0xFF6750A4),
      valueStrokeWidth: isInstrument ? 6 : 10,
      needleColor: const Color(0xFF6750A4),
      needleWidth: 3,
      needleTipStyle: NeedleTipStyle.sharp,
      needleDropShadow: !isInstrument,
      knobColor: const Color(0xFF6750A4),
      knobRadius: 8,
      knobBorderWidth: 0,
      majorTick: const GaugeTickStyle(
        color: Color(0xFF49454F),
        strokeWidth: 1.5,
        length: 12,
      ),
      minorTick: const GaugeTickStyle(
        color: Color(0xFF79747E),
        strokeWidth: 1,
        length: 6,
      ),
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF49454F)),
      labelOffset: 16,
      zoneNormal: const Color(0xFF0077BB),
      zoneWarning: const Color(0xFFEE7733),
      zoneDanger: const Color(0xFFCC3311),
      annotationTextStyle:
          const TextStyle(fontSize: 11, color: Color(0xFF49454F)),
      dragOverlayColor: const Color(0x336750A4),
      dragOverlayRadius: 20,
      animationDuration: isInstrument
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 600),
      animationCurve: isInstrument ? Curves.easeOut : Curves.easeInOut,
    );
  }
}

const Color kCBSafeNormal = Color(0xFF0077BB);
const Color kCBSafeWarning = Color(0xFFEE7733);
const Color kCBSafeDanger = Color(0xFFCC3311);
