import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('DefaultGaugeStyle', () {
    testWidgets('resolves ambient tokens', (tester) async {
      late GaugeTokens tokens;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tokens = const DefaultGaugeStyle().resolve(context, GaugeMode.ambient);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tokens.trackStrokeWidth, 10);
      expect(tokens.trackStrokeCap, StrokeCap.round);
    });

    testWidgets('resolves instrument tokens', (tester) async {
      late GaugeTokens tokens;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tokens = const DefaultGaugeStyle().resolve(context, GaugeMode.instrument);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tokens.trackStrokeWidth, 6);
      expect(tokens.trackStrokeCap, StrokeCap.butt);
    });
  });

  group('MaterialGaugeStyle', () {
    testWidgets('resolves tokens from theme', (tester) async {
      late GaugeTokens tokens;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Builder(
            builder: (context) {
              tokens = const MaterialGaugeStyle().resolve(context, GaugeMode.ambient);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tokens.trackStrokeWidth, 10);
    });
  });

  group('ExecutiveGaugeStyle', () {
    testWidgets('resolves tokens without theme dependency', (tester) async {
      late GaugeTokens tokens;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tokens = const ExecutiveGaugeStyle().resolve(context, GaugeMode.ambient);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tokens.needleDropShadow, isTrue);
      expect(tokens.trackStrokeCap, StrokeCap.butt);
    });
  });

  group('GaugeThemeExtension', () {
    testWidgets('provides style via Theme', (tester) async {
      late GaugeThemeExtension? ext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [
              const GaugeThemeExtension(
                style: ExecutiveGaugeStyle(),
                defaultMode: GaugeMode.instrument,
              ),
            ],
          ),
          home: Builder(
            builder: (context) {
              ext = Theme.of(context).extension<GaugeThemeExtension>();
              return const SizedBox();
            },
          ),
        ),
      );
      expect(ext, isNotNull);
      expect(ext!.defaultMode, GaugeMode.instrument);
    });
  });
}
