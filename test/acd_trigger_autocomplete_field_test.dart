import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  Future<List<Object?>> findMentions(String query) async =>
      ['alice', 'albert'].where((n) => n.startsWith(query)).toList();
  Future<List<Object?>> findHashtags(String query) async =>
      ['art', 'automation'].where((n) => n.startsWith(query)).toList();

  testWidgets('shows options for @ after a space', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDTriggerAutocompleteField(
          triggers: [
            ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findMentions),
          ],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'hi @al');
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('alice'), findsOneWidget);
    expect(find.text('albert'), findsOneWidget);
  });

  testWidgets('triggerOnlyAfterSpace blocks a mid-word trigger', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDTriggerAutocompleteField(
          triggers: [
            ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findMentions),
          ],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'hi@al');
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('alice'), findsNothing);
  });

  testWidgets('tapping an option inserts its text and a trailing space', (
    tester,
  ) async {
    Object? selected;
    await tester.pumpWidget(
      wrap(
        ACDTriggerAutocompleteField(
          triggers: [
            ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findMentions),
          ],
          onOptionSelected: (trigger, option) => selected = option,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '@al');
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('alice'));
    await tester.pump();

    expect(selected, 'alice');
    expect(find.text('alice '), findsOneWidget);
  });

  testWidgets('two distinct triggers do not cross-fire', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDTriggerAutocompleteField(
          triggers: [
            ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findMentions),
            ACDAutocompleteTrigger(trigger: '#', optionsBuilder: findHashtags),
          ],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '#ar');
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('art'), findsOneWidget);
    expect(find.text('alice'), findsNothing);
    expect(find.text('albert'), findsNothing);
  });

  testWidgets('itemStyle and popup customization apply to the option list', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDTriggerAutocompleteField(
          triggers: [
            ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findMentions),
          ],
          itemTextColor: Colors.red,
          popupElevation: 10,
          popupColor: Colors.yellow,
          popupBorderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '@al');
    await tester.pump(const Duration(milliseconds: 400));

    final Text label = tester.widget<Text>(find.text('alice'));
    expect(label.style?.color, Colors.red);

    final Material popup = tester
        .widgetList<Material>(find.byType(Material))
        .firstWhere((m) => m.elevation == 10);
    expect(popup.color, Colors.yellow);
    expect(
      (popup.borderRadius as BorderRadius?)?.topLeft,
      const Radius.circular(20),
    );
  });
}
