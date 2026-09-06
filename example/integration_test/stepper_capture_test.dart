import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "11. Stepper" — the horizontal wizard bar
/// and the vertical timeline layout, with `stepShape.roundedRectangle` (a
/// non-rounded/less-round marker) alongside the default circular one, for
/// full coverage of `direction`/`stepShape`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture stepper', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/stepper');
    await capture.setSize();

    int horizontalStep = 0;
    int verticalStep = 0;

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KeyedSubtree(
                    key: const ValueKey('horizontal'),
                    child: StatefulBuilder(
                      builder: (context, setState) => ACDStepper(
                        steps: const ['Cart', 'Address', 'Payment', 'Done'],
                        activeStep: horizontalStep,
                        onStepReached: (i) =>
                            setState(() => horizontalStep = i),
                        titleStyle: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Expanded(
                    child: KeyedSubtree(
                      key: const ValueKey('vertical'),
                      child: StatefulBuilder(
                        builder: (context, setState) => ACDStepper(
                          steps: const ['Placed', 'Packed', 'Shipped'],
                          activeStep: verticalStep,
                          direction: Axis.vertical,
                          stepShape: ACDStepShape.roundedRectangle,
                          onStepReached: (i) =>
                              setState(() => verticalStep = i),
                        ),
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

    await capture.pumpAndCapture(Duration.zero);

    // Horizontal wizard, step through.
    final Finder horizontal = find.byKey(const ValueKey('horizontal'));
    for (int step = 1; step <= 3; step++) {
      await tester.tap(
        find.descendant(of: horizontal, matching: find.text('${step + 1}')),
      );
      for (int i = 0; i < 5; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      await capture.hold(4);
    }

    // Vertical timeline, step through.
    final Finder vertical = find.byKey(const ValueKey('vertical'));
    for (int step = 1; step <= 2; step++) {
      await tester.tap(
        find.descendant(of: vertical, matching: find.text('${step + 1}')),
      );
      for (int i = 0; i < 5; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      await capture.hold(4);
    }
    await capture.hold(8);
  });
}
