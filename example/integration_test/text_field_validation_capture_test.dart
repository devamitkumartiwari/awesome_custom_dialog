import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "5. Text Field with Validation".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture text field with validation', (tester) async {
    final capture = GifCapture(
      tester,
      'build/gif_frames/text-field-validation',
    );
    await capture.setSize();

    final fieldKey = GlobalKey<FormFieldState<String>>();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    final dialog = ACDDialog().build(context)
                      ..width = 300
                      ..borderRadius = 12
                      ..acdTextField(
                        hint: 'Enter your full name',
                        fieldKey: fieldKey,
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      );
                    dialog
                      ..oneButton(
                        text: 'Submit',
                        isClickAutoDismiss: false,
                        buttonPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        onTap: () {
                          if (fieldKey.currentState?.validate() ?? false) {
                            dialog.dismiss();
                          }
                        },
                      )
                      ..show();
                  },
                  child: const Text('Open Form'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.text('Open Form'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    // Tap Submit with an empty field to show the validation error.
    await tester.tap(find.text('Submit'));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    await capture.hold(8);

    // Now fill it in and submit successfully.
    await tester.enterText(find.byType(TextFormField), 'Ada Lovelace');
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    await capture.hold(4);
    await tester.tap(find.text('Submit'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);
  });
}
