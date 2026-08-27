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

  testWidgets(
    'ACDSlideAction fires onConfirm when dragged past the threshold',
    (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(
        wrap(ACDSlideAction(label: 'Slide', onConfirm: () => confirmed = true)),
      );

      await tester.drag(find.byType(ACDSlideAction), const Offset(650, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    },
  );

  testWidgets(
    'ACDSlideAction snaps back without firing onConfirm below the threshold',
    (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(
        wrap(ACDSlideAction(label: 'Slide', onConfirm: () => confirmed = true)),
      );

      await tester.drag(find.byType(ACDSlideAction), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    },
  );

  testWidgets('ACDSlideAction controller drives loading/success/idle visuals', (
    tester,
  ) async {
    final controller = ACDSlideActionController();
    await tester.pumpWidget(
      wrap(
        ACDSlideAction(
          controller: controller,
          label: 'Slide',
          onConfirm: () {},
        ),
      ),
    );

    controller.loading();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.success();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);

    controller.reset();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('ACDSlideAction ignores drags when disabled', (tester) async {
    bool confirmed = false;
    await tester.pumpWidget(
      wrap(
        ACDSlideAction(
          enabled: false,
          label: 'Slide',
          onConfirm: () => confirmed = true,
        ),
      ),
    );

    await tester.drag(find.byType(ACDSlideAction), const Offset(650, 0));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);
  });

  testWidgets('ACDSlideAction mirrors drag direction under RTL', (
    tester,
  ) async {
    bool confirmed = false;
    await tester.pumpWidget(
      wrap(
        ACDSlideAction(label: 'Slide', onConfirm: () => confirmed = true),
        direction: TextDirection.rtl,
      ),
    );

    await tester.drag(find.byType(ACDSlideAction), const Offset(-650, 0));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets(
    'ACDSlideAction.swipeButton renders and fires onConfirm past the threshold',
    (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(
        wrap(
          ACDSlideAction.swipeButton(
            label: 'Swipe to pay',
            onConfirm: () => confirmed = true,
          ),
        ),
      );

      expect(find.text('Swipe to pay'), findsOneWidget);

      await tester.drag(find.byType(ACDSlideAction), const Offset(650, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    },
  );

  testWidgets(
    'activeTrackGradient swaps in while dragging, inactiveTrackGradient at rest',
    (tester) async {
      const inactive = LinearGradient(colors: [Colors.grey, Colors.white]);
      const active = LinearGradient(colors: [Colors.blue, Colors.purple]);
      await tester.pumpWidget(
        wrap(
          ACDSlideAction(
            label: 'Slide',
            onConfirm: () {},
            inactiveTrackGradient: inactive,
            activeTrackGradient: active,
          ),
        ),
      );

      Gradient? trackGradient() => tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((w) => (w.decoration as BoxDecoration).gradient)
          .firstWhere((g) => g != null);

      expect(trackGradient(), inactive);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(ACDSlideAction)),
      );
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();

      expect(trackGradient(), active);

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );
}
