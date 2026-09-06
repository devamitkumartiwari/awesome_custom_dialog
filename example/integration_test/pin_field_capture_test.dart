import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "16. Pin / OTP Field" — square-corner
/// cells with a scale-in animation and circular cells with a fade-in
/// animation, for rounded-vs-non-rounded and `pinAnimationType` coverage.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture pin field', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/pin-field');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ACDPinField(
                    key: const ValueKey('square'),
                    length: 4,
                    pinAnimationType: ACDPinAnimationType.scale,
                    pinTheme: const ACDPinTheme(
                      width: 48,
                      height: 52,
                      borderRadius: BorderRadius.zero,
                    ),
                    onCompleted: (_) {},
                  ),
                  const SizedBox(height: 36),
                  ACDPinField(
                    key: const ValueKey('circle'),
                    length: 4,
                    pinAnimationType: ACDPinAnimationType.fade,
                    obscureText: true,
                    pinTheme: const ACDPinTheme(
                      width: 48,
                      height: 48,
                      shape: BoxShape.circle,
                    ),
                    onCompleted: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.byKey(const ValueKey('square')));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));

    const String pin = '1234';
    final Finder squareField = find.descendant(
      of: find.byKey(const ValueKey('square')),
      matching: find.byType(TextField),
    );
    for (int i = 1; i <= pin.length; i++) {
      await tester.enterText(squareField, pin.substring(0, i));
      for (int f = 0; f < 3; f++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
    }
    await capture.hold(8);

    await tester.tap(find.byKey(const ValueKey('circle')));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    final Finder circleField = find.descendant(
      of: find.byKey(const ValueKey('circle')),
      matching: find.byType(TextField),
    );
    for (int i = 1; i <= pin.length; i++) {
      await tester.enterText(circleField, pin.substring(0, i));
      for (int f = 0; f < 3; f++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
    }
    await capture.hold(10);
  });
}
