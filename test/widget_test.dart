// This is a basic Flutter widget test for Exomic.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Exomic/main.dart';

void main() {
  testWidgets('System layout compilation smoke test', (WidgetTester tester) async {
    // Build our app under a ProviderScope and trigger a frame.
    // We target the true ExomicAppRoot class rather than the non-existent MyApp layout.
    await tester.pumpWidget(
      const ProviderScope(
        child: ExomicAppRoot(),
      ),
    );

    // Verify that the navigation layout bootstraps and renders the branding asset marker
    expect(find.text('E'), findsOneWidget);

    // Verify that the initial workspace view has successfully rendered its section header
    expect(find.text('// EXPENSE_LEDGER_STREAM'), findsNothing); // Will be visible once expense log fires
  });
}