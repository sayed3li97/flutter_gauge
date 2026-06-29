import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class ServerDashboardScreen extends StatefulWidget {
  const ServerDashboardScreen({super.key});

  @override
  State<ServerDashboardScreen> createState() => _ServerDashboardScreenState();
}

class _ServerDashboardScreenState extends State<ServerDashboardScreen> {
  // CPU / GPU arcs (0–100%)
  final _cpu1Ctrl = GaugeController(initialValue: 45.0);
  final _cpu2Ctrl = GaugeController(initialValue: 38.0);
  final _memCtrl = GaugeController(initialValue: 72.0);
  final _gpuCtrl = GaugeController(initialValue: 55.0);

  // Disk usage (0–100%)
  final _diskDevCtrl = GaugeController(initialValue: 68.0);
  final _diskHomeCtrl = GaugeController(initialValue: 41.0);
  final _diskTmpCtrl = GaugeController(initialValue: 12.0);

  // Network tape gauges (Mbps)
  final _netDlCtrl = GaugeController(initialValue: 120.0);
  final _netUlCtrl = GaugeController(initialValue: 35.0);

  // Service status (0=ok, 1=warn, 2=danger)
  final _webStatusCtrl = GaugeController(initialValue: 0.0);
  final _dbStatusCtrl = GaugeController(initialValue: 0.0);
  final _cacheStatusCtrl = GaugeController(initialValue: 0.0);
  final _queueStatusCtrl = GaugeController(initialValue: 1.0);
  final _storageStatusCtrl = GaugeController(initialValue: 0.0);
  final _cdnStatusCtrl = GaugeController(initialValue: 0.0);

  // Uptime SLA bullet
  final _uptimeCtrl = GaugeController(initialValue: 99.94);

  Timer? _timer;
  final _rng = Random();
  double _phase = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _phase += 0.18;

      _cpu1Ctrl.value = (45.0 + 30.0 * sin(_phase * 0.9) + _rng.nextDouble() * 10).clamp(0, 100);
      _cpu2Ctrl.value = (38.0 + 35.0 * sin(_phase * 1.1 + 0.5) + _rng.nextDouble() * 8).clamp(0, 100);
      _memCtrl.value = (72.0 + 8.0 * sin(_phase * 0.4)).clamp(0, 100);
      _gpuCtrl.value = (55.0 + 25.0 * sin(_phase * 0.7) + _rng.nextDouble() * 12).clamp(0, 100);

      _diskDevCtrl.value = (68.0 + 0.5 * sin(_phase * 0.05)).clamp(0, 100);
      _diskHomeCtrl.value = (41.0 + 0.3 * sin(_phase * 0.03)).clamp(0, 100);
      _diskTmpCtrl.value = (12.0 + 4.0 * sin(_phase * 0.6)).clamp(0, 100);

      _netDlCtrl.value = (120.0 + 80.0 * sin(_phase * 1.2) + _rng.nextDouble() * 40).clamp(0, 1000);
      _netUlCtrl.value = (35.0 + 25.0 * sin(_phase * 0.8) + _rng.nextDouble() * 15).clamp(0, 1000);

