import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "14. Motion & Animated Text" — the
/// per-character text entrance plus three different `ACDMotionRestEffect`
/// loops (pulse/wave/rotate) for broader rest-effect coverage.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture motion & animated text', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/motion-animated-text');
    await capture.setSize();

    Widget chip(IconData icon, Color color, ACDMotionRestEffect effect) =>
        ACDMotion(
          restEffect: ACDRestEffectConfig(effect: effect),
          delay: const Duration(milliseconds: 1400),
          child: Icon(icon, color: color, size: 40),
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
                  const ACDAnimatedText(
                    text: 'Hello, world!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      chip(
                        Icons.favorite,
                        Colors.red,
                        ACDMotionRestEffect.pulse,
                      ),
                      const SizedBox(width: 28),
                      chip(
                        Icons.waving_hand,
                        Colors.orange,
                        ACDMotionRestEffect.wave,
                      ),
                      const SizedBox(width: 28),
                      chip(
                        Icons.settings,
                        demoSeedColor,
                        ACDMotionRestEffect.rotate,
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

    for (int i = 0; i < 16; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 90));
    }
    for (int i = 0; i < 20; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 120));
    }
    await capture.hold(6);
  });
}
