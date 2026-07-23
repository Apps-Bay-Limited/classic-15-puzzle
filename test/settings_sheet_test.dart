import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    required int currentGridSize,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => SettingsPage(
                        currentGridSize: currentGridSize,
                        onGridSizeSelected: (_) {},
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens as a route with a back button that pops it',
      (tester) async {
    await pumpPage(tester, currentGridSize: 3);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('does not show an About row', (tester) async {
    await pumpPage(tester, currentGridSize: 3);

    expect(find.text('About'), findsNothing);
  });

  testWidgets('marks only the current grid size as selected', (tester) async {
    await pumpPage(tester, currentGridSize: 4);

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    expect(find.bySemanticsLabel('4x4 grid, selected'), findsOneWidget);
    expect(find.bySemanticsLabel('3x3 grid'), findsOneWidget);
    expect(find.bySemanticsLabel('5x5 grid'), findsOneWidget);
  });
}
