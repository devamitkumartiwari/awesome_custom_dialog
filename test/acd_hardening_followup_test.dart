// Phase 1/2 hardening: lifecycle contracts, global switches, dark mode,
// localization and accessibility behaviour.
import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  home: Scaffold(body: Center(child: child)),
);

Widget _host(void Function(BuildContext context) onOpen, {ThemeData? theme}) {
  final Widget body = Builder(
    builder: (context) => ElevatedButton(
      onPressed: () => onOpen(context),
      child: const Text('Open'),
    ),
  );
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: body),
  );
}

void main() {
  tearDown(() {
    ACDToastManager.resetForTest();
    ACDDialogQueue.reset();
  });

  group('slide action', () {
    Future<void> slide(WidgetTester tester) async {
      await tester.drag(find.byType(ACDSlideAction), const Offset(650, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('without a controller it confirms only once', (tester) async {
      int confirms = 0;
      await tester.pumpWidget(
        _wrap(ACDSlideAction(label: 'Slide', onConfirm: () => confirms++)),
      );
      await slide(tester);
      await slide(tester);
      expect(confirms, 1);
    });

    testWidgets('autoResetAfter re-arms it', (tester) async {
      int confirms = 0;
      await tester.pumpWidget(
        _wrap(
          ACDSlideAction(
            label: 'Slide',
            autoResetAfter: const Duration(seconds: 1),
            onConfirm: () => confirms++,
          ),
        ),
      );
      await slide(tester);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await slide(tester);
      expect(confirms, 2);
    });

    testWidgets('controller.reset() re-arms it', (tester) async {
      int confirms = 0;
      final ACDSlideActionController controller = ACDSlideActionController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrap(
          ACDSlideAction(
            label: 'Slide',
            controller: controller,
            onConfirm: () => confirms++,
          ),
        ),
      );
      await slide(tester);
      controller.reset();
      await tester.pumpAndSettle();
      await slide(tester);
      expect(confirms, 2);
    });
  });

  group('pin field', () {
    testWidgets('Form.reset() clears the visible digits', (tester) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      String? saved;
      await tester.pumpWidget(
        _wrap(
          Form(
            key: form,
            child: ACDPinField(length: 4, onSaved: (v) => saved = v),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      form.currentState!.reset();
      await tester.pump();
      expect(find.text('1'), findsNothing);
      final TextField field = tester.widget(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      form.currentState!.save();
      expect(saved ?? '', isEmpty);
    });

    testWidgets('a caller controller with text seeds the form value', (
      tester,
    ) async {
      final TextEditingController controller = TextEditingController(
        text: '1234',
      );
      addTearDown(controller.dispose);
      String? saved;
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _wrap(
          Form(
            key: form,
            child: ACDPinField(
              length: 4,
              controller: controller,
              onSaved: (v) => saved = v,
            ),
          ),
        ),
      );
      await tester.pump();
      form.currentState!.save();
      expect(saved, '1234');
    });

    testWidgets('shrinking length trims the existing text', (tester) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      Widget pin(int length) =>
          _wrap(ACDPinField(length: length, controller: controller));
      await tester.pumpWidget(pin(6));
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpWidget(pin(4));
      await tester.pump();
      expect(controller.text, '1234');
    });

    testWidgets('hapticsEnabled: false silences the pin field', (tester) async {
      final List<MethodCall> calls = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method.startsWith('HapticFeedback')) calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        _wrap(
          ACDDesignScope(
            hapticsEnabled: false,
            child: ACDPinField(
              length: 4,
              hapticFeedbackType: ACDHapticFeedbackType.heavyImpact,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(calls, isEmpty);
    });
  });

  testWidgets('a blocking toast swallows taps on the app behind it', (
    tester,
  ) async {
    int taps = 0;
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ctx = context;
              return Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  onPressed: () => taps++,
                  child: const Text('Behind'),
                ),
              );
            },
          ),
        ),
      ),
    );
    ACDToastManager.show(
      ctx,
      const ACDToastConfig(
        message: 'Busy',
        blockBackgroundInteraction: true,
        autoDismissAfter: Duration.zero,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Behind'), warnIfMissed: false);
    expect(taps, 0);

    ACDToastManager.dismissAll();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Behind'));
    expect(taps, 1);
  });

  testWidgets('an actionable toast stays up for screen-reader users', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(accessibleNavigation: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      _host((context) {
        ACDToastManager.show(
          context,
          ACDToastConfig(
            message: 'Deleted',
            autoDismissAfter: const Duration(seconds: 2),
            actions: [TextButton(onPressed: () {}, child: const Text('Undo'))],
          ),
        );
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('multi-segment indicator does not replay on an unrelated '
      'rebuild', (tester) async {
    int ends = 0;
    Widget bar() => _wrap(
      SizedBox(
        width: 200,
        child: ACDMultiSegmentLinearIndicator(
          segments: const [ACDLoaderSegment(percent: 0.4)],
          onAnimationEnd: () => ends++,
        ),
      ),
    );
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();
    expect(ends, 1);
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();
    expect(ends, 1);
  });

  testWidgets('stepper (below placement) draws its connector under the '
      'marker', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 300,
          child: ACDStepper(
            steps: const ['One', 'Two'],
            direction: Axis.vertical,
            verticalTitlePlacement: ACDStepperTitlePlacement.below,
          ),
        ),
      ),
    );
    final Rect stepper = tester.getRect(find.byType(ACDStepper));
    final Finder line = find.descendant(
      of: find.byType(ACDStepper),
      matching: find.byType(CustomPaint),
    );
    // Start-aligned markers: the connector must sit near the start edge,
    // not in the middle of the 300 px column.
    final double lineX = tester.getRect(line.first).center.dx;
    expect(lineX - stepper.left, lessThan(60));
  });

  test('ACDDottedDecoration compares by value', () {
    expect(
      ACDDottedDecoration(dashPattern: [3, 2]),
      ACDDottedDecoration(dashPattern: [3, 2]),
    );
    expect(
      ACDDottedDecoration(dashPattern: [3, 2]) ==
          ACDDottedDecoration(dashPattern: [4, 2]),
      isFalse,
    );
  });

  group('dark mode', () {
    Color? cardColor(WidgetTester tester) {
      for (final Container c in tester.widgetList<Container>(
        find.byType(Container),
      )) {
        final Decoration? d = c.decoration;
        if (d is ShapeDecoration && d.color != null) return d.color;
      }
      return null;
    }

    testWidgets('light mode keeps the white card', (tester) async {
      await tester.pumpWidget(
        _host((context) {
          ACDDialog().build(context)
            ..text(text: 'Hi')
            ..show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(cardColor(tester), Colors.white);
    });

    testWidgets('dark mode uses the theme surface', (tester) async {
      final ThemeData dark = ThemeData(brightness: Brightness.dark);
      await tester.pumpWidget(
        _host((context) {
          ACDDialog().build(context)
            ..text(text: 'Hi')
            ..show();
        }, theme: dark),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(cardColor(tester), dark.colorScheme.surfaceContainerHigh);
    });
  });

  group('localized defaults', () {
    const ACDStrings german = ACDStrings(
      ok: 'Gut',
      successTitle: 'Erfolg',
      errorMessage: 'Fehler',
    );

    testWidgets('presets use ACDStrings for title and button', (tester) async {
      // App-wide scope (above the Navigator), as recommended: dialogs are
      // routes, so a scope inside one page doesn't reach them.
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              ACDDesignScope(strings: german, child: child!),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ACDDialog().build(context)
                    ..success(message: 'Saved')
                    ..show();
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Erfolg'), findsOneWidget);
      expect(find.text('Gut'), findsOneWidget);
    });

    testWidgets('searchable list error uses ACDStrings', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ACDDesignScope(
            strings: german,
            child: SizedBox(
              height: 400,
              child: ACDSearchableListTile<String>(
                items: const [],
                multiple: false,
                searchDebounce: Duration.zero,
                onFind: (_) async => throw Exception('db down'),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pumpAndSettle();
      expect(find.text('Fehler'), findsOneWidget);
      expect(find.textContaining('db down'), findsNothing);
    });
  });

  testWidgets('switch and rating bar expose a semantic label', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            ACDSwitch(
              initialValue: true,
              semanticLabel: 'Notifications',
              onChanged: (_) {},
            ),
            const ACDRatingBar(semanticLabel: 'Rate this app'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    expect(find.bySemanticsLabel('Rate this app'), findsOneWidget);
    handle.dispose();
  });
}
