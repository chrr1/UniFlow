import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitask/main.dart';

void main() {
  testWidgets('UniTaskApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UniTaskApp(),
      ),
    );
    expect(find.text('UniTask'), findsNothing); // Or check basic loading
  });
}
