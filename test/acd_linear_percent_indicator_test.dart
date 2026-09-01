import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('ACDLinearPercentIndicator renders at its initial value', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 200,
          child: ACDLinearPercentIndicator(initialValue: 0.4, animate: false),
        ),
      ),
    );

    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ACDLinearPercentIndicator),
        matching: find.byType(CustomPaint),
      ),
    );
    // ignore: avoid_dynamic_calls
    expect((paint.painter as dynamic).progress, 0.4);
  });

  testWidgets(
    'ACDLinearPercentIndicator animates a value change from its current '
    'displayed value, not from 0 (regression: must not restart from 0 on '
    'every rebuild)',
    (tester) async {
      Widget build(double value) => wrap(
        SizedBox(
          width: 200,
          child: ACDLinearPercentIndicator(
            value: value,
            animationDuration: const Duration(milliseconds: 200),
          ),
        ),
      );

      await tester.pumpWidget(build(0.5));
      await tester.pumpAndSettle();

      await tester.pumpWidget(build(0.9));
      // Halfway through the second animation.
      await tester.pump(const Duration(milliseconds: 100));

      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(ACDLinearPercentIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      // ignore: avoid_dynamic_calls
      final double mid = (paint.painter as dynamic).progress as double;
      // Animating 0.5 -> 0.9 should never dip back down toward/through 0.
      expect(mid, greaterThan(0.5));
      expect(mid, lessThan(0.9));
    },
  );

  testWidgets(
    'ACDLinearPercentIndicator with animate:false jumps instantly and never '
    'reads size before layout',
    (tester) async {
      // Regression: must not throw a "RenderBox not laid out" crash even
      // though the animation (if any) would start on the very first frame.
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 200,
            child: ACDLinearPercentIndicator(initialValue: 1.0, animate: false),
          ),
        ),
      );
    },
  );

  testWidgets(
    'ACDLinearPercentIndicator re-flows to a resized parent when no fixed '
    'width is given',
    (tester) async {
      double parentWidth = 100;
      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: parentWidth,
              child: const ACDLinearPercentIndicator(
                initialValue: 0.5,
                animate: false,
              ),
            ),
          ),
        ),
      );

      CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(ACDLinearPercentIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.size.width, 100);

      parentWidth = 250;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: parentWidth,
            child: const ACDLinearPercentIndicator(
              initialValue: 0.5,
              animate: false,
            ),
          ),
        ),
      );
      await tester.pump();

      paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(ACDLinearPercentIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.size.width, 250);
    },
  );

  testWidgets('ACDLinearPercentIndicator disposes its AnimationController', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 200,
          child: ACDLinearPercentIndicator(initialValue: 0.3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    // No pending tickers/timers should remain; pumpAndSettle would hang
    // otherwise and the test framework's `tearDown` ticker leak check would
    // fail this test.
    await tester.pumpAndSettle();
  });

  testWidgets('ACDLinearPercentIndicator applies disabledOpacity', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 200,
          child: ACDLinearPercentIndicator(
            initialValue: 0.5,
            enabled: false,
            disabledOpacity: 0.3,
            animate: false,
          ),
        ),
      ),
    );

    final Opacity opacity = tester.widget<Opacity>(
      find
          .descendant(
            of: find.byType(ACDLinearPercentIndicator),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, 0.3);
  });
}
