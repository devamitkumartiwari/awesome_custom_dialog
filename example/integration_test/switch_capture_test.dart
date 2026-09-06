import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "12. Switch".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture switch', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/switch');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ACDSwitch.material(initialValue: false),
                  SizedBox(height: 32),
                  ACDSwitch.ios(initialValue: false),
                  SizedBox(height: 32),
                  ACDSwitch(
                    initialValue: false,
                    shape: ACDSwitchShape.roundedRectangle,
                    activeTrackColor: Color(0xFF7C4DFF),
                    inactiveTrackColor: Color(0xFFE0E0E0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);

    final Finder switches = find.byType(ACDSwitch);
    for (int i = 0; i < switches.evaluate().length; i++) {
      await tester.tap(switches.at(i));
      for (int f = 0; f < 4; f++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
    }
    await capture.hold(6);

    for (int i = 0; i < switches.evaluate().length; i++) {
      await tester.tap(switches.at(i));
      for (int f = 0; f < 4; f++) {
        await capture.pumpAndCapture(const Duration(milliseconds: 60));
      }
    }
    await capture.hold(6);
  });
}
