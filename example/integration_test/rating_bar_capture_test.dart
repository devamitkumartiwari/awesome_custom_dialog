import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "13. Rating Bar".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture rating bar', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/rating-bar');
    await capture.setSize();

    double rating = 0;

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => ACDRatingBar(
                  itemSize: 48,
                  allowHalfRating: true,
                  rating: rating,
                  onRatingUpdate: (value) => setState(() => rating = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);

    final Offset start = tester.getTopLeft(find.byType(ACDRatingBar));
    final TestGesture gesture = await tester.startGesture(
      start + const Offset(10, 24),
    );
    for (int i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(20, 0));
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await capture.hold(10);
  });
}
