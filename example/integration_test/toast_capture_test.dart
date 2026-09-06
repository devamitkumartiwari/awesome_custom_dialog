import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for the Toast section — cycles four
/// style/content-type combinations for full feature coverage in one GIF.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const List<({String label, ACDContentType type, ACDToastStyle style})>
  variants = [
    (
      label: 'Filled',
      type: ACDContentType.success,
      style: ACDToastStyle.filled,
    ),
    (label: 'Flat', type: ACDContentType.failure, style: ACDToastStyle.flat),
    (
      label: 'Flat Colored',
      type: ACDContentType.warning,
      style: ACDToastStyle.flatColored,
    ),
    (label: 'Minimal', type: ACDContentType.help, style: ACDToastStyle.minimal),
  ];

  testWidgets('capture toast', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/toast');
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
                    for (final v in variants)
                      OutlinedButton(
                        onPressed: () {
                          ACDDialog.toast(
                            context: context,
                            message: '${v.label} toast, ${v.type.name} type',
                            showDuration: const Duration(milliseconds: 1300),
                            showProgressBar: true,
                            contentType: v.type,
                            style: v.style,
                          ).show();
                        },
                        child: Text(v.label),
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

    for (final v in variants) {
      await tester.tap(find.text(v.label));
      for (int i = 0; i < 6; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      for (int i = 0; i < 12; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 100));
      }
      for (int i = 0; i < 6; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      await capture.hold(3);
    }
  });
}