      // Occasionally trigger queue warning
      _queueStatusCtrl.value = sin(_phase * 0.15) > 0.7 ? 2.0 : (sin(_phase * 0.15) > 0.3 ? 1.0 : 0.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cpu1Ctrl.dispose();
    _cpu2Ctrl.dispose();
    _memCtrl.dispose();
    _gpuCtrl.dispose();
    _diskDevCtrl.dispose();
    _diskHomeCtrl.dispose();
    _diskTmpCtrl.dispose();
    _netDlCtrl.dispose();
    _netUlCtrl.dispose();
    _webStatusCtrl.dispose();
    _dbStatusCtrl.dispose();
    _cacheStatusCtrl.dispose();
    _queueStatusCtrl.dispose();
    _storageStatusCtrl.dispose();
    _cdnStatusCtrl.dispose();
    _uptimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF121212);

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00CC88),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    const labelStyle = TextStyle(
      color: Color(0xFF00CC88),
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    );
    const dimLabel = TextStyle(
      color: Color(0xFF666666),
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    );
    const style = MaterialGaugeStyle();
    const mode = GaugeMode.instrument;

    return Theme(
      data: darkTheme,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SERVER MONITOR',
                          style: TextStyle(
                            color: Color(0xFF00CC88),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                          ),
                        ),
                        Text(
                          'prod-cluster-01  •  rack 4B',
                          style: TextStyle(color: Color(0xFF555555), fontSize: 11),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF00CC88)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ONLINE',
                        style: TextStyle(
                          color: Color(0xFF00CC88),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 2×2 CPU/Mem/GPU arcs ───────────────────────────────
                const Text('COMPUTE', style: labelStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _ArcTile(
                        ctrl: _cpu1Ctrl, label: 'CPU CORE 1',
                        style: style, mode: mode,
                      ),
                      _ArcTile(
                        ctrl: _cpu2Ctrl, label: 'CPU CORE 2',
                        style: style, mode: mode,
                      ),
                      _ArcTile(
                        ctrl: _memCtrl, label: 'MEMORY',
                        style: style, mode: mode,
                      ),
                      _ArcTile(
                        ctrl: _gpuCtrl, label: 'GPU',
                        style: style, mode: mode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Disk Usage ─────────────────────────────────────────
                const Text('DISK USAGE', style: labelStyle),
                const SizedBox(height: 8),
                _DiskRow(label: '/dev', ctrl: _diskDevCtrl, style: style, mode: mode),
                const SizedBox(height: 6),
                _DiskRow(label: '/home', ctrl: _diskHomeCtrl, style: style, mode: mode),
                const SizedBox(height: 6),
                _DiskRow(label: '/tmp', ctrl: _diskTmpCtrl, style: style, mode: mode),

                const SizedBox(height: 16),

                // ── Network ────────────────────────────────────────────
                const Text('NETWORK THROUGHPUT', style: labelStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('DOWNLOAD', style: dimLabel),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 60,
                            child: TapeGauge(
                              controller: _netDlCtrl,
                              min: 0,
                              max: 1000,
                              tickInterval: 100,
                              unit: 'Mbps',
                              vertical: false,
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
                          const Text('UPLOAD', style: dimLabel),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 60,
                            child: TapeGauge(
                              controller: _netUlCtrl,
                              min: 0,
                              max: 1000,
                              tickInterval: 100,
                              unit: 'Mbps',
                              vertical: false,
                              style: style,
                              mode: mode,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Service Health ─────────────────────────────────────
                const Text('SERVICE HEALTH', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ServiceStatus('WEB', _webStatusCtrl, style, mode),
                      _ServiceStatus('DB', _dbStatusCtrl, style, mode),
                      _ServiceStatus('CACHE', _cacheStatusCtrl, style, mode),
                      _ServiceStatus('QUEUE', _queueStatusCtrl, style, mode),
                      _ServiceStatus('STORAGE', _storageStatusCtrl, style, mode),
                      _ServiceStatus('CDN', _cdnStatusCtrl, style, mode),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Uptime SLA ─────────────────────────────────────────
                const Text('UPTIME SLA', style: labelStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: BulletGauge.kpi(
                    controller: _uptimeCtrl,
                    max: 100,
                    label: '30-day uptime %',
                    style: style,
                    mode: mode,
                  ),
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

class _ArcTile extends StatelessWidget {
  final GaugeController ctrl;
  final String label;
  final GaugeStyle style;
  final GaugeMode mode;

  const _ArcTile({
    required this.ctrl,
    required this.label,
    required this.style,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF555555),
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

class _DiskRow extends StatelessWidget {
  final String label;
  final GaugeController ctrl;
  final GaugeStyle style;
  final GaugeMode mode;

  const _DiskRow({
    required this.label,
    required this.ctrl,
    required this.style,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 32,
            child: LinearGauge.progress(
              controller: ctrl,
              min: 0,
              max: 100,
              style: style,
              mode: mode,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ListenableBuilder(
          listenable: ctrl,
          builder: (_, __) => SizedBox(
            width: 40,
            child: Text(
              '${ctrl.value.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Color(0xFF00CC88),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceStatus extends StatelessWidget {
  final String label;
  final GaugeController ctrl;
  final GaugeStyle style;
  final GaugeMode mode;

  const _ServiceStatus(this.label, this.ctrl, this.style, this.mode);

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
            color: Color(0xFF555555),
            fontSize: 8,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
