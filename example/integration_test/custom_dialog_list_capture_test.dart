import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "2. Custom Dialog with List".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture custom dialog with list', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/custom-dialog-list');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    ACDDialog().build(context)
                      ..width = 300
                      ..borderRadius = 12
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
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.text('Open Dialog'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);
    await tester.tap(find.text('Option 2'));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    await capture.hold(4);
  });
}
