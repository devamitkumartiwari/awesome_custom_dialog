import 'package:awesome_custom_dialog/src/motion/acd_stagger_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACDStaggerOptions.delayForIndex', () {
    const options = ACDStaggerOptions(
      interval: Duration(milliseconds: 50),
      startDelay: Duration(milliseconds: 100),
    );

    test('entrance delay grows linearly with index', () {
      expect(
        options.delayForIndex(0, 3, visible: true),
        const Duration(milliseconds: 100),
      );
      expect(
        options.delayForIndex(1, 3, visible: true),
        const Duration(milliseconds: 150),
      );
      expect(
        options.delayForIndex(2, 3, visible: true),
        const Duration(milliseconds: 200),
      );
    });

    test('exit delay is reversed by default (last in, first out)', () {
      // index 2 (last shown) should exit first -> smallest delay.
      expect(
        options.delayForIndex(2, 3, visible: false),
        const Duration(milliseconds: 100),
      );
      expect(
        options.delayForIndex(0, 3, visible: false),
        const Duration(milliseconds: 200),
      );
    });

    test('reverseOnExit: false keeps entrance order on exit too', () {
      final ACDStaggerOptions forward = options.copyWith(reverseOnExit: false);
      expect(
        forward.delayForIndex(0, 3, visible: false),
        const Duration(milliseconds: 100),
      );
      expect(
        forward.delayForIndex(2, 3, visible: false),
        const Duration(milliseconds: 200),
      );
    });
  });

  group('ACDStaggerOptions.copyWith', () {
    test('replaces only the given fields', () {
      const base = ACDStaggerOptions();
      final ACDStaggerOptions updated = base.copyWith(
        interval: const Duration(milliseconds: 10),
        curve: Curves.linear,
      );

      expect(updated.interval, const Duration(milliseconds: 10));
      expect(updated.curve, Curves.linear);
      expect(updated.itemDuration, base.itemDuration);
      expect(updated.startDelay, base.startDelay);
      expect(updated.effect, base.effect);
      expect(updated.reverseOnExit, base.reverseOnExit);
    });
  });
}
