import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for the Toast section.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture toast', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/toast');
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
                    ACDDialog.toast(
                      context: context,
                      message: 'Changes saved successfully!',
                      showDuration: const Duration(seconds: 2),
                      showProgressBar: true,
                      contentType: ACDContentType.success,
                    ).show();
                  },
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.text('Show Toast'));
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    for (int i = 0; i < 20; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 100));
    }
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(6);
  });
}
