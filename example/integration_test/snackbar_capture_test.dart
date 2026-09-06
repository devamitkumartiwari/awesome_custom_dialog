import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for the Snackbar section — cycles all four
/// `ACDContentType` looks for full coverage.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const List<(String, ACDContentType, String)> variants = [
    ('Success', ACDContentType.success, 'Your changes have been saved.'),
    ('Failure', ACDContentType.failure, 'This is an example error message.'),
    ('Warning', ACDContentType.warning, 'Your session is about to expire.'),
    ('Help', ACDContentType.help, 'Tap the icon for more information.'),
  ];

  testWidgets('capture snackbar', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/snackbar');
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
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                duration: const Duration(milliseconds: 1400),
                                content: ACDSnackbarContent(
                                  title: v.$1,
                                  message: v.$3,
                                  contentType: v.$2,
                                ),
                              ),
                            );
                        },
                        child: Text(v.$1),
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
      await tester.tap(find.text(v.$1).last);
      for (int i = 0; i < 8; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      for (int i = 0; i < 10; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 100));
      }
      for (int i = 0; i < 6; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      await capture.hold(3);
    }
  });
}
