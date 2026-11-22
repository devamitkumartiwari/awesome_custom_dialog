// Regression tests for the 2.0 hardening pass: inputs that used to hang the
// UI thread, throw, or leave a dialog/toast/queue stuck.
import 'dart:async';
import 'dart:ui';

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:awesome_custom_dialog/src/dashed/acd_dash_path.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

/// A host whose button runs [onOpen] with a context under the Navigator.
Widget _host(void Function(BuildContext context) onOpen) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => onOpen(context),
        child: const Text('Open'),
      ),
    ),
  ),
);

void main() {
  tearDown(() {
    ACDToastManager.resetForTest();
    ACDDialogQueue.reset();
  });

  group('dash path never hangs', () {
    final Path line = Path()
      ..moveTo(0, 0)
      ..lineTo(10000, 0);

    test(
      'negative entries are rejected (assert in debug, empty in release)',
      () {
        // Debug builds flag the misuse; release builds (no asserts) take the
        // guard and return an empty path instead of looping forever.
        expect(
          () => acdDashPath(line, pattern: const [-5, 3]),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('a sub-pixel pattern draws nothing instead of millions of dashes', () {
      final Path out = acdDashPath(line, pattern: const [0.001, 0.001]);
      expect(out.computeMetrics().isEmpty, isTrue);
    });

    test('a zero gap draws a continuous line', () {
      final Path out = acdDashPath(line, pattern: const [4, 0]);
      final double total = out.computeMetrics().fold(
        0.0,
        (sum, m) => sum + m.length,
      );
      expect(total, closeTo(10000, 1));
    });

    test('a non-finite phase is ignored', () {
      final Path out = acdDashPath(
        line,
        pattern: const [4, 4],
        phase: double.nan,
      );
      expect(out.computeMetrics().isNotEmpty, isTrue);
    });
  });

  testWidgets('wavy linear loader inside an unbounded width does not hang', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 300,
          child: ACDLinearPercentIndicator(
            value: 0.5,
            style: ACDLoaderStyle.wavy,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  group('motion sequences', () {
    Widget seq(int count, {bool loop = false}) => _wrap(
      ACDMotionSequence(
        trigger: ACDMotionSequenceTrigger.tap,
        loop: loop,
        children: [
          for (int i = 0; i < count; i++)
            ACDMotionSequenceStep(child: Text('step $i')),
        ],
      ),
    );

    testWidgets('shrinking children below the active step does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(seq(3));
      await tester.tap(find.text('step 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('step 1'));
      await tester.pumpAndSettle();
      expect(find.text('step 2'), findsOneWidget);

      await tester.pumpWidget(seq(1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('step 0'), findsOneWidget);
    });

    testWidgets('a single looping step replays its entrance', (tester) async {
      int changes = 0;
      await tester.pumpWidget(
        _wrap(
          ACDMotionSequence(
            trigger: ACDMotionSequenceTrigger.tap,
            loop: true,
            onStepChanged: (_) => changes++,
            children: const [ACDMotionSequenceStep(child: Text('only'))],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('only'));
      await tester.pump();
      // The entrance restarted: mid-animation, opacity is below 1.
      final Opacity opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('only'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, lessThan(1));
      expect(changes, 1);
      await tester.pumpAndSettle();
    });
  });

  group('rating bar', () {
    testWidgets('lowering itemCount re-clamps an uncontrolled rating', (
      tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      Widget bar(int count) =>
          _wrap(ACDRatingBar(initialRating: 5, itemCount: count));
      await tester.pumpWidget(bar(5));
      await tester.pumpWidget(bar(3));
      await tester.pump();
      final SemanticsNode node = tester.getSemantics(find.byType(ACDRatingBar));
      expect(node.value, '3 of 3');
      semantics.dispose();
    });

    testWidgets('increase action steps exactly on a 0.1 grid', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<double> updates = [];
      await tester.pumpWidget(
        _wrap(
          ACDRatingBar(
            initialRating: 0.2,
            ratingPrecision: 0.1,
            onRatingUpdate: updates.add,
          ),
        ),
      );
      final SemanticsNode node = tester.getSemantics(find.byType(ACDRatingBar));
      node.owner!.performAction(node.id, SemanticsAction.increase);
      await tester.pump();
      expect(updates.single, 0.3); // not 0.30000000000000004
      semantics.dispose();
    });
  });

  testWidgets('slide action inside a Row (unbounded width) lays out', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Row(
          children: [ACDSlideAction(label: 'Slide', onConfirm: () {})],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ACDSlideAction)).width, 280);
  });

  testWidgets('dual slide action thumb stays inside the track', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 300,
          child: ACDSlideAction(
            label: 'Slide',
            direction: ACDSlideActionDirection.dual,
            onConfirm: () {},
          ),
        ),
      ),
    );
    final Rect track = tester.getRect(find.byType(ACDSlideAction));
    final TestGesture gesture = await tester.startGesture(track.center);
    await gesture.moveBy(const Offset(1000, 0));
    await tester.pump();
    final Finder thumb = find.descendant(
      of: find.byType(ACDSlideAction),
      matching: find.byType(PositionedDirectional),
    );
    expect(tester.getRect(thumb.last).right, lessThanOrEqualTo(track.right));
    await gesture.moveBy(const Offset(-2000, 0));
    await tester.pump();
    expect(tester.getRect(thumb.last).left, greaterThanOrEqualTo(track.left));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  group('toasts', () {
    testWidgets('a throwing onDismissed still completes closed', (
      tester,
    ) async {
      late ACDToastController controller;
      await tester.pumpWidget(
        _host((context) {
          controller = ACDToastManager.show(
            context,
            ACDToastConfig(
              message: 'hello',
              onDismissed: () => throw StateError('boom'),
            ),
          );
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      ACDToastManager.dismissAll();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isA<StateError>());
      expect(
        await controller.closed.timeout(const Duration(seconds: 1)),
        isNotNull,
      );
      expect(ACDToastManager.activeCount(), 0);
    });

    testWidgets('a toast still shows after its overlay was replaced', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host((context) {
          ACDToastManager.show(
            context,
            const ACDToastConfig(
              message: 'first',
              autoDismissAfter: Duration.zero, // sticky
            ),
          );
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('first'), findsOneWidget);

      // A brand-new app (new Navigator + Overlay) replaces the old one.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pumpWidget(
        _host((context) {
          ACDToastManager.show(
            context,
            const ACDToastConfig(message: 'second'),
          );
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('maxVisible: 0 still shows a toast', (tester) async {
      await tester.pumpWidget(
        _host((context) {
          ACDToastManager.show(
            context,
            const ACDToastConfig(message: 'hi', maxVisible: 0),
          );
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('a reused id is not unregistered by the older toast', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host((context) {
          ACDToastManager.show(
            context,
            const ACDToastConfig(
              message: 'a',
              id: 'same',
              autoDismissAfter: Duration.zero,
              cancelPrevious: false,
            ),
          );
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      ACDToastManager.dismissById('same'); // older one starts exiting
      await tester.tap(find.text('Open')); // newer one, same id
      await tester.pumpAndSettle();
      expect(ACDToastManager.findById('same'), isNotNull);
    });
  });

  group('dialog lifecycle', () {
    testWidgets('an old showing cannot complete a newer showForResult', (
      tester,
    ) async {
      final ACDDialog dialog = ACDDialog();
      Future<String?>? second;
      await tester.pumpWidget(
        _host((context) {
          dialog
            ..build(context)
            ..text(text: 'Body');
        }),
      );
      await tester.tap(find.text('Open'));
      unawaited(dialog.showForResult<String>());
      await tester.pumpAndSettle();
      dialog.dismiss();
      second = dialog.showForResult<String>(); // old route still exiting
      await tester.pumpAndSettle();

      bool completed = false;
      unawaited(second.then((_) => completed = true));
      await tester.pump();
      expect(completed, isFalse);
      expect(find.text('Body'), findsOneWidget);
      expect(dialog.isShowing, isTrue);

      dialog
        ..setResult('picked')
        ..dismiss();
      await tester.pumpAndSettle();
      expect(await second, 'picked');
    });

    testWidgets('show() twice keeps a single copy on screen', (tester) async {
      final ACDDialog dialog = ACDDialog();
      await tester.pumpWidget(
        _host((context) {
          dialog
            ..build(context)
            ..text(text: 'Once')
            ..show()
            ..show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Once'), findsOneWidget);
      dialog.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('Once'), findsNothing);
    });

    testWidgets('dismissCallBack may call setState', (tester) async {
      int dismissed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Column(
                children: [
                  Text('dismissed $dismissed'),
                  ElevatedButton(
                    onPressed: () {
                      ACDDialog().build(context)
                        ..text(text: 'Hi')
                        ..dismissCallBack = (() => setState(() => dismissed++))
                        ..show();
                    },
                    child: const Text('Open'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5)); // barrier
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('dismissed 1'), findsOneWidget);
    });

    testWidgets('a staggered dismiss does not close a newer showing', (
      tester,
    ) async {
      final ACDDialog dialog = ACDDialog()
        ..contentStagger = const ACDStaggerOptions();
      await tester.pumpWidget(
        _host((context) {
          dialog
            ..build(context)
            ..text(text: 'Stagger')
            ..show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      unawaited(dialog.dismiss()); // starts the staggered exit
      await tester.pump(const Duration(milliseconds: 50));
      dialog.show(); // a new showing takes over mid-exit
      await tester.pumpAndSettle();
      expect(find.text('Stagger'), findsOneWidget);
      expect(dialog.isShowing, isTrue);
    });

    testWidgets('show(x, y) does not overwrite gravity or margin', (
      tester,
    ) async {
      final ACDDialog dialog = ACDDialog();
      await tester.pumpWidget(
        _host((context) {
          dialog
            ..build(context)
            ..text(text: 'At')
            ..show(40, 60);
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(dialog.gravity, ACDGravity.center);
      expect(tester.getTopLeft(find.text('At')).dx, greaterThanOrEqualTo(40));
    });

    testWidgets('autoDismissAfter: Duration.zero keeps the dialog open', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host((context) {
          ACDDialog().build(context)
            ..autoDismissAfter = Duration.zero
            ..text(text: 'Stays')
            ..show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Stays'), findsOneWidget);
    });

    testWidgets('showing with an unmounted context reports instead of '
        'crashing', (tester) async {
      late BuildContext stale;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              stale = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: Text('other')));
      final Future<Object?> result = ACDDialog()
          .build(stale)
          .showForResult<Object>();
      expect(tester.takeException(), isA<FlutterError>());
      expect(await result, isNull);
    });
  });

  group('dialog queue', () {
    testWidgets('skips a dialog that cannot show and keeps going', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host((context) {
          ACDDialogQueue.enqueue(ACDDialog()..text(text: 'no context'));
          ACDDialogQueue.enqueue(ACDDialog().build(context)..text(text: 'B'));
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('shows the next one after the current one closes, and '
        'leaves dismissCallBack alone', (tester) async {
      final ACDDialog a = ACDDialog();
      final ACDDialog b = ACDDialog();
      await tester.pumpWidget(
        _host((context) {
          a
            ..build(context)
            ..text(text: 'A');
          b
            ..build(context)
            ..text(text: 'B');
          ACDDialogQueue.enqueue(a);
          ACDDialogQueue.enqueue(b);
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);
      expect(a.dismissCallBack, isNull);

      a.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(ACDDialogQueue.pendingCount, 0);
    });

    testWidgets('clearQueue while showing does not overlap the next enqueue', (
      tester,
    ) async {
      final ACDDialog a = ACDDialog();
      late BuildContext ctx;
      await tester.pumpWidget(
        _host((context) {
          ctx = context;
          a
            ..build(context)
            ..text(text: 'A');
          ACDDialogQueue.enqueue(a);
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      ACDDialogQueue.clearQueue();
      ACDDialogQueue.enqueue(ACDDialog().build(ctx)..text(text: 'C'));
      await tester.pumpAndSettle();
      expect(find.text('C'), findsNothing); // waits for A

      a.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('C'), findsOneWidget);
    });
  });

  group('searchable list', () {
    testWidgets('clearing the query drops an in-flight result', (tester) async {
      final Completer<List<String>> pending = Completer<List<String>>();
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 400,
            child: ACDSearchableListTile<String>(
              items: const ['idle row'],
              multiple: false,
              searchDebounce: Duration.zero,
              onFind: (_) => pending.future,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      pending.complete(['stale row']);
      await tester.pumpAndSettle();
      expect(find.text('stale row'), findsNothing);
      expect(find.text('idle row'), findsOneWidget);
    });

    testWidgets('multi-select without confirm buttons commits each toggle', (
      tester,
    ) async {
      List<String>? committed;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 400,
            child: ACDSearchableListTile<String>(
              items: const ['one', 'two'],
              multiple: true,
              showConfirmCancelButtons: false,
              onMultipleItemsChange: (items) => committed = items,
            ),
          ),
        ),
      );
      await tester.tap(find.text('two'));
      await tester.pump();
      expect(committed, ['two']);
    });

    testWidgets('a short first page loads the next page without scrolling', (
      tester,
    ) async {
      final List<int> requested = [];
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 600,
            child: ACDSearchableListTile<String>(
              items: const [],
              multiple: false,
              onFindPaged: (query, page) async {
                requested.add(page);
                return page < 2 ? ['row $page'] : <String>[];
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(requested, [0, 1, 2]);
      expect(find.text('row 1'), findsOneWidget);
    });
  });

  testWidgets('trigger autocomplete: a caret-only change keeps the pending '
      'search alive', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ACDTriggerAutocompleteField(
          triggers: [
            ACDAutocompleteTrigger(
              trigger: '@',
              optionsBuilder: (q) async => ['alice'],
            ),
          ],
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'hi @al');
    await tester.pump(const Duration(milliseconds: 100));
    // Same text, same caret: a selection-only notification.
    final TextField field = tester.widget(find.byType(TextField));
    field.controller!.selection = const TextSelection.collapsed(offset: 6);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('alice'), findsOneWidget);
  });

  test('ACDStrings has value equality and copyWith', () {
    expect(const ACDStrings(), ACDStrings.english);
    expect(ACDStrings(ok: 'Okay'), ACDStrings(ok: 'Okay'));
    expect(ACDStrings.english.copyWith(ok: 'Ja').ok, 'Ja');
    expect(ACDStrings.english.copyWith(ok: 'Ja').cancel, 'Cancel');
  });
}
