import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Phase 2: every field widget renders Material by default, Cupertino on
/// request, and adaptively — and never crashes inside a bare CupertinoApp.
void main() {
  Widget cupertinoApp(Widget child) => CupertinoApp(
    home: CupertinoPageScaffold(child: Center(child: child)),
  );
  Widget materialApp(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  const List<String> fruits = ['Apple', 'Banana', 'Cherry'];

  for (final ACDDesign design in [ACDDesign.cupertino, ACDDesign.adaptive]) {
    group('bare CupertinoApp, design: ${design.name}', () {
      testWidgets('ACDPinField', (tester) async {
        await tester.pumpWidget(
          cupertinoApp(ACDPinField(length: 4, design: design)),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(CupertinoTextField), findsOneWidget);
        expect(find.byType(TextField), findsNothing);

        await tester.enterText(find.byType(EditableText), '12');
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('ACDAutocompleteField', (tester) async {
        await tester.pumpWidget(
          cupertinoApp(
            SizedBox(
              width: 300,
              child: ACDAutocompleteField<String>(
                suggestions: fruits,
                design: design,
              ),
            ),
          ),
        );
        expect(find.byType(CupertinoTextField), findsOneWidget);
        await tester.enterText(find.byType(EditableText), 'an');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.byType(CupertinoListTile), findsOneWidget);
      });

      testWidgets('ACDTriggerAutocompleteField', (tester) async {
        await tester.pumpWidget(
          cupertinoApp(
            SizedBox(
              width: 300,
              child: ACDTriggerAutocompleteField(
                design: design,
                triggers: [
                  ACDAutocompleteTrigger(
                    trigger: '@',
                    optionsBuilder: (q) async =>
                        fruits.where((f) => f.contains(q)).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(EditableText), '@Ch');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Cherry'), findsOneWidget);
      });

      testWidgets('ACDDropdownField (dialog mode)', (tester) async {
        String? picked;
        await tester.pumpWidget(
          cupertinoApp(
            SizedBox(
              width: 300,
              child: ACDDropdownField<String>(
                design: design,
                items: fruits,
                decoration: const InputDecoration(labelText: 'Fruit'),
                onChanged: (v) => picked = v,
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(InputDecorator), findsNothing);

        await tester.tap(find.text('Fruit'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(CupertinoSearchTextField), findsOneWidget);

        await tester.tap(find.text('Cherry'));
        await tester.pumpAndSettle();
        expect(picked, 'Cherry');
      });

      testWidgets('ACDDropdownField (menu mode) opens an anchored popover', (
        tester,
      ) async {
        await tester.pumpWidget(
          cupertinoApp(
            SizedBox(
              width: 300,
              child: ACDDropdownField<String>(
                design: design,
                mode: ACDDropdownMode.menu,
                items: fruits,
                decoration: const InputDecoration(labelText: 'Fruit'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Fruit'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Banana'), findsOneWidget);

        await tester.tap(find.text('Banana'));
        await tester.pumpAndSettle();
        expect(find.text('Banana'), findsOneWidget); // now the field value
        expect(find.byType(CupertinoSearchTextField), findsNothing);
      });

      testWidgets('ACDMultiDropdownField', (tester) async {
        List<String>? picked;
        await tester.pumpWidget(
          cupertinoApp(
            SizedBox(
              width: 300,
              child: ACDMultiDropdownField<String>(
                design: design,
                items: fruits,
                decoration: const InputDecoration(labelText: 'Fruits'),
                onChanged: (v) => picked = v,
              ),
            ),
          ),
        );
        await tester.tap(find.text('Fruits'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoCheckbox), findsNWidgets(3));
        await tester.tap(find.text('Apple'));
        await tester.tap(find.text('Cherry'));
        await tester.pump();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(picked, ['Apple', 'Cherry']);
      });
    });
  }

  group('Material stays the default', () {
    testWidgets('fields render Material primitives with no design set', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          Column(
            children: [
              ACDPinField(length: 4),
              const SizedBox(
                width: 300,
                child: ACDAutocompleteField<String>(suggestions: fruits),
              ),
              SizedBox(
                width: 300,
                child: ACDDropdownField<String>(items: fruits),
              ),
            ],
          ),
        ),
      );
      expect(find.byType(CupertinoTextField), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(InputDecorator), findsNWidgets(3));
    });

    testWidgets('ACDDesignScope switches every field at once', (tester) async {
      await tester.pumpWidget(
        ACDDesignScope(
          design: ACDDesign.cupertino,
          child: materialApp(
            Column(
              children: [
                ACDPinField(length: 4),
                const SizedBox(
                  width: 300,
                  child: ACDAutocompleteField<String>(suggestions: fruits),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CupertinoTextField), findsNWidgets(2));
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('UX', () {
    testWidgets('autocomplete: arrow keys + Enter pick a suggestion', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 300,
            child: ACDAutocompleteField<String>(
              suggestions: fruits,
              minCharsForSuggestions: 0,
              onSuggestionSelected: (v) => picked = v,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget); // opens on focus

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, 'Banana');
    });

    testWidgets('autocomplete: Escape closes the popup', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const SizedBox(
            width: 300,
            child: ACDAutocompleteField<String>(suggestions: fruits),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('dropdown: focus + Enter opens the popup', (tester) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(width: 300, child: ACDDropdownField<String>(items: fruits)),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('dropdown keeps the caller\'s errorText', (tester) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 300,
            child: ACDDropdownField<String>(
              items: fruits,
              decoration: const InputDecoration(errorText: 'Required'),
            ),
          ),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('PIN field is one labelled field for screen readers', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        materialApp(ACDPinField(length: 4, initialValue: '12')),
      );
      expect(
        find.bySemanticsLabel(RegExp(r'PIN, 2 of 4 entered')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
