// This is a basic Flutter widget test.
//
// This test has been updated for the Mass Ledger application.
//
// The original Flutter template tested a counter app using MyApp.
// Mass Ledger is a financial tracking application, so the original
// counter test is no longer applicable.

import 'package:flutter_test/flutter_test.dart';

import 'package:mass_ledger/main.dart';

void main() {
  testWidgets(
    'Mass Ledger application loads',
    (WidgetTester tester) async {
      // Build the Mass Ledger application and trigger a frame.
      await tester.pumpWidget(
        const MassLedgerApp(),
      );

      // Allow the application to finish building.
      await tester.pumpAndSettle();

      // Verify that the Mass Ledger login screen is displayed.
      expect(
        find.text('Mass Ledger'),
        findsOneWidget,
      );

      // Verify that the login screen contains the
      // welcome message.
      expect(
        find.text('Welcome back!'),
        findsOneWidget,
      );

      // Verify that the login button is displayed.
      expect(
        find.text('Login'),
        findsOneWidget,
      );
    },
  );
}