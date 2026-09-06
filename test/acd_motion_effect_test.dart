import 'package:awesome_custom_dialog/src/motion/acd_motion_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(TextDirection direction, WidgetBuilder builder) => Directionality(
    textDirection: direction,
    child: Builder(builder: builder),
  );

  group('ACDMotionEffect.slideInFromStart/End RTL resolution', () {
    testWidgets('slideInFromStart matches slideInFromLeft under LTR', (
      tester,
    ) async {
      late ACDMotionEffect resolved;
      await tester.pumpWidget(
        wrap(TextDirection.ltr, (context) {
          resolved = ACDMotionEffect.slideInFromStart(context);
          return const SizedBox();
        }),
      );
      expect(
        resolved.beginOffsetFactor,
        ACDMotionEffect.slideInFromLeft().beginOffsetFactor,
      );
    });

    testWidgets('slideInFromStart matches slideInFromRight under RTL', (
      tester,
    ) async {
      late ACDMotionEffect resolved;
      await tester.pumpWidget(
        wrap(TextDirection.rtl, (context) {
          resolved = ACDMotionEffect.slideInFromStart(context);
          return const SizedBox();
        }),
      );
      expect(
        resolved.beginOffsetFactor,
        ACDMotionEffect.slideInFromRight().beginOffsetFactor,
      );
    });

    testWidgets('slideInFromEnd mirrors slideInFromStart', (tester) async {
      late ACDMotionEffect start;
      late ACDMotionEffect end;
      await tester.pumpWidget(
        wrap(TextDirection.rtl, (context) {
          start = ACDMotionEffect.slideInFromStart(context);
          end = ACDMotionEffect.slideInFromEnd(context);
          return const SizedBox();
        }),
      );
      expect(start.beginOffsetFactor, isNot(end.beginOffsetFactor));
      expect(
        end.beginOffsetFactor,
        ACDMotionEffect.slideInFromLeft().beginOffsetFactor,
      );
    });

    testWidgets('slideOutToStart/End mirror the same way on exit', (
      tester,
    ) async {
      late ACDMotionEffect resolved;
      await tester.pumpWidget(
        wrap(TextDirection.rtl, (context) {
          resolved = ACDMotionEffect.slideOutToStart(context);
          return const SizedBox();
        }),
      );
      expect(
        resolved.endOffsetFactor,
        ACDMotionEffect.slideOutToRight().endOffsetFactor,
      );
    });
  });

  group('ACDMotionEffect.reversed', () {
    test('swaps every begin/end pair', () {
      const effect = ACDMotionEffect(
        beginOpacity: 0,
        endOpacity: 1,
        beginScale: 0.5,
        endScale: 1.5,
      );
      final ACDMotionEffect reversed = effect.reversed;
      expect(reversed.beginOpacity, effect.endOpacity);
      expect(reversed.endOpacity, effect.beginOpacity);
      expect(reversed.beginScale, effect.endScale);
      expect(reversed.endScale, effect.beginScale);
    });
  });
}
