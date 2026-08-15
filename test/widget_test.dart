import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/app/app.dart';

void main() {
  testWidgets('RespiraCare app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RespiraCareApp(),
      ),
    );

    // The splash screen features a repeating breathing animation, so
    // pumpAndSettle would never settle. Use fixed pumps instead.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1300));

    expect(find.byType(RespiraCareApp), findsOneWidget);
  });
}
