import 'dart:async';

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
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

  testWidgets('shape is applied to the dialog card', (tester) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..shape = const StadiumBorder()
          ..text(text: 'Hello')
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final Iterable<Material> materials = tester.widgetList<Material>(
      find.byType(Material),
    );
    expect(materials.any((m) => m.shape is StadiumBorder), isTrue);
  });

  testWidgets('elevation renders a drop shadow via BoxShadow', (tester) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..elevation = 12
          ..text(text: 'Hello')
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final Iterable<Container> shadowContainers = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).boxShadow != null,
        );
    expect(shadowContainers, isNotEmpty);
    final List<BoxShadow> shadow =
        (shadowContainers.first.decoration! as BoxDecoration).boxShadow!;
    expect(shadow.single.blurRadius, 24); // elevation * 2
  });

  testWidgets('boxShadow overrides elevation entirely', (tester) async {
    const custom = [BoxShadow(color: Colors.red, blurRadius: 3)];
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..elevation = 12
          ..boxShadow = custom
          ..text(text: 'Hello')
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final Iterable<Container> shadowContainers = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).boxShadow != null,
        );
    expect(shadowContainers.first.decoration, isA<BoxDecoration>());
    expect(
      (shadowContainers.first.decoration! as BoxDecoration).boxShadow,
      custom,
    );
  });

  testWidgets('backgroundGradient/backgroundImage feed into the fill '
      'decoration when shape/decoration are unset', (tester) async {
    const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..backgroundGradient = gradient
          ..text(text: 'Hello')
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final Iterable<ShapeDecoration> decorations = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<ShapeDecoration>();
    expect(decorations, isNotEmpty);
    expect(decorations.first.gradient, gradient);
  });

  testWidgets('contentStagger wraps top-level content in ACDMotion', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..contentStagger = const ACDStaggerOptions()
          ..text(text: 'Hello')
          ..oneButton(text: 'OK')
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ACDMotion), findsWidgets);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('contentStagger is off by default (no ACDMotion wrapping)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..text(text: 'Hello')
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ACDMotion), findsNothing);
  });

  group('dismiss() lifecycle (regressions)', () {
    testWidgets('removes its own route, not a route pushed above it', (
      tester,
    ) async {
      late ACDDialog dialog;
      late BuildContext ctx;
      await tester.pumpWidget(
        wrap((context) {
          ctx = context;
          dialog = ACDDialog().build(context)
            ..text(text: 'Dialog body')
            ..show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Something else is pushed on top of the dialog.
      unawaited(
        Navigator.of(ctx, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Top page')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await dialog.dismiss();
      await tester.pumpAndSettle();

      // The page on top survives; only the dialog was removed.
      expect(find.text('Top page'), findsOneWidget);
      expect(find.text('Dialog body', skipOffstage: false), findsNothing);
    });

    testWidgets('dismiss() right after show() still closes the dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap((context) {
          final ACDDialog dialog = ACDDialog().build(context)
            ..text(text: 'Quick')
            ..show();
          dialog.dismiss(); // before the first frame of the dialog
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Quick'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets(
      'a stale autoDismiss timer from a previous showing does not close a '
      're-shown dialog early',
      (tester) async {
        late ACDDialog dialog;
        await tester.pumpWidget(
          wrap((context) {
            dialog = ACDDialog().build(context)
              ..autoDismissAfter = const Duration(seconds: 4)
              ..text(text: 'Timed')
              ..show();
          }),
        );
        // Explicit pumps (no pumpAndSettle) keep the fake clock exact.
        await tester.tap(find.text('Open')); // t=0: timer A due at t=4s
        await tester.pump();
        await tester.pump(const Duration(seconds: 3)); // t=3s

        await dialog.dismiss();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500)); // t=3.5s
        dialog.show(); // timer B due at t=7.5s
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500)); // t=4s

        // Past A's deadline (t=4s) — a leaked A would have closed it.
        await tester.pump(const Duration(seconds: 1)); // t=5s
        expect(find.text('Timed'), findsOneWidget);

        // B still fires on schedule.
        await tester.pump(const Duration(seconds: 3)); // t=8s
        await tester.pump(const Duration(milliseconds: 500)); // exit anim
        expect(find.text('Timed'), findsNothing);
      },
    );
  });

  testWidgets('a queued toast advances ACDDialogQueue when it is dismissed', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialogQueue.enqueue(
          ACDDialog.toast(
            context: context,
            message: 'First toast',
            showDuration: const Duration(milliseconds: 500),
          ),
        );
        ACDDialogQueue.enqueue(
          ACDDialog().build(context)..text(text: 'Second dialog'),
        );
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('First toast'), findsOneWidget);
    expect(find.text('Second dialog'), findsNothing);

    // Toast auto-dismisses → queue must advance to the dialog.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('First toast'), findsNothing);
    expect(find.text('Second dialog'), findsOneWidget);

    ACDDialogQueue.clearQueue();
    ACDToastManager.dismissAll();
  });
}
