import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit_example/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const GaugeKitExampleApp());
    expect(find.byType(GaugeKitExampleApp), findsOneWidget);
  });
}
