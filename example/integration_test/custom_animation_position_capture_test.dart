import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "4. Custom Animation and Position".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture custom animation and position', (tester) async {
    final capture = GifCapture(
      tester,
      'build/gif_frames/custom-animation-position',
    );
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
                      ..gravity = ACDGravity.bottom
                      ..animation = ACDAnimation.slideUp
                      ..borderRadius = 20
                      ..width = 320
                      ..margin = const EdgeInsets.fromLTRB(20, 0, 20, 40)
                      ..text(
                        text: 'I slid up from the bottom!',
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      )
                      ..show();
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.text('Show Dialog'));
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 40));
    }
    await capture.hold(14);
  });
}
