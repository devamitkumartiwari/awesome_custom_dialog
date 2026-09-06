import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "8. Autocomplete".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const List<String> countries = ['Canada', 'France', 'Germany', 'India'];

  testWidgets('capture autocomplete', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/autocomplete');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 200,
              ),
              child: ACDAutocompleteField<String>(
                suggestions: countries,
                decoration: const InputDecoration(labelText: 'Country'),
                onSuggestionSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.byType(ACDAutocompleteField<String>));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await tester.enterText(find.byType(TextField), 'ca');
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(8);
    await tester.tap(find.text('Canada'));
    for (int i = 0; i < 4; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(6);
  });
}
