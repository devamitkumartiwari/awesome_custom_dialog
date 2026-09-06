import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "14. Motion & Animated Text".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture motion & animated text', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/motion-animated-text');
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
                  ACDAnimatedText(
                    text: 'Hello, world!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  ACDMotion(
                    restEffect: ACDRestEffectConfig(
                      effect: ACDMotionRestEffect.pulse,
                    ),
                    delay: Duration(milliseconds: 1400),
                    child: Icon(Icons.favorite, color: Colors.red, size: 48),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < 16; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 90));
    }
    for (int i = 0; i < 14; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 120));
    }
    await capture.hold(6);
  });
}
