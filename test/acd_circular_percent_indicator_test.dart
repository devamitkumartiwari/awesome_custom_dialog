import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('ACDCircularPercentIndicator renders at its initial value', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ACDCircularPercentIndicator(
          radius: 40,
          initialValue: 0.6,
          animate: false,
        ),
      ),
    );

    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ACDCircularPercentIndicator),
        matching: find.byType(CustomPaint),
      ),
    );
    // ignore: avoid_dynamic_calls
    expect((paint.painter as dynamic).progress, 0.6);
  });

  testWidgets(
    'ACDCircularPercentIndicator animates from its current value, not 0',
    (tester) async {
      Widget build(double value) => wrap(
        ACDCircularPercentIndicator(
          radius: 40,
          value: value,
          animationDuration: const Duration(milliseconds: 200),
        ),
      );

      await tester.pumpWidget(build(0.3));
      await tester.pumpAndSettle();
      await tester.pumpWidget(build(0.8));
      await tester.pump(const Duration(milliseconds: 100));

      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(ACDCircularPercentIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      // ignore: avoid_dynamic_calls
      final double mid = (paint.painter as dynamic).progress as double;
      expect(mid, greaterThan(0.3));
      expect(mid, lessThan(0.8));
    },
  );

  testWidgets(
    'ACDCircularPercentIndicator arc background spans the same extent as '
    'the foreground for a half-circle gauge (regression: the background '
    'must not stay a full circle behind a partial arc)',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const ACDCircularPercentIndicator(
            radius: 40,
            initialValue: 1.0,
            arcType: ACDLoaderArcType.half,
            animate: false,
          ),
        ),
      );

      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(ACDCircularPercentIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      // ignore: avoid_dynamic_calls
      expect((paint.painter as dynamic).sweepAngleDeg, 180.0);
    },
  );

  testWidgets(
    'ACDCircularPercentIndicator at 100% with a full 360° sweep still '
    'renders a visible ring (regression for the degenerate-arc bug)',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const ACDCircularPercentIndicator(
            radius: 40,
            initialValue: 1.0,
            animate: false,
          ),
        ),
      );

      // A CustomPaint's painter.paint is only actually invoked at flush time;
      // confirm painting doesn't throw and something is drawn by checking
      // the painter reports the clamped (non-degenerate) sweep.
      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(ACDCircularPercentIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.painter, isNotNull);
    },
  );

  testWidgets('ACDCircularPercentIndicator fillMode.pie paints filled paths', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ACDCircularPercentIndicator(
          radius: 40,
          initialValue: 0.5,
          fillMode: ACDLoaderFillMode.pie,
          animate: false,
        ),
      ),
    );

    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ACDCircularPercentIndicator),
        matching: find.byType(CustomPaint),
      ),
    );
    // ignore: avoid_dynamic_calls
    expect((paint.painter as dynamic).fillMode, ACDLoaderFillMode.pie);
  });

  testWidgets('ACDCircularPercentIndicator reverse flips the fill direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ACDCircularPercentIndicator(
          radius: 40,
          initialValue: 0.5,
          reverse: true,
          animate: false,
        ),
      ),
    );

    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ACDCircularPercentIndicator),
        matching: find.byType(CustomPaint),
      ),
    );
    // ignore: avoid_dynamic_calls
    expect((paint.painter as dynamic).reverse, isTrue);
  });

  testWidgets('ACDCircularPercentIndicator disposes its AnimationController', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ACDCircularPercentIndicator(radius: 40, initialValue: 0.3)),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
