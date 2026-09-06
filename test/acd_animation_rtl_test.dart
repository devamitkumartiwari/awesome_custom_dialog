import 'package:awesome_custom_dialog/src/core/acd_animation.dart';
import 'package:awesome_custom_dialog/src/toast/acd_toast_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression coverage for the pre-existing bug where ACDAnimation.slideLeft/
// slideRight were hardcoded physical offsets, disagreeing with every other
// direction-aware part of the package (gravity, margin, animated text) under
// RTL. See acd_gravity_rtl_test.dart for the equivalent gravity coverage.
void main() {
  Offset slideOffsetAt0(Function(Widget, Animation<double>) fn) {
    final Widget built =
        fn(const SizedBox(), const AlwaysStoppedAnimation<double>(0)) as Widget;
    return (built as SlideTransition).position.value;
  }

  group('acdPresetAnimFn RTL mirroring', () {
    test('slideLeft/slideRight are unchanged under the default (LTR)', () {
      expect(
        slideOffsetAt0(acdPresetAnimFn(ACDAnimation.slideLeft)),
        const Offset(1, 0),
      );
      expect(
        slideOffsetAt0(acdPresetAnimFn(ACDAnimation.slideRight)),
        const Offset(-1, 0),
      );
    });

    test('slideLeft/slideRight mirror under RTL', () {
      expect(
        slideOffsetAt0(
          acdPresetAnimFn(ACDAnimation.slideLeft, TextDirection.rtl),
        ),
        const Offset(-1, 0),
      );
      expect(
        slideOffsetAt0(
          acdPresetAnimFn(ACDAnimation.slideRight, TextDirection.rtl),
        ),
        const Offset(1, 0),
      );
    });

    test('slideUp/slideDown are unaffected by direction', () {
      for (final direction in TextDirection.values) {
        expect(
          slideOffsetAt0(acdPresetAnimFn(ACDAnimation.slideUp, direction)),
          const Offset(0, 1),
        );
        expect(
          slideOffsetAt0(acdPresetAnimFn(ACDAnimation.slideDown, direction)),
          const Offset(0, -1),
        );
      }
    });
  });

  group('acdToastPresetAnimFn RTL mirroring', () {
    test('slideLeft/slideRight are unchanged under the default (LTR)', () {
      expect(
        slideOffsetAt0(acdToastPresetAnimFn(ACDAnimation.slideLeft)),
        const Offset(1, 0),
      );
      expect(
        slideOffsetAt0(acdToastPresetAnimFn(ACDAnimation.slideRight)),
        const Offset(-1, 0),
      );
    });

    test('slideLeft/slideRight mirror under RTL', () {
      expect(
        slideOffsetAt0(
          acdToastPresetAnimFn(ACDAnimation.slideLeft, TextDirection.rtl),
        ),
        const Offset(-1, 0),
      );
      expect(
        slideOffsetAt0(
          acdToastPresetAnimFn(ACDAnimation.slideRight, TextDirection.rtl),
        ),
        const Offset(1, 0),
      );
    });
  });
}
