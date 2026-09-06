import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "9. Slide to Confirm" — shows the
/// rounded `swipeButton` preset (pill shape, start-to-end) alongside a
/// sharp-cornered base `ACDSlideAction` (square corners, end-to-start,
/// `.circle` thumb) for rounded-vs-non-rounded and direction coverage.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture slide to confirm', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/slide-to-confirm');
    await capture.setSize();

    final roundedController = ACDSlideActionController();
    final squareController = ACDSlideActionController();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ACDSlideAction.swipeButton(
                      key: const ValueKey('rounded'),
                      controller: roundedController,
                      borderRadius: const BorderRadius.all(Radius.circular(28)),
                      label: 'Swipe to pay',
                      onConfirm: () async {
                        roundedController.loading();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 400),
                        );
                        roundedController.success();
                      },
                    ),
                    const SizedBox(height: 24),
                    ACDSlideAction(
                      key: const ValueKey('square'),
                      controller: squareController,
                      shape: ACDSlideActionShape.rectangle,
                      direction: ACDSlideActionDirection.endToStart,
                      borderRadius: BorderRadius.zero,
                      thumbBorderRadius: BorderRadius.zero,
                      activeTrackColor: const Color(0xFFFFE0B2),
                      inactiveTrackColor: const Color(0xFFF5F5F5),
                      activeThumbColor: const Color(0xFFEF6C00),
                      thumbIcon: Icons.arrow_back,
                      label: 'Swipe to cancel',
                      onConfirm: () async {
                        squareController.loading();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 400),
                        );
                        squareController.success();
                      },
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

    // Rounded (pill), start-to-end.
    final Finder roundedFinder = find.byKey(const ValueKey('rounded'));
    TestGesture gesture = await tester.startGesture(
      tester.getCenter(roundedFinder),
    );
    for (int i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(32, 0));
      await capture.pumpAndCapture(const Duration(milliseconds: 40));
    }
    await gesture.up();
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 80));
    }
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 100));
    }
    await capture.hold(6);

    // Sharp corners, end-to-start.
    final Finder squareFinder = find.byKey(const ValueKey('square'));
    gesture = await tester.startGesture(tester.getCenter(squareFinder));
    for (int i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(-32, 0));
      await capture.pumpAndCapture(const Duration(milliseconds: 40));
    }
    await gesture.up();
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 80));
    }
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 100));
    }
    await capture.hold(8);
  });
}
