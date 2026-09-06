import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "16. Pin / OTP Field".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture pin field', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/pin-field');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Center(child: ACDPinField(length: 6, onCompleted: (_) {})),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.byType(ACDPinField));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));

    const String pin = '123456';
    for (int i = 1; i <= pin.length; i++) {
      await tester.enterText(find.byType(TextField), pin.substring(0, i));
      for (int f = 0; f < 3; f++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
    }
    await capture.hold(10);
  });
}
