import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "9. Slide to Confirm".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture slide to confirm', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/slide-to-confirm');
    await capture.setSize();

    final controller = ACDSlideActionController();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ACDSlideAction.swipeButton(
                  controller: controller,
                  label: 'Swipe to pay',
                  onConfirm: () async {
                    controller.loading();
                    await Future<void>.delayed(
                      const Duration(milliseconds: 500),
                    );
                    controller.success();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(ACDSlideAction)),
    );
    for (int i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(28, 0));
      await capture.pumpAndCapture(const Duration(milliseconds: 40));
    }
    await gesture.up();
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 80));
    }
    for (int i = 0; i < 10; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 100));
    }
    await capture.hold(8);
  });
}
