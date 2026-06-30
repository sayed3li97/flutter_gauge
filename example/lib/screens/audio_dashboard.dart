import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class AudioDashboardScreen extends StatefulWidget {
  const AudioDashboardScreen({super.key});

  @override
  State<AudioDashboardScreen> createState() => _AudioDashboardScreenState();
}

class _AudioDashboardScreenState extends State<AudioDashboardScreen> {
  // 6 channel level meters (0–100 dBFS mapped to 0–100)
  final _kickCtrl = GaugeController(initialValue: 0.0);
  final _bassCtrl = GaugeController(initialValue: 0.0);
  final _gtrLCtrl = GaugeController(initialValue: 0.0);
  final _gtrRCtrl = GaugeController(initialValue: 0.0);
  final _voxCtrl = GaugeController(initialValue: 0.0);
  final _masterCtrl = GaugeController(initialValue: 0.0);

  // Metering/analysis instruments
  final _loudnessCtrl = GaugeController(initialValue: -18.0); // LUFS: -23..0
  final _dynRangeCtrl = GaugeController(initialValue: 12.0); // DR: 0..20
  final _gainRedCtrl =
      GaugeController(initialValue: -4.0); // Gain reduction: -20..0 dB
  final _panCtrl = GaugeController(initialValue: 0.0); // Pan: -100..+100

  Timer? _timer;
  final _rng = Random();
  double _phase = 0.0;

  // Per-channel "activity patterns" — sin frequency per channel
  static const _channelFreqs = [1.8, 0.9, 1.3, 1.4, 0.7, 1.1];

  List<GaugeController> get _channelCtrls => [
        _kickCtrl,
        _bassCtrl,
        _gtrLCtrl,
        _gtrRCtrl,
        _voxCtrl,
        _masterCtrl,
      ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _phase += 0.15;

      // Simulate live VU bouncing — each channel has its own character
      for (var i = 0; i < _channelCtrls.length; i++) {
        final base = 40.0 + 30.0 * sin(_phase * _channelFreqs[i]);
        final noise = _rng.nextDouble() * 20.0;
        final peak = max(0.0, base + noise);
        _channelCtrls[i].value = peak.clamp(0.0, 100.0);
      }

      // Master is the loudest of all channels
      _masterCtrl.value = _channelCtrls
          .take(5)
          .map((c) => c.value)
          .reduce(max)
          .clamp(0.0, 100.0);

      // Loudness: -23 to 0 LUFS, slowly wanders
      _loudnessCtrl.value =
          (-16.0 + 4.0 * sin(_phase * 0.18)).clamp(-23.0, 0.0);

      // Dynamic range varies inversely with loudness
      _dynRangeCtrl.value = (14.0 - 3.0 * sin(_phase * 0.18)).clamp(0.0, 20.0);

      // Gain reduction tracks master level
      _gainRedCtrl.value = (-_masterCtrl.value / 10.0).clamp(-20.0, 0.0);

      // Pan position slowly sweeps
      _panCtrl.value = (25.0 * sin(_phase * 0.08)).clamp(-100.0, 100.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _channelCtrls) {
      c.dispose();
    }
    _loudnessCtrl.dispose();
    _dynRangeCtrl.dispose();
    _gainRedCtrl.dispose();
    _panCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0A0A0A);
    const style = ExecutiveGaugeStyle();
    const mode = GaugeMode.instrument;
    const headerStyle = TextStyle(
      color: Color(0xFF888888),
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.8,
    );

