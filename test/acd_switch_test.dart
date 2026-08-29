import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {TextDirection direction = TextDirection.ltr}) =>
      MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(body: Center(child: child)),
        ),
      );

  testWidgets('ACDSwitch tap toggles the uncontrolled value', (tester) async {
    bool? lastValue;
    await tester.pumpWidget(wrap(ACDSwitch(onChanged: (v) => lastValue = v)));

    await tester.tap(find.byType(ACDSwitch));
    await tester.pumpAndSettle();
    expect(lastValue, isTrue);

    await tester.tap(find.byType(ACDSwitch));
    await tester.pumpAndSettle();
    expect(lastValue, isFalse);
  });

  testWidgets(
    'ACDSwitch controlled value keeps reporting from the last committed '
    'widget.value until the parent rebuilds',
    (tester) async {
      bool? lastValue;
      await tester.pumpWidget(
        wrap(ACDSwitch(value: false, onChanged: (v) => lastValue = v)),
      );

      await tester.tap(find.byType(ACDSwitch));
      await tester.pumpAndSettle();
      expect(lastValue, isTrue);

      // The parent hasn't rebuilt with the new value, so `value` is still
      // `false` and a second tap reports the same toggle again.
      await tester.tap(find.byType(ACDSwitch));
      await tester.pumpAndSettle();
      expect(lastValue, isTrue);
    },
  );

  testWidgets('ACDSwitch controller takes precedence and is mutated on tap', (
    tester,
  ) async {
    final controller = ValueNotifier<bool>(false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(ACDSwitch(controller: controller)));

    await tester.tap(find.byType(ACDSwitch));
    await tester.pumpAndSettle();

    expect(controller.value, isTrue);
  });

  testWidgets('ACDSwitch commits on drag past 50% of travel', (tester) async {
    bool? lastValue;
    await tester.pumpWidget(
      wrap(ACDSwitch(width: 200, onChanged: (v) => lastValue = v)),
    );

    // width: 200, height: 32, thumbPadding: 2 -> travel extent is 168px.
    // 120px is unambiguously past both touch slop and the 50% threshold.
    await tester.drag(find.byType(ACDSwitch), const Offset(120, 0));
    await tester.pumpAndSettle();

    expect(lastValue, isTrue);
  });

  testWidgets('ACDSwitch snaps back without committing below 50% of travel', (
    tester,
  ) async {
    bool? lastValue;
    await tester.pumpWidget(
      wrap(ACDSwitch(width: 200, onChanged: (v) => lastValue = v)),
    );

    // 40px clears touch slop (so this is unambiguously a drag, not a tap)
    // while staying well under 50% of the 168px travel extent.
    await tester.drag(find.byType(ACDSwitch), const Offset(40, 0));
    await tester.pumpAndSettle();

    expect(lastValue, isNull);
  });

  testWidgets('ACDSwitch mirrors drag direction under RTL', (tester) async {
    bool? lastValue;
    await tester.pumpWidget(
      wrap(
        ACDSwitch(width: 200, onChanged: (v) => lastValue = v),
        direction: TextDirection.rtl,
      ),
    );

    await tester.drag(find.byType(ACDSwitch), const Offset(-120, 0));
    await tester.pumpAndSettle();

    expect(lastValue, isTrue);
  });

  testWidgets('ACDSwitch ignores gestures when disabled', (tester) async {
    bool? lastValue;
    await tester.pumpWidget(
      wrap(ACDSwitch(enabled: false, onChanged: (v) => lastValue = v)),
    );

    await tester.tap(find.byType(ACDSwitch));
    await tester.pumpAndSettle();

    expect(lastValue, isNull);
  });
}
