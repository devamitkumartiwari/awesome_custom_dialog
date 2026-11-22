import 'dart:async';

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for async feedback: a loading dialog, then a
/// promise toast turning into "Saved", then an undo toast being undone.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture async feedback', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/async-feedback');
    await capture.setSize();

    final Completer<void> signIn = Completer<void>();
    final Completer<void> save = Completer<void>();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Builder(
              builder: (context) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () => ACDDialog.loading(
                        context: context,
                        future: signIn.future,
                        message: 'Signing in…',
                        minDisplay: Duration.zero,
                      ),
                      child: const Text('Loading dialog'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ACDDialog.promiseToast<void>(
                        context: context,
                        future: save.future,
                        loading: 'Saving note…',
                        success: (_) => 'Note saved',
                        error: (_) => 'Could not save',
                        resultDuration: const Duration(milliseconds: 1200),
                      ),
                      child: const Text('Promise toast'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ACDDialog.undoToast(
                        context: context,
                        message: 'Message deleted',
                        duration: const Duration(seconds: 3),
                      ),
                      child: const Text('Undo toast'),
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
    await capture.hold(3);

    // Loading dialog: spinner for a moment, then the work completes.
    await tester.tap(find.text('Loading dialog'));
    for (int i = 0; i < 14; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    signIn.complete();
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }

    // Promise toast: Saving… → Note saved, in the same toast.
    await tester.tap(find.text('Promise toast'));
    for (int i = 0; i < 14; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    save.complete();
    for (int i = 0; i < 16; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }

    // Undo toast: the countdown runs, then Undo is tapped.
    await tester.tap(find.text('Undo toast'));
    for (int i = 0; i < 14; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 80));
    }
    await tester.tap(find.text('Undo'));
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }
    await capture.hold(4);
  });
}
