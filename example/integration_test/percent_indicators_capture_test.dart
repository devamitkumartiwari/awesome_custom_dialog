import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "15. Percent & Loading Indicators".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture percent indicators', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/percent-indicators');
    await capture.setSize();

    final linear = ValueNotifier<double>(0);
    final circular = ValueNotifier<double>(0);

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ACDLinearPercentIndicator(
                      controller: linear,
                      progressColor: Colors.blue,
                      showPercentageText: true,
                    ),
                    const SizedBox(height: 32),
                    ACDCircularPercentIndicator(
                      radius: 60,
                      controller: circular,
                      progressColor: Colors.green,
                      showPercentageText: true,
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
    linear.value = 0.4;
    circular.value = 0.7;
    for (int i = 0; i < 16; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(8);
  });
}
