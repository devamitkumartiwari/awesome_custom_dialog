import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for the form-field wrappers: validate shows
/// the errors, then filling the switch, rating and autocomplete clears them.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture form fields', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/form-fields');
    await capture.setSize();
    final GlobalKey<FormState> form = GlobalKey<FormState>();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ACDAutocompleteFormField<String>(
                        suggestions: const ['France', 'Finland', 'Fiji'],
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                        ),
                        validator: (c) =>
                            c == null ? 'Pick a country from the list' : null,
                      ),
                      const SizedBox(height: 20),
                      ACDRatingFormField(
                        validator: (r) =>
                            (r ?? 0) == 0 ? 'Please rate your stay' : null,
                      ),
                      const SizedBox(height: 16),
                      ACDSwitchFormField(
                        title: const Text('I accept the terms'),
                        validator: (on) =>
                            on == true ? null : 'Please accept to continue',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => form.currentState!.validate(),
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await capture.hold(4);

    await tester.tap(find.text('Submit'));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    await capture.hold(8);

    await tester.enterText(find.byType(TextField), 'Fr');
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await tester.tap(find.text('France').last);
    for (int i = 0; i < 4; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }

    final Rect stars = tester.getRect(find.byType(ACDRatingBar));
    await tester.tapAt(
      Offset(stars.left + stars.width * 0.75, stars.center.dy),
    );
    for (int i = 0; i < 4; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }

    await tester.tap(find.byType(ACDSwitch));
    for (int i = 0; i < 5; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }

    await tester.tap(find.text('Submit'));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    await capture.hold(10);
  });
}
