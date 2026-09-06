import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "8. Autocomplete" — the standalone
/// `ACDAutocompleteField` and the multi-trigger `ACDTriggerAutocompleteField`
/// (`@`-mention style), for full coverage of both field types.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const List<String> countries = ['Canada', 'France', 'Germany', 'India'];
  const List<String> users = ['alice', 'ben', 'carla'];

  testWidgets('capture autocomplete', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/autocomplete');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ACDAutocompleteField<String>(
                    suggestions: countries,
                    decoration: const InputDecoration(labelText: 'Country'),
                    onSuggestionSelected: (_) {},
                  ),
                  const SizedBox(height: 28),
                  ACDTriggerAutocompleteField(
                    decoration: const InputDecoration(labelText: 'Message'),
                    triggers: [
                      ACDAutocompleteTrigger(
                        trigger: '@',
                        optionsBuilder: (query) async => users
                            .where((u) => u.startsWith(query.toLowerCase()))
                            .toList(),
                      ),
                    ],
                    onOptionSelected: (_, _) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);

    // Standalone autocomplete field.
    await tester.tap(find.byType(ACDAutocompleteField<String>));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await tester.enterText(
      find.descendant(
        of: find.byType(ACDAutocompleteField<String>),
        matching: find.byType(TextField),
      ),
      'ca',
    );
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(6);
    await tester.tap(find.text('Canada'));
    for (int i = 0; i < 4; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);

    // @-mention trigger field.
    await tester.tap(find.byType(ACDTriggerAutocompleteField));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await tester.enterText(
      find.descendant(
        of: find.byType(ACDTriggerAutocompleteField),
        matching: find.byType(TextField),
      ),
      'Hey @b',
    );
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(8);
    await tester.tap(find.text('ben'));
    for (int i = 0; i < 4; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(6);
  });
}
