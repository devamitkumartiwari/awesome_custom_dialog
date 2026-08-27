import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(void Function(BuildContext context) onOpen) => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () => onOpen(context),
            child: const Text('Open'),
          );
        },
      ),
    ),
  );

  testWidgets('oneButton renders backgroundColor, borderRadius, and icon', (
    tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..oneButton(
            text: 'Confirm',
            backgroundColor: Colors.blue,
            borderRadius: BorderRadius.circular(12),
            icon: Icons.check,
            onTap: () => tapped = true,
          )
          ..show();
      }),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    final ButtonStyle? style = tester
        .widget<TextButton>(find.byType(TextButton))
        .style;
    expect(style?.backgroundColor?.resolve(<WidgetState>{}), Colors.blue);
    expect(
      (style?.shape?.resolve(
        <WidgetState>{},
      ) as RoundedRectangleBorder?)?.borderRadius,
      BorderRadius.circular(12),
    );

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets(
    'oneButton applies a gradient background via a wrapping Container',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog().build(context)
            ..oneButton(
              text: 'Gradient',
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.orange],
              ),
            )
            ..show();
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final Container container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(TextButton),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((container.decoration as BoxDecoration?)?.gradient, isNotNull);
    },
  );

  testWidgets('twoButton renders both backgroundColor1 and backgroundColor2', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..twoButton(
            text1: 'Cancel',
            backgroundColor1: Colors.grey,
            text2: 'OK',
            backgroundColor2: Colors.green,
          )
          ..show();
      }),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets(
    'a filled button gets non-zero default padding; a plain one stays flush',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog().build(context)
            ..twoButton(
              text1: 'Plain',
              text2: 'Filled',
              backgroundColor2: Colors.teal,
            )
            ..show();
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final List<TextButton> buttons = tester
          .widgetList<TextButton>(find.byType(TextButton))
          .toList();
      final ButtonStyle? plainStyle = buttons[0].style;
      final ButtonStyle? filledStyle = buttons[1].style;

      expect(
        plainStyle?.padding?.resolve(<WidgetState>{}),
        EdgeInsets.zero,
        reason: 'a button with no backgroundColor/gradient/boxShadow keeps the flat, flush look',
      );
      expect(
        filledStyle?.padding?.resolve(<WidgetState>{}),
        isNot(EdgeInsets.zero),
        reason: 'a filled button needs breathing room around its label',
      );
    },
  );

  testWidgets('an explicit buttonPadding always wins over the smart default', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..oneButton(
            text: 'Custom padding',
            backgroundColor: Colors.teal,
            buttonPadding: const EdgeInsets.all(2),
          )
          ..show();
      }),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final ButtonStyle? style = tester
        .widget<TextButton>(find.byType(TextButton))
        .style;
    expect(style?.padding?.resolve(<WidgetState>{}), const EdgeInsets.all(2));
  });

  testWidgets(
    'a filled button with no explicit height is not clipped by a fixed-height box',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog().build(context)
            ..oneButton(text: 'Filled', backgroundColor: Colors.teal)
            ..show();
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // No caller-provided height means the button's own content (including
      // the new default padding) must be free to size the row — regressing
      // to a hardcoded fixed-height SizedBox would clip a taller filled button.
      expect(find.byType(SizedBox), findsNothing);

      final Size buttonSize = tester.getSize(find.byType(TextButton));
      expect(buttonSize.height, greaterThan(44));
    },
  );
}
