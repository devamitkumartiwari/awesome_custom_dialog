import 'package:awesome_custom_dialog/src/core/acd_gravity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('acdGravityToAlignment RTL mirroring', () {
    test('left/right mirror under RTL, unchanged under LTR', () {
      expect(
        acdGravityToAlignment(ACDGravity.left, TextDirection.ltr),
        Alignment.centerLeft,
      );
      expect(
        acdGravityToAlignment(ACDGravity.left, TextDirection.rtl),
        Alignment.centerRight,
      );
      expect(
        acdGravityToAlignment(ACDGravity.right, TextDirection.rtl),
        Alignment.centerLeft,
      );
    });

    test('all four corners mirror under RTL', () {
      expect(
        acdGravityToAlignment(ACDGravity.leftTop, TextDirection.rtl),
        Alignment.topRight,
      );
      expect(
        acdGravityToAlignment(ACDGravity.rightTop, TextDirection.rtl),
        Alignment.topLeft,
      );
      expect(
        acdGravityToAlignment(ACDGravity.leftBottom, TextDirection.rtl),
        Alignment.bottomRight,
      );
      expect(
        acdGravityToAlignment(ACDGravity.rightBottom, TextDirection.rtl),
        Alignment.bottomLeft,
      );
    });

    test('top/bottom/center are unaffected by direction', () {
      for (final direction in TextDirection.values) {
        expect(
          acdGravityToAlignment(ACDGravity.top, direction),
          Alignment.topCenter,
        );
        expect(
          acdGravityToAlignment(ACDGravity.bottom, direction),
          Alignment.bottomCenter,
        );
        expect(
          acdGravityToAlignment(ACDGravity.center, direction),
          Alignment.center,
        );
      }
    });
  });

  group('acdResolveMarginForGravity RTL mirroring', () {
    test('left/right margins mirror under RTL (regression for the internal '
        'contradiction where gravity meant "visual start" for button rows '
        'but "physical left" for docking/margin)', () {
      final EdgeInsets ltrLeft = acdResolveMarginForGravity(
        ACDGravity.left,
        EdgeInsets.zero,
        TextDirection.ltr,
      );
      final EdgeInsets rtlLeft = acdResolveMarginForGravity(
        ACDGravity.left,
        EdgeInsets.zero,
        TextDirection.rtl,
      );
      // Under RTL, ACDGravity.left resolves like .right did under LTR —
      // flush against the (now mirrored) near edge.
      final EdgeInsets ltrRight = acdResolveMarginForGravity(
        ACDGravity.right,
        EdgeInsets.zero,
        TextDirection.ltr,
      );
      expect(rtlLeft, ltrRight);
      expect(rtlLeft, isNot(ltrLeft));
    });

    test(
      'an explicit non-zero margin is never overridden regardless of direction',
      () {
        const EdgeInsets explicit = EdgeInsets.all(10);
        expect(
          acdResolveMarginForGravity(
            ACDGravity.left,
            explicit,
            TextDirection.rtl,
          ),
          explicit,
        );
      },
    );
  });
}