    final channels = [
      ('KICK', _kickCtrl, const Color(0xFFCC3311)),
      ('BASS', _bassCtrl, const Color(0xFFBB5500)),
      ('GTR L', _gtrLCtrl, const Color(0xFF228833)),
      ('GTR R', _gtrRCtrl, const Color(0xFF228833)),
      ('VOX', _voxCtrl, const Color(0xFF0077BB)),
      ('MASTER', _masterCtrl, const Color(0xFFCC9900)),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF080808),
                border: Border(bottom: BorderSide(color: Color(0xFF222222))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AUDIO MIXING CONSOLE',
                    style: TextStyle(
                      color: Color(0xFFCC9900),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                  Row(children: [
                    _ConsoleLed(color: const Color(0xFF44BB66), label: 'PWR'),
                    const SizedBox(width: 12),
                    _ConsoleLed(color: const Color(0xFFCC9900), label: 'REC'),
                    const SizedBox(width: 12),
                    _ConsoleLed(color: const Color(0xFF0077BB), label: 'SYNC'),
                  ]),
                ],
              ),
            ),

            // ── Main content ──────────────────────────────────────────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left 60%: Channel strips ──────────────────────────
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          const Text('CHANNEL METERS', style: headerStyle),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Row(
                              children: channels.map((ch) {
                                final (label, ctrl, accent) = ch;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Column(
                                      children: [
                                        // dBFS value at top
                                        ListenableBuilder(
                                          listenable: ctrl,
                                          builder: (_, __) {
                                            final dbfs =
                                                -60.0 + ctrl.value * 0.6;
                                            return Text(
                                              dbfs.toStringAsFixed(0),
                                              style: TextStyle(
                                                color: ctrl.value > 90
                                                    ? const Color(0xFFCC3311)
                                                    : accent,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 4),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              // Conditional border when hot
                                              Positioned.fill(
                                                child: ListenableBuilder(
                                                  listenable: ctrl,
                                                  builder: (_, __) => Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: ctrl.value > 90
                                                            ? const Color(
                                                                0xFFCC3311)
                                                            : Colors
                                                                .transparent,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                    ),
                                                    child: LevelMeterGauge(
                                                      controller: ctrl,
                                                      min: 0,
                                                      max: 100,
                                                      channelCount: 1,
                                                      gap: 1,
                                                      style: style,
                                                      mode: mode,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            color: accent,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: const Color(0xFF222222)),

                  // ── Right 40%: Analysis instruments ────────────────────
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('METERING & ANALYSIS', style: headerStyle),
                          const SizedBox(height: 10),

                          // Stereo master meter
                          const Text('STEREO MASTER', style: headerStyle),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 80,
                            child: LevelMeterGauge.stereo(
                              controller: _masterCtrl,
                              style: style,
                              mode: mode,
                            ),
                          ),

                          const SizedBox(height: 12),
                          Container(height: 1, color: const Color(0xFF222222)),
                          const SizedBox(height: 12),

                          // Loudness LUFS
                          const Text('LOUDNESS  (LUFS)', style: headerStyle),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 40,
                            child: BulletGauge(
                              controller: _loudnessCtrl,
                              min: -23,
                              max: 0,
                              targetValue: -14,
                              poorThreshold: -20,
                              satisfactoryThreshold: -16,
                              label: 'INT',
                              style: style,
                              mode: mode,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Dynamic Range
                          const Text('DYNAMIC RANGE  (DR)', style: headerStyle),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 40,
                            child: BulletGauge(
                              controller: _dynRangeCtrl,
                              min: 0,
                              max: 20,
                              targetValue: 14,
                              poorThreshold: 6,
                              satisfactoryThreshold: 10,
                              label: 'DR',
                              style: style,
                              mode: mode,
                            ),
                          ),

                          const SizedBox(height: 12),
                          Container(height: 1, color: const Color(0xFF222222)),
                          const SizedBox(height: 12),

                          // Gain Reduction
                          const Text('GAIN REDUCTION  (dB)',
                              style: headerStyle),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 50,
                            child: DeltaGauge(
                              controller: _gainRedCtrl,
                              baseline: 0,
                              min: -20,
                              max: 0,
                              unit: 'dB',
                              style: style,
                              mode: mode,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Pan position arc with L/C/R overlay
                          const Text('PAN POSITION', style: headerStyle),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ListenableBuilder(
                                    listenable: _panCtrl,
                                    builder: (_, __) => ArcGauge(
                                      controller: _panCtrl,
                                      min: -100,
                                      max: 100,
                                      startAngleDeg: 160,
                                      sweepAngleDeg: 220,
                                      centerLabel: _panCtrl.value.abs() < 5
                                          ? 'C'
                                          : _panCtrl.value < 0
                                              ? 'L${_panCtrl.value.abs().toStringAsFixed(0)}'
                                              : 'R${_panCtrl.value.toStringAsFixed(0)}',
                                      style: style,
                                      mode: mode,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsoleLed extends StatelessWidget {
  final Color color;
  final String label;
  const _ConsoleLed({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4)
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              color: Color(0xFF666666), fontSize: 9, letterSpacing: 1.0),
        ),
      ],
    );
  }
}
