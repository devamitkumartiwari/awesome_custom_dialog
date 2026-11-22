import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
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
    'ACDAnimatedText onComplete fires even when the text ends in a space',
    (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        wrap(
          ACDAnimatedText(text: 'Hello ', onComplete: () => completed = true),
        ),
      );

      await tester.pumpAndSettle();

      expect(completed, isTrue);
    },
  );

  testWidgets('ACDAnimatedText handles emoji/grapheme clusters without error', (
    tester,
  ) async {
    bool completed = false;
    await tester.pumpWidget(
      wrap(
        ACDAnimatedText(
          text: 'Hi 👍🏽 there!',
          onComplete: () => completed = true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ACDAnimatedText completes under RTL directionality', (
    tester,
  ) async {
    bool completed = false;
    await tester.pumpWidget(
      wrap(
        ACDAnimatedText(text: 'שלום עולם', onComplete: () => completed = true),
        direction: TextDirection.rtl,
      ),
    );

    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  // Flutter 3.50+ lays out WidgetSpans in bidi visual order, so the
  // stagger must follow reading order: under RTL the rightmost (first
  // logical) character animates first.
  for (final TextDirection direction in TextDirection.values) {
    testWidgets('ACDAnimatedText staggers in reading order under $direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ACDAnimatedText(
            text: 'אבג',
            effect: ACDMotionEffect.fadeIn,
            charDuration: Duration(milliseconds: 100),
            staggerDelay: Duration(milliseconds: 100),
            curve: Curves.linear,
          ),
          direction: direction,
        ),
      );
      await tester.pump(); // start the entrance
      await tester.pump(const Duration(milliseconds: 50));

      double opacityOf(String c) => tester
          .widget<Opacity>(
            find
                .ancestor(of: find.text(c), matching: find.byType(Opacity))
                .first,
          )
          .opacity;
      double xOf(String c) => tester.getCenter(find.text(c)).dx;

      // The first logical character is mid-fade; the last hasn't started.
      expect(opacityOf('א'), greaterThan(0));
      expect(opacityOf('ג'), 0);
      // ...and the first logical character sits at the reading-start edge.
      if (direction == TextDirection.rtl) {
        expect(xOf('א'), greaterThan(xOf('ג')));
      } else {
        expect(xOf('א'), lessThan(xOf('ג')));
      }

      await tester.pumpAndSettle();
    });
  }

  testWidgets('ACDAnimatedText renders empty text without error', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const ACDAnimatedText(text: '')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
