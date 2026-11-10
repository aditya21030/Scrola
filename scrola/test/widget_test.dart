import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ScrolaApp());
    expect(find.text('REELS TODAY'), findsOneWidget);
  });
}
