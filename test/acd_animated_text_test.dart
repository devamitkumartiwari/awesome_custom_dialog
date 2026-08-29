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

  testWidgets('ACDAnimatedText renders empty text without error', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const ACDAnimatedText(text: '')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
