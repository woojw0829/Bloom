import 'package:bloom/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BloomApp renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BloomApp()));
    expect(find.byType(BloomApp), findsOneWidget);
  });
}
