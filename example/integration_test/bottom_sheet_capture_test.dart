import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for the bottom sheet: it slides up, then is
/// dragged down to close.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture bottom sheet', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/bottom-sheet');
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
                child: ElevatedButton(
                  onPressed: () {
                    ACDDialog.bottomSheet(context: context)
                      ..text(
                        text: 'Share to',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                      )
                      ..actions(const [
                        ACDAction(label: 'Mail', value: 'mail'),
                        ACDAction(label: 'Messages', value: 'messages'),
                        ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
                      ])
                      ..show();
                  },
                  child: const Text('Share'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await capture.hold(4);
    await tester.tap(find.text('Share'));
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 40));
    }
    await capture.hold(10);

    // Drag the sheet down by its title, a little each frame.
    final TestGesture drag = await tester.startGesture(
      tester.getCenter(find.text('Share to')),
    );
    for (int i = 0; i < 10; i++) {
      await drag.moveBy(const Offset(0, 22));
      await capture.pumpAndCapture(const Duration(milliseconds: 30));
    }
    await drag.up();
    for (int i = 0; i < 10; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 40));
    }
    await capture.hold(6);
  });
}
