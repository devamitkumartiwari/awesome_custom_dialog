import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "1. Simple Success Preset".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture success preset', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/success-preset');
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
                      ..success(
                        title: 'Awesome!',
                        message: 'This is a beautiful success dialog.',
                      )
                      ..show();
                  },
                  child: const Text('Show Success'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.text('Show Success'));
    await capture.pumpAndCapture(const Duration(milliseconds: 50));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    await capture.pumpAndCapture(const Duration(milliseconds: 150));
    await capture.hold(18);

    await tester.tap(find.text('OK'));
    await capture.pumpAndCapture(const Duration(milliseconds: 100));
    await capture.pumpAndCapture(const Duration(milliseconds: 150));
    await capture.hold(6);
  });
}
