import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "10. Dashed and Dotted Decoration". These
/// are static decorations (no built-in animation), so entrance is via a
/// staggered fade/scale reveal for a bit of motion in the GIF.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture dashed and dotted decoration', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/dashed-dotted');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ACDMotion(
                    effect: ACDMotionEffect.fadeSlideIn(),
                    child: const ACDDashedLine(
                      length: 200,
                      color: Colors.grey,
                      dashLength: 6,
                      gapLength: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ACDMotion(
                    delay: const Duration(milliseconds: 200),
                    effect: ACDMotionEffect.scaleIn,
                    child: Container(
                      decoration: const ACDDottedDecoration(
                        shape: ACDDottedShape.box,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Dotted box'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const ACDMotion(
                    delay: Duration(milliseconds: 400),
                    effect: ACDMotionEffect.scaleIn,
                    child: ACDDashedBorder(
                      shape: ACDDashedBorderShape.roundedRect,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Drop file here'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < 14; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(10);
  });
}
