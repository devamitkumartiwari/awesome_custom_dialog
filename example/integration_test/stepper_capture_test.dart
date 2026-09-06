import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "11. Stepper".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture stepper', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/stepper');
    await capture.setSize();

    int currentStep = 0;

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatefulBuilder(
                  builder: (context, setState) => ACDStepper(
                    steps: const ['Cart', 'Address', 'Payment', 'Done'],
                    activeStep: currentStep,
                    onStepReached: (i) => setState(() => currentStep = i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    for (int step = 1; step <= 3; step++) {
      await tester.tap(find.text('${step + 1}'));
      for (int i = 0; i < 5; i++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
      await capture.hold(4);
    }
    await capture.hold(6);
  });
}
