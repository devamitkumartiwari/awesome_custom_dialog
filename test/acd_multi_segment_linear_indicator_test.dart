import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets(
    'ACDMultiSegmentLinearIndicator renders one CustomPaint per segment',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 200,
            child: ACDMultiSegmentLinearIndicator(
              animate: false,
              segments: [
                ACDLoaderSegment(key: 'a', percent: 0.5, color: Colors.blue),
                ACDLoaderSegment(key: 'b', percent: 0.2, color: Colors.red),
              ],
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(ACDMultiSegmentLinearIndicator),
          matching: find.byType(CustomPaint),
        ),
        findsNWidgets(2),
      );
    },
  );

  testWidgets(
    'ACDMultiSegmentLinearIndicator does not throw when segments shrink or '
    'reorder at runtime (regression: a fixed-size positional index must '
    'never be used for animated segment state)',
    (tester) async {
      Widget build(List<ACDLoaderSegment> segments) => wrap(
        SizedBox(
          width: 200,
          child: ACDMultiSegmentLinearIndicator(
            animate: false,
            segments: segments,
          ),
        ),
      );

      await tester.pumpWidget(
        build(const [
          ACDLoaderSegment(key: 'a', percent: 0.5, color: Colors.blue),
          ACDLoaderSegment(key: 'b', percent: 0.2, color: Colors.red),
          ACDLoaderSegment(key: 'c', percent: 0.1, color: Colors.green),
        ]),
      );

      // Shrink. Must not throw a RangeError.
      await tester.pumpWidget(
        build(const [
          ACDLoaderSegment(key: 'a', percent: 0.6, color: Colors.blue),
        ]),
      );

      // Reorder + grow again with a fresh key. Must not throw either.
      await tester.pumpWidget(
        build(const [
          ACDLoaderSegment(key: 'c', percent: 0.9, color: Colors.green),
          ACDLoaderSegment(key: 'd', percent: 0.4, color: Colors.orange),
          ACDLoaderSegment(key: 'a', percent: 0.1, color: Colors.blue),
        ]),
      );
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'ACDMultiSegmentLinearIndicator animates each segment independently '
    'from its own previous value',
    (tester) async {
      Widget build(List<ACDLoaderSegment> segments) => wrap(
        SizedBox(
          width: 200,
          child: ACDMultiSegmentLinearIndicator(
            segments: segments,
            animationDuration: const Duration(milliseconds: 200),
          ),
        ),
      );

      await tester.pumpWidget(
        build(const [
          ACDLoaderSegment(key: 'a', percent: 0.2, color: Colors.blue),
          ACDLoaderSegment(key: 'b', percent: 0.8, color: Colors.red),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        build(const [
          ACDLoaderSegment(key: 'a', percent: 0.9, color: Colors.blue),
          ACDLoaderSegment(key: 'b', percent: 0.1, color: Colors.red),
        ]),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final List<CustomPaint> paints = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(ACDMultiSegmentLinearIndicator),
              matching: find.byType(CustomPaint),
            ),
          )
          .toList();
      // ignore: avoid_dynamic_calls
      final double a = (paints[0].painter as dynamic).progress as double;
      // ignore: avoid_dynamic_calls
      final double b = (paints[1].painter as dynamic).progress as double;
      // 'a' animates up (0.2 -> 0.9): should be above its start.
      expect(a, greaterThan(0.2));
      // 'b' animates down (0.8 -> 0.1): should be below its start.
      expect(b, lessThan(0.8));
    },
  );

  testWidgets('ACDMultiSegmentLinearIndicator per-segment strokeCap override', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 200,
          child: ACDMultiSegmentLinearIndicator(
            animate: false,
            strokeCap: ACDLoaderStrokeCap.round,
            segments: [
              ACDLoaderSegment(
                key: 'a',
                percent: 0.5,
                strokeCap: ACDLoaderStrokeCap.butt,
              ),
            ],
          ),
        ),
      ),
    );

    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ACDMultiSegmentLinearIndicator),
        matching: find.byType(CustomPaint),
      ),
    );
    // ignore: avoid_dynamic_calls
    expect((paint.painter as dynamic).strokeCap, ACDLoaderStrokeCap.butt);
  });

  testWidgets(
    'ACDMultiSegmentLinearIndicator disposes its stripe ticker when no '
    'longer needed',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 200,
            child: ACDMultiSegmentLinearIndicator(
              stripeEffect: true,
              segments: [
                ACDLoaderSegment(key: 'a', percent: 0.5, color: Colors.blue),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
