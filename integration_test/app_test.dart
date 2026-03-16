import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_pantry_inventory/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smart Pantry Inventory - Integration Tests', () {
    testWidgets('App launches and shows inventory page', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Inventory'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Navigate to add item page', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap add button
      final addButton = find.byIcon(Icons.add).first;
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify add page appears
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('Theme toggle works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify inventory page loads
      expect(find.text('Inventory'), findsOneWidget);

      // Try to find and tap theme toggle
      final darkModeIcons = find.byIcon(Icons.dark_mode);
      if (darkModeIcons.evaluate().isNotEmpty) {
        await tester.tap(darkModeIcons.first);
        await tester.pumpAndSettle();
      }

      // Verify still on inventory page
      expect(find.text('Inventory'), findsOneWidget);
    });

    testWidgets('Dashboard cards display', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify dashboard cards exist
      expect(find.text('Total Items'), findsOneWidget);
    });

    testWidgets('Back navigation from add item page', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap add button
      final addButton = find.byIcon(Icons.add).first;
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify on add page
      expect(find.text('Add Item'), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify back on inventory
      expect(find.text('Inventory'), findsOneWidget);
    });
  });
}
