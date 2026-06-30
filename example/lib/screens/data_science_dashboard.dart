import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class DataScienceDashboardScreen extends StatefulWidget {
  const DataScienceDashboardScreen({super.key});

  @override
  State<DataScienceDashboardScreen> createState() =>
      _DataScienceDashboardScreenState();
}

class _DataScienceDashboardScreenState
    extends State<DataScienceDashboardScreen> {
  // === MODEL PERFORMANCE (0–100 %) ===
  final _accuracyCtrl = GaugeController(initialValue: 87.5);
  final _precisionCtrl = GaugeController(initialValue: 91.2);
  final _recallCtrl = GaugeController(initialValue: 84.8);
  final _f1Ctrl = GaugeController(initialValue: 87.9);

  // === TRAINING PROGRESS ===
  final _epochCtrl = GaugeController(initialValue: 23.0); // out of 50
  final _accDeltaCtrl = GaugeController(initialValue: 87.5); // for DeltaGauge
  final _lrCtrl = GaugeController(initialValue: 0.30); // 0–0.5 scale

  // === GPU RESOURCES ===
  final _gpuCtrl = GaugeController(initialValue: 94.0);
  final _vramCtrl = GaugeController(initialValue: 77.5);
  final _throughputCtrl = GaugeController(initialValue: 450.0); // samples/s

  // === PIPELINE HEALTH (0=ok, 1=warn, 2=err) ===
  final _loaderCtrl = GaugeController(initialValue: 0.0);
  final _preprocCtrl = GaugeController(initialValue: 0.0);
  final _fwdCtrl = GaugeController(initialValue: 0.0);
  final _bkpropCtrl = GaugeController(initialValue: 0.0);
  final _loggerCtrl = GaugeController(initialValue: 0.0);

  // === CONFIDENCE DISTRIBUTION ===
  final _confCtrl = GaugeController(initialValue: 82.0);

  // === TRAINING COUNTERS ===
  final _samplesCtrl = GaugeController(initialValue: 115200.0);
  final _batchCtrl = GaugeController(initialValue: 1800.0);

  Timer? _timer;
  final _rng = Random();
  double _phase = 0.0;
  int _epoch = 23;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      _phase += 0.16;

      // Model metrics fluctuate slightly around their converged values
      _accuracyCtrl.value =
          (87.5 + 0.6 * sin(_phase * 0.28) + _rng.nextDouble() * 0.3)
              .clamp(0, 100);
      _precisionCtrl.value =
          (91.2 + 0.5 * sin(_phase * 0.24) + _rng.nextDouble() * 0.25)
              .clamp(0, 100);
      _recallCtrl.value =
          (84.8 + 0.7 * sin(_phase * 0.32) + _rng.nextDouble() * 0.35)
              .clamp(0, 100);
      _f1Ctrl.value =
          (87.9 + 0.6 * sin(_phase * 0.28) + _rng.nextDouble() * 0.28)
              .clamp(0, 100);

      // Accuracy delta mirrors live accuracy (baseline was 65 % at epoch 0)
      _accDeltaCtrl.value = _accuracyCtrl.value;

      // Learning-rate cosine-annealing schedule
      _lrCtrl.value =
          (0.3 * (1.0 + cos(_phase * 0.05)) / 2.0 + 0.01).clamp(0.0, 0.5);

      // GPU resources
      _gpuCtrl.value = (94.0 + 4.0 * sin(_phase * 1.5) + _rng.nextDouble() * 3)
          .clamp(0, 100);
      _vramCtrl.value = (77.5 + 1.5 * sin(_phase * 0.4)).clamp(0, 100);
      _throughputCtrl.value =
          (450.0 + 50.0 * sin(_phase * 1.1) + _rng.nextDouble() * 28)
              .clamp(100, 800);

      // Confidence distribution
      _confCtrl.value =
          (82.0 + 3.0 * sin(_phase * 0.38) + _rng.nextDouble() * 1.5)
              .clamp(0, 100);

      // Epoch counter — advance every ~12 ticks
      if (_phase % 12.0 < 0.16 && _epoch < 50) {
        _epoch++;
        _epochCtrl.value = _epoch.toDouble();
      }

      // Running counters
      _samplesCtrl.value += 64.0; // one mini-batch of 64
      _batchCtrl.value += 1.0;

      // Pipeline — occasional pre-processing hiccup
      _preprocCtrl.value = sin(_phase * 0.07) > 0.80 ? 1.0 : 0.0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [
      _accuracyCtrl,
      _precisionCtrl,
      _recallCtrl,
      _f1Ctrl,
      _epochCtrl,
      _accDeltaCtrl,
      _lrCtrl,
      _gpuCtrl,
      _vramCtrl,
      _throughputCtrl,
      _loaderCtrl,
      _preprocCtrl,
      _fwdCtrl,
      _bkpropCtrl,
      _loggerCtrl,
      _confCtrl,
      _samplesCtrl,
      _batchCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Palette ────────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0A0B14);
  static const _cardBg = Color(0xFF111320);
  static const _borderC = Color(0xFF1E2035);
  static const _accent = Color(0xFF7C65FF); // electric violet
  static const _cyan = Color(0xFF00D4FF);
  static const _emerald = Color(0xFF00CC88);
  static const _amber = Color(0xFFFF9F33);
  static const _dimC = Color(0xFF4A4D6B);

  static const _sectionLabel = TextStyle(
    color: _accent,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
  );
  static const _rowLabel = TextStyle(
    color: _dimC,
    fontSize: 9,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
  static const _dimLabel = TextStyle(
    color: _dimC,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  // Performance-zone ranges shared by all four model-metric arcs
  static const _perfRanges = [
    GaugeRange(min: 0, max: 60, color: Color(0x88CC3311)),
    GaugeRange(min: 60, max: 80, color: Color(0x88EE7733)),
  ];

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accent,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    const style = MaterialGaugeStyle();
    const mode = GaugeMode.instrument;

    return Theme(
      data: darkTheme,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ML EXPERIMENT MONITOR',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          'ResNet-50  •  ImageNet-1K  •  run exp_0847',
                          style: TextStyle(color: _dimC, fontSize: 10),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x1A00CC66),
                        border: Border.all(color: const Color(0xFF00CC66)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TRAINING',
                        style: TextStyle(
                          color: Color(0xFF00CC66),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Model Performance ─────────────────────────────────────
                const Text('MODEL PERFORMANCE', style: _sectionLabel),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 130,
                            child: _MetricArc(
                              ctrl: _accuracyCtrl,
                              label: 'ACCURACY',
                              accentColor: _cyan,
                              ranges: _perfRanges,
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 130,
                            child: _MetricArc(
                              ctrl: _precisionCtrl,
                              label: 'PRECISION',
                              accentColor: _accent,
                              ranges: _perfRanges,
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 130,
                            child: _MetricArc(
                              ctrl: _recallCtrl,
                              label: 'RECALL',
                              accentColor: _emerald,
                              ranges: _perfRanges,
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 130,
                            child: _MetricArc(
                              ctrl: _f1Ctrl,
                              label: 'F1 SCORE',
                              accentColor: _amber,
                              ranges: _perfRanges,
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Training Progress ─────────────────────────────────────
                const Text('TRAINING PROGRESS', style: _sectionLabel),
                const SizedBox(height: 8),

                // Epoch progress bar
                Row(
                  children: [
                    const SizedBox(
                        width: 72, child: Text('EPOCH', style: _rowLabel)),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: LinearGauge.progress(
                          controller: _epochCtrl,
                          min: 0,
                          max: 50,
                          style: style,
                          mode: mode,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ListenableBuilder(
                      listenable: _epochCtrl,
                      builder: (_, __) => SizedBox(
                        width: 48,
                        child: Text(
                          '${_epochCtrl.value.toStringAsFixed(0)}/50',
                          style: const TextStyle(
                            color: _cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Accuracy delta vs epoch-0 baseline (65 %)
                Row(
                  children: [
                    const SizedBox(
                        width: 72, child: Text('ACC Δ', style: _rowLabel)),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: DeltaGauge(
                          controller: _accDeltaCtrl,
                          baseline: 65.0,
                          min: 0.0,
                          max: 100.0,
                          unit: '%',
                          style: style,
                          mode: mode,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Learning-rate schedule (cosine annealing)
                Row(
                  children: [
                    const SizedBox(
                        width: 72, child: Text('LR SCHED', style: _rowLabel)),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: BulletGauge(
                          controller: _lrCtrl,
                          min: 0,
                          max: 0.5,
                          targetValue: 0.3,
                          poorThreshold: 0.05,
                          satisfactoryThreshold: 0.15,
                          label: 'learning rate ×1e-3',
                          style: style,
                          mode: mode,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ListenableBuilder(
                      listenable: _lrCtrl,
                      builder: (_, __) => SizedBox(
                        width: 56,
                        child: Text(
                          (_lrCtrl.value * 0.001).toStringAsFixed(4),
                          style: const TextStyle(
                            color: _amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── GPU Resources ─────────────────────────────────────────
                const Text('GPU RESOURCES', style: _sectionLabel),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 130,
                        child: _GpuArc(
                          ctrl: _gpuCtrl,
                          label: 'GPU UTIL',
                          style: style,
                          mode: mode,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 130,
                        child: _GpuArc(
                          ctrl: _vramCtrl,
                          label: 'VRAM',
                          style: style,
                          mode: mode,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Throughput tape gauge
                Row(
                  children: [
                    const SizedBox(
                        width: 72, child: Text('SAMPLES/S', style: _rowLabel)),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TapeGauge(
                          controller: _throughputCtrl,
                          min: 0,
                          max: 800,
                          tickInterval: 100,
                          unit: 'smp/s',
                          vertical: false,
                          style: style,
                          mode: mode,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Confidence Distribution ───────────────────────────────
                const Text('PREDICTION CONFIDENCE', style: _sectionLabel),
                const SizedBox(height: 6),
                SizedBox(
                  height: 28,
                  child: SegmentedGauge(
                    controller: _confCtrl,
                    min: 0,
                    max: 100,
                    segmentCount: 10,
                    horizontal: true,
                    gap: 2,
                    style: style,
                    mode: mode,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('50 %',
                        style: TextStyle(color: _dimC, fontSize: 8)),
                    ListenableBuilder(
                      listenable: _confCtrl,
                      builder: (_, __) => Text(
                        'avg ${_confCtrl.value.toStringAsFixed(1)} %',
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text('100 %',
                        style: TextStyle(color: _dimC, fontSize: 8)),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Pipeline Health ───────────────────────────────────────
                const Text('PIPELINE HEALTH', style: _sectionLabel),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderC),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PipelineStep('DATA\nLOADER', _loaderCtrl, style, mode),
                      _PipelineStep('PRE-\nPROC', _preprocCtrl, style, mode),
                      _PipelineStep('FWD\nPASS', _fwdCtrl, style, mode),
                      _PipelineStep('BACK-\nPROP', _bkpropCtrl, style, mode),
                      _PipelineStep('LOGGER', _loggerCtrl, style, mode),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Training Counters ─────────────────────────────────────
                const Text('TRAINING COUNTERS', style: _sectionLabel),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('SAMPLES SEEN', style: _dimLabel),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 44,
                            child: OdometerGauge(
                              controller: _samplesCtrl,
                              digitCount: 7,
                              decimalDigits: 0,
                              unit: 'smpl',
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('BATCHES', style: _dimLabel),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 44,
                            child: OdometerGauge(
                              controller: _batchCtrl,
                              digitCount: 5,
                              decimalDigits: 0,
                              unit: 'batch',
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper widgets ────────────────────────────────────────────────────────────

/// Arc gauge tile for model performance metrics.
class _MetricArc extends StatelessWidget {
  const _MetricArc({
    required this.ctrl,
    required this.label,
    required this.accentColor,
    required this.ranges,
    required this.style,
    required this.mode,
  });

  final GaugeController ctrl;
  final String label;
  final Color accentColor;
  final List<GaugeRange> ranges;
  final GaugeStyle style;
  final GaugeMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111320),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E2035)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: accentColor.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Expanded(
            // Override colorScheme.primary so each metric has its own colour
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(primary: accentColor),
              ),
              child: ListenableBuilder(
                listenable: ctrl,
                builder: (_, __) => ArcGauge(
                  controller: ctrl,
                  min: 0,
                  max: 100,
                  startAngleDeg: 150,
                  sweepAngleDeg: 240,
                  centerLabel: '${ctrl.value.toStringAsFixed(1)}%',
                  ranges: ranges,
                  style: style,
                  mode: mode,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Arc gauge tile for GPU/VRAM resources.
class _GpuArc extends StatelessWidget {
  const _GpuArc({
    required this.ctrl,
    required this.label,
    required this.style,
    required this.mode,
  });

  final GaugeController ctrl;
  final String label;
  final GaugeStyle style;
  final GaugeMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111320),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E2035)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4A4D6B),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: ctrl,
              builder: (_, __) => ArcGauge(
                controller: ctrl,
                min: 0,
                max: 100,
                startAngleDeg: 150,
                sweepAngleDeg: 240,
                centerLabel: '${ctrl.value.toStringAsFixed(0)}%',
                ranges: const [
                  GaugeRange(min: 85, max: 100, color: Color(0x88CC3311)),
                ],
                style: style,
                mode: mode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pipeline step dot (StatusGauge + label).
class _PipelineStep extends StatelessWidget {
  const _PipelineStep(this.label, this.ctrl, this.style, this.mode);

  final String label;
  final GaugeController ctrl;
  final GaugeStyle style;
  final GaugeMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: StatusGauge(
            controller: ctrl,
            radius: 10,
            style: style,
            mode: mode,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A4D6B),
            fontSize: 7,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
