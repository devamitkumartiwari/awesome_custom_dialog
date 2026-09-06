import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "18. Dialog Styling & Content Stagger".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture dialog styling', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/dialog-styling');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
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
                      ..width = 280
                      ..text(
                        text: 'Styled dialog',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                      ..text(
                        text: 'shape, elevation, gradient & contentStagger',
                        color: Colors.white70,
                      )
                      ..oneButton(
                        text: 'Nice',
                        backgroundColor: Colors.white,
                        color: const Color(0xFF6A11CB),
                      )
                      ..show();
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.text('Open Dialog'));
    for (int i = 0; i < 16; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(14);
  });
}
