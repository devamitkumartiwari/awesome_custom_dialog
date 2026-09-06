import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "4. Custom Animation and Position" —
/// cycles three gravity/animation combinations (bottom+slideUp,
/// top+slideDown, center+bounce) for full coverage of both axes. Each
/// dialog carries its own visible "Close" button and is dismissed via that
/// button (never a blind barrier tap) so the previous dialog is always
/// fully torn down before the next one opens.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture custom animation and position', (tester) async {
    final capture = GifCapture(
      tester,
      'build/gif_frames/custom-animation-position',
    );
    await capture.setSize();

    ACDDialog showDialog(
      BuildContext context, {
      required ACDGravity gravity,
      required ACDAnimation animation,
      required String text,
      required EdgeInsets margin,
    }) {
      final dialog = ACDDialog().build(context)
        ..gravity = gravity
        ..animation = animation
        ..borderRadius = 20
        // Opaque barrier so the background buttons never peek through at
        // the dialog's edge — the default 30% barrier is intentionally
        // see-through, which read as a stray artifact with this layout
        // (confirmed: fully opaque removes it completely).
        ..barrierColor = Colors.black
        ..width = 320
        ..margin = margin
        ..text(
          text: text,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        )
        ..oneButton(
          text: 'Close',
          buttonPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        );
      dialog.show();
      return dialog;
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
                      onPressed: () => showDialog(
                        context,
                        gravity: ACDGravity.bottom,
                        animation: ACDAnimation.slideUp,
                        text: 'I slid up from the bottom!',
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      ),
                      child: const Text('Bottom · Slide Up'),
                    ),
                    OutlinedButton(
                      onPressed: () => showDialog(
                        context,
                        gravity: ACDGravity.top,
                        animation: ACDAnimation.slideDown,
                        text: 'I slid down from the top!',
                        margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      ),
                      child: const Text('Top · Slide Down'),
                    ),
                    OutlinedButton(
                      onPressed: () => showDialog(
                        context,
                        gravity: ACDGravity.center,
                        animation: ACDAnimation.bounce,
                        text: 'I bounced into the center!',
                        margin: EdgeInsets.zero,
                      ),
                      child: const Text('Center · Bounce'),
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

    for (final label in [
      'Bottom · Slide Up',
      'Top · Slide Down',
      'Center · Bounce',
    ]) {
      await tester.tap(find.text(label));
      for (int i = 0; i < 8; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 40));
      }
      await capture.hold(10);
      await tester.tap(find.text('Close'));
      // Let the exit transition fully finish before the next dialog opens —
      // a short hold here previously let dialogs stack instead of tearing
      // down cleanly.
      for (int i = 0; i < 8; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
      await capture.hold(4);
    }
  });
}
