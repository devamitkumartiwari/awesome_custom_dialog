import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  const suggestions = ['Alpha', 'Beta', 'Gamma'];

  testWidgets(
    'ACDAutocompleteField shows suggestions past minCharsForSuggestions',
    (tester) async {
      await tester.pumpWidget(
        wrap(const ACDAutocompleteField<String>(suggestions: suggestions)),
      );

      await tester.enterText(find.byType(TextField), 'al');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing); // no 'al' in "Beta"
      expect(find.text('Gamma'), findsNothing); // no 'al' in "Gamma"
    },
  );

  testWidgets('ACDAutocompleteField respects a custom filterFn', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDAutocompleteField<String>(
          suggestions: suggestions,
          filterFn: (item, query) => item.startsWith(query),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'B');
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('tapping a suggestion selects it and clears on submit', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      wrap(
        ACDAutocompleteField<String>(
          suggestions: suggestions,
          clearOnSubmit: true,
          onSuggestionSelected: (v) => picked = v,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Alpha'));
    await tester.pump();

    expect(picked, 'Alpha');
    expect(find.text('Alpha'), findsNothing); // cleared after submit
  });

  testWidgets('programmatic controller.clear() hides the overlay', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      wrap(
        ACDAutocompleteField<String>(
          suggestions: suggestions,
          controller: controller,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Alpha'), findsOneWidget);

    controller.clear();
    await tester.pump();

    expect(find.text('Alpha'), findsNothing);
  });
}
