import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  // The hidden real TextField underneath also "contains" whatever was
  // typed (that's the whole point of the architecture), so a plain
  // `find.text(...)` matches both the visible cell and that hidden
  // EditableText. Scope to actual `Text` widgets (the cells) only.
  Finder findCellText(String value) => find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == value,
  );

  testWidgets('ACDPinField renders `length` cells and reflects initialValue', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(ACDPinField(length: 4, initialValue: '12')));

    expect(findCellText('1'), findsOneWidget);
    expect(findCellText('2'), findsOneWidget);
  });

  testWidgets(
    'ACDPinField typing updates cells and fires onChanged/onCompleted',
    (tester) async {
      String? changed;
      String? completed;
      await tester.pumpWidget(
        wrap(
          ACDPinField(
            length: 4,
            onChanged: (v) => changed = v,
            onCompleted: (v) => completed = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(changed, '12');
      expect(completed, isNull);
      expect(findCellText('1'), findsOneWidget);
      expect(findCellText('2'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();
      expect(changed, '1234');
      expect(completed, '1234');
    },
  );

  testWidgets('ACDPinField enabled:false blocks input and dims the field', (
    tester,
  ) async {
    String? changed;
    await tester.pumpWidget(
      wrap(
        ACDPinField(
          length: 4,
          enabled: false,
          disabledOpacity: 0.4,
          onChanged: (v) => changed = v,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    expect(changed, isNull);

    final Opacity opacity = tester.widget<Opacity>(
      find
          .descendant(
            of: find.byType(ACDPinField),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, 0.4);
  });

  testWidgets(
    'ACDPinField long-press does not crash (regression: text selection is '
    'delegated entirely to the underlying TextField, never reimplemented)',
    (tester) async {
      await tester.pumpWidget(wrap(ACDPinField(length: 4)));
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();

      // Must not throw.
      await tester.longPress(find.byType(TextField));
      await tester.pump();
    },
  );

  testWidgets('ACDPinField autofocus focuses on the first pump', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      wrap(ACDPinField(length: 4, focusNode: focusNode, autofocus: true)),
    );
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets(
    'ACDPinField forceErrorText does not drop focus (regression: error '
    'state must never call unfocus())',
    (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        wrap(ACDPinField(length: 4, focusNode: focusNode)),
      );
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.pumpWidget(
        wrap(
          ACDPinField(
            length: 4,
            focusNode: focusNode,
            forceErrorText: 'Invalid code',
          ),
        ),
      );
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
      expect(find.text('Invalid code'), findsOneWidget);
    },
  );

  testWidgets('ACDPinField animationDuration: Duration.zero does not throw '
      '(regression: implicit animations must handle a zero duration safely)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(ACDPinField(length: 4, animationDuration: Duration.zero)),
    );
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    expect(findCellText('1'), findsOneWidget);
  });

  testWidgets('ACDPinField obscures typed digits and briefly reveals with '
      'obscureRevealDuration set', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDPinField(
          length: 4,
          obscureText: true,
          obscureRevealDuration: Duration(milliseconds: 200),
          pinAnimationType: ACDPinAnimationType.none,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    expect(findCellText('1'), findsOneWidget);

    // Past the reveal duration. No `pumpAndSettle` here: the blinking
    // cursor's repeating AnimationController never settles on its own.
    await tester.pump(const Duration(milliseconds: 200));
    expect(findCellText('1'), findsNothing);
    expect(findCellText('•'), findsOneWidget);
  });

  testWidgets(
    'ACDPinField obscures immediately with no obscureRevealDuration',
    (tester) async {
      await tester.pumpWidget(wrap(ACDPinField(length: 4, obscureText: true)));

      await tester.enterText(find.byType(TextField), '1');
      await tester.pump();

      expect(findCellText('1'), findsNothing);
      expect(findCellText('•'), findsOneWidget);
    },
  );

  testWidgets(
    'ACDPinField validator + default autovalidateMode surfaces the error '
    'on the very first interaction (regression: an error must not be '
    'silently withheld until a second interaction)',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          ACDPinField(
            length: 4,
            validator: (v) => (v?.length ?? 0) == 4 ? null : 'Incomplete',
          ),
        ),
      );
      expect(find.text('Incomplete'), findsNothing);

      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();

      expect(find.text('Incomplete'), findsOneWidget);
    },
  );

  testWidgets('ACDPinField wrap:true lays out a long code without error', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(ACDPinField(length: 12, wrap: true)));
  });

  testWidgets(
    'ACDPinField submittedPinTheme wins over focusedPinTheme once complete',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          ACDPinField(
            length: 2,
            initialValue: '12',
            focusedPinTheme: ACDPinTheme(
              decoration: BoxDecoration(color: Colors.blue),
            ),
            submittedPinTheme: ACDPinTheme(
              decoration: BoxDecoration(color: Colors.green),
            ),
          ),
        ),
      );

      final Iterable<Container> containers = tester.widgetList<Container>(
        find.byType(Container),
      );
      final bool anyGreen = containers.any(
        (c) => (c.decoration as BoxDecoration?)?.color == Colors.green,
      );
      expect(anyGreen, isTrue);
    },
  );

  testWidgets('ACDPinField cellBuilder fully overrides cell rendering', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDPinField(
          length: 3,
          cellBuilder: (context, index, state, char) =>
              Text('cell-$index-$char'),
        ),
      ),
    );

    expect(find.text('cell-0-'), findsOneWidget);
    expect(find.text('cell-1-'), findsOneWidget);
    expect(find.text('cell-2-'), findsOneWidget);
  });

  testWidgets('ACDPinField entering the full pin at once (paste-equivalent) '
      'populates every cell', (tester) async {
    String? completed;
    await tester.pumpWidget(
      wrap(ACDPinField(length: 4, onCompleted: (v) => completed = v)),
    );

    await tester.enterText(find.byType(TextField), '9876');
    await tester.pump();

    expect(completed, '9876');
    for (final digit in ['9', '8', '7', '6']) {
      expect(findCellText(digit), findsOneWidget);
    }
  });
}
