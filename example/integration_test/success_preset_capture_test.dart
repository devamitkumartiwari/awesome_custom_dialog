import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "1. Simple Success Preset" — cycles all
/// four ready-made presets (`success`/`error`/`warning`/`info`) for full
/// feature coverage in one GIF.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture success preset', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/success-preset');
    await capture.setSize();

    void showPreset(BuildContext context, String preset) {
      final dialog = ACDDialog().build(context)..animation = ACDAnimation.scale;
      switch (preset) {
        case 'success':
          dialog.success(
            title: 'Awesome!',
            message: 'This is a beautiful success dialog.',
          );
        case 'error':
          dialog.error(
            title: 'Oh no!',
            message: 'Something went wrong. Please retry.',
          );
        case 'warning':
          dialog.warning(
            title: 'Careful',
            message: 'This action can\'t be undone.',
          );
        case 'info':
          dialog.info(
            title: 'Did you know?',
            message: 'You can chain any content onto a dialog.',
          );
      }
      dialog.show();
    }

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
                    ElevatedButton(
                      onPressed: () => showPreset(context, 'success'),
                      child: const Text('Success'),
                    ),
                    OutlinedButton(
                      onPressed: () => showPreset(context, 'error'),
                      child: const Text('Error'),
                    ),
                    OutlinedButton(
                      onPressed: () => showPreset(context, 'warning'),
                      child: const Text('Warning'),
                    ),
                    OutlinedButton(
                      onPressed: () => showPreset(context, 'info'),
                      child: const Text('Info'),
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

    for (final label in ['Success', 'Error', 'Warning', 'Info']) {
      await tester.tap(find.text(label));
      for (int i = 0; i < 6; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
      await capture.hold(10);
      await tester.tap(find.text('OK'));
      // Give the exit transition a real margin over its 250ms duration
      // before the next preset opens — a tight buffer here previously let
      // dialogs stack instead of tearing down cleanly.
      for (int i = 0; i < 9; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
      await capture.hold(4);
    }
  });
}
