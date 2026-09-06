import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "13. Rating Bar" — the default star
/// glyphs, swappable heart glyphs, and the vector-star `StarBorder` style
/// for full icon-style coverage in one GIF.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture rating bar', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/rating-bar');
    await capture.setSize();

    double starRating = 0;
    double heartRating = 0;
    double vectorRating = 0;

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
                  StatefulBuilder(
                    key: const ValueKey('star'),
                    builder: (context, setState) => ACDRatingBar(
                      itemSize: 40,
                      allowHalfRating: true,
                      rating: starRating,
                      onRatingUpdate: (value) =>
                          setState(() => starRating = value),
                    ),
                  ),
                  const SizedBox(height: 28),
                  StatefulBuilder(
                    key: const ValueKey('heart'),
                    builder: (context, setState) => ACDRatingBar(
                      itemSize: 40,
                      filledIcon: Icons.favorite,
                      emptyIcon: Icons.favorite_border,
                      itemCount: 5,
                      rating: heartRating,
                      onRatingUpdate: (value) =>
                          setState(() => heartRating = value),
                    ),
                  ),
                  const SizedBox(height: 28),
                  StatefulBuilder(
                    key: const ValueKey('vector'),
                    builder: (context, setState) => ACDRatingBar(
                      itemSize: 40,
                      itemIconStyle: ACDRatingIconStyle.vectorStar,
                      rating: vectorRating,
                      onRatingUpdate: (value) =>
                          setState(() => vectorRating = value),
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

    for (final key in ['star', 'heart', 'vector']) {
      final Offset start = tester.getTopLeft(find.byKey(ValueKey(key)));
      final TestGesture gesture = await tester.startGesture(
        start + const Offset(10, 24),
      );
      for (int i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(20, 0));
        await capture.pumpAndCapture(const Duration(milliseconds: 50));
      }
      await gesture.up();
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
      await capture.hold(6);
    }
    await capture.hold(6);
  });
}
