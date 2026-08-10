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

    await tester.pumpAndSettle();

    expect(find.byType(RespiraCareApp), findsOneWidget);
  });
}