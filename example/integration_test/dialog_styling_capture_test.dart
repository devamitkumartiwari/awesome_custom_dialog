import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "18. Dialog Styling & Content Stagger" —
/// a rounded-superellipse gradient dialog and a sharp-cornered solid-color
/// dialog side by side, covering both the rounded and non-rounded corner
/// options plus `contentStagger` on both.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture dialog styling', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/dialog-styling');
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
                    ElevatedButton(
                      onPressed: () {
                        ACDDialog().build(context)
                          ..shape = const RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                          )
                          ..elevation = 16
                          ..backgroundGradient = const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          )
                          ..contentStagger = const ACDStaggerOptions(
                            interval: Duration(milliseconds: 90),
                          )
                          ..width = 300
                          ..text(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                            text: 'Rounded corners',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )
                          ..text(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                            text:
                                'shape: RoundedSuperellipseBorder\n'
                                '+ gradient + contentStagger',
                            color: Colors.white70,
                          )
                          ..oneButton(
                            text: 'Nice',
                            backgroundColor: Colors.white,
                            color: const Color(0xFF6A11CB),
                            buttonPadding: const EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              22,
                            ),
                          )
                          ..show();
                      },
                      child: const Text('Rounded'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ACDDialog().build(context)
                          ..borderRadius = 0
                          ..elevation = 10
                          ..backgroundColor = const Color(0xFF1B1F3B)
                          ..contentStagger = const ACDStaggerOptions(
                            interval: Duration(milliseconds: 90),
                          )
                          ..width = 300
                          ..text(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                            text: 'Square corners',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )
                          ..text(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                            text:
                                'borderRadius: 0, solid color\n'
                                '+ contentStagger',
                            color: Colors.white70,
                          )
                          ..oneButton(
                            text: 'Got it',
                            backgroundColor: Colors.white,
                            color: const Color(0xFF1B1F3B),
                            borderRadius: BorderRadius.zero,
                            buttonPadding: const EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              22,
                            ),
                          )
                          ..show();
                      },
                      child: const Text('Square'),
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

    for (final entry in [('Rounded', 'Nice'), ('Square', 'Got it')]) {
      await tester.tap(find.text(entry.$1));
      for (int i = 0; i < 16; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      await capture.hold(12);
      await tester.tap(find.text(entry.$2));
      // contentStagger means dismiss() plays a full staggered exit
      // (~580ms: 2 * 90ms interval + 400ms item duration) before the route
      // actually pops — a short buffer here previously left the dialog
      // still open (and its own barrier still blocking taps) when the next
      // button was tapped.
      for (int i = 0; i < 15; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
      await capture.hold(6);
    }
  });
}
