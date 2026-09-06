import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "2. Custom Dialog with List" — cycles
/// all three list-item types (`listOfACDListTile`/`listOfACDRadioButton`/
/// `listOfACDCheckbox`), alternating rounded and square dialog corners for
/// full coverage.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture custom dialog with list', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/custom-dialog-list');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Builder(
              builder: (context) => Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ACDDialog().build(context)
                          ..width = 300
                          ..borderRadius = 16
                          ..text(
                            text: 'Choose an option',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )
                          ..acdDivider()
                          ..listOfACDListTile(
                            items: const [
                              ACDListTileItem(
                                text: 'Option 1',
                                leading: Icon(Icons.star),
                              ),
                              ACDListTileItem(
                                text: 'Option 2',
                                leading: Icon(Icons.settings),
                              ),
                              ACDListTileItem(
                                text: 'Option 3',
                                leading: Icon(Icons.info),
                              ),
                            ],
                          )
                          ..show();
                      },
                      child: const Text('List Tiles'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ACDDialog().build(context)
                          ..width = 300
                          ..borderRadius = 0
                          ..text(
                            text: 'Pick one',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )
                          ..acdDivider()
                          ..listOfACDRadioButton(
                            items: const [
                              ACDRadioItem(text: 'Small'),
                              ACDRadioItem(text: 'Medium'),
                              ACDRadioItem(text: 'Large'),
                            ],
                          )
                          ..oneButton(
                            text: 'Done',
                            buttonPadding: const EdgeInsets.fromLTRB(
                              20,
                              8,
                              20,
                              20,
                            ),
                          )
                          ..show();
                      },
                      child: const Text('Radio (square)'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ACDDialog().build(context)
                          ..width = 300
                          ..borderRadius = 16
                          ..text(
                            text: 'Pick many',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )
                          ..acdDivider()
                          ..listOfACDCheckbox(
                            items: const [
                              ACDCheckboxItem(text: 'Wifi'),
                              ACDCheckboxItem(text: 'Bluetooth'),
                              ACDCheckboxItem(text: 'Location'),
                            ],
                          )
                          ..oneButton(
                            text: 'Apply',
                            buttonPadding: const EdgeInsets.fromLTRB(
                              20,
                              8,
                              20,
                              20,
                            ),
                          )
                          ..show();
                      },
                      child: const Text('Checkboxes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);

    // List tiles (rounded), tap-to-dismiss.
    await tester.tap(find.text('List Tiles'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(10);
    await tester.tap(find.text('Option 2'));
    // Let the (unanimated) dismiss fully settle before opening the next
    // dialog — too short a gap here previously let dialogs stack instead
    // of tearing down cleanly.
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }
    await capture.hold(4);

    // Radio buttons (square corners).
    await tester.tap(find.text('Radio (square)'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(6);
    await tester.tap(find.text('Medium'));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await capture.hold(6);
    await tester.tap(find.text('Done'));
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }
    await capture.hold(4);

    // Checkboxes (rounded), multi-select.
    await tester.tap(find.text('Checkboxes'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);
    await tester.tap(find.text('Wifi'));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await tester.tap(find.text('Location'));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await capture.hold(8);
    await tester.tap(find.text('Apply'));
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }
    await capture.hold(6);
  });
}
