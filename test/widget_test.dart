import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHomeGuardian());
    expect(find.textContaining('GUARDIAN'), findsOneWidget);
  });
}