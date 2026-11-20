import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
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

  testWidgets(
    'picking a suggestion does not call onFind again with the picked value '
    '(regression: writing it into the field re-ran the search)',
    (tester) async {
      final List<String> queries = <String>[];
      await tester.pumpWidget(
        wrap(
          ACDAutocompleteField<String>(
            suggestions: const <String>[],
            onFind: (q) async {
              queries.add(q);
              return suggestions.where((s) => s.contains(q)).toList();
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Al');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alpha'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(queries, ['Al']);
    },
  );

  testWidgets('moving the caret does not reopen the popup or re-search '
      '(regression: selection-only changes were treated as new queries)', (
    tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);
    int finds = 0;
    await tester.pumpWidget(
      wrap(
        ACDAutocompleteField<String>(
          suggestions: const <String>[],
          controller: controller,
          onFind: (q) async {
            finds++;
            return suggestions;
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(finds, 1);

    controller.selection = const TextSelection.collapsed(offset: 0);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(finds, 1);
  });

  testWidgets('swapping the controller re-wires the field to the new one', (
    tester,
  ) async {
    final TextEditingController a = TextEditingController();
    final TextEditingController b = TextEditingController();
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    Widget build(TextEditingController c) => wrap(
      ACDAutocompleteField<String>(controller: c, suggestions: suggestions),
    );

    await tester.pumpWidget(build(a));
    await tester.pumpWidget(build(b));
    b.text = 'Gam';
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Gamma'), findsOneWidget);
  });
}
