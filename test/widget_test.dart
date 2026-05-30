import 'package:flutter_test/flutter_test.dart';
import 'package:pos/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MasaPosApp());
    expect(find.text('AURA.POS'), findsOneWidget);
  });
}
