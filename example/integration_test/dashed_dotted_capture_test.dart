import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "10. Dashed and Dotted Decoration" —
/// covers a square-corner border, a rounded-corner border, a dotted box,
/// and a dashed oval, so both the rounded and non-rounded corner options
/// are shown side by side. These are static decorations (no built-in
/// animation), so entrance is via a staggered fade/scale reveal for a bit
/// of motion in the GIF.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture dashed and dotted decoration', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/dashed-dotted');
    await capture.setSize();

    Widget tile(String label) => Padding(
      padding: const EdgeInsets.all(14),
      child: Text(label, textAlign: TextAlign.center),
    );

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
                  ACDMotion(
                    effect: ACDMotionEffect.fadeSlideIn(),
                    child: const ACDDashedLine(
                      length: 220,
                      color: Colors.grey,
                      dashLength: 6,
                      gapLength: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ACDMotion(
                        delay: const Duration(milliseconds: 150),
                        effect: ACDMotionEffect.scaleIn,
                        child: ACDDashedBorder(
                          shape: ACDDashedBorderShape.rect,
                          child: tile('Square\ncorners'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ACDMotion(
                        delay: const Duration(milliseconds: 300),
                        effect: ACDMotionEffect.scaleIn,
                        child: ACDDashedBorder(
                          shape: ACDDashedBorderShape.roundedRect,
                          child: tile('Rounded\ncorners'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ACDMotion(
                        delay: const Duration(milliseconds: 450),
                        effect: ACDMotionEffect.scaleIn,
                        child: Container(
                          decoration: const ACDDottedDecoration(
                            shape: ACDDottedShape.box,
                          ),
                          child: tile('Dotted\nbox'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ACDMotion(
                        delay: const Duration(milliseconds: 600),
                        effect: ACDMotionEffect.scaleIn,
                        child: ACDDashedBorder(
                          shape: ACDDashedBorderShape.oval,
                          child: tile('Dashed\noval'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < 18; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(12);
  });
}
