// New in 2.1: loading dialog, promise/undo toasts, live toast updates,
// toast gestures, bottom sheet, form-field wrappers, resend countdown and
// the searchable-list/dropdown upgrades.
import 'dart:async';

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:awesome_custom_dialog/src/core/acd_sheet_drag.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

late BuildContext _ctx;

Widget _app({Widget? body}) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) {
        _ctx = context;
        return body ?? const SizedBox.expand();
      },
    ),
  ),
);

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  tearDown(() {
    ACDToastManager.resetForTest();
    ACDDialogQueue.reset();
  });

  group('ACDDialog.loading', () {
    testWidgets('shows while working and returns the value', (tester) async {
      await tester.pumpWidget(_app());
      final Completer<int> work = Completer<int>();
      final Future<int> result = ACDDialog.loading(
        context: _ctx,
        future: work.future,
        message: 'Signing in',
        minDisplay: Duration.zero,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Signing in'), findsOneWidget);

      work.complete(42);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(await result, 42);
      expect(find.text('Signing in'), findsNothing);
    });

    testWidgets('rethrows the error and closes', (tester) async {
      await tester.pumpWidget(_app());
      final Future<int> result = ACDDialog.loading(
        context: _ctx,
        future: Future<int>.error(StateError('nope')),
        message: 'Working',
        minDisplay: Duration.zero,
      );
      Object? caught;
      unawaited(result.then<void>((_) {}, onError: (Object e) => caught = e));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(caught, isA<StateError>());
      expect(find.text('Working'), findsNothing);
    });

    testWidgets('fast work never shows a dialog with showAfter', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      final Future<String> result = ACDDialog.loading(
        context: _ctx,
        future: Future<String>.delayed(
          const Duration(milliseconds: 50),
          () => 'ok',
        ),
        message: 'Hidden',
        showAfter: const Duration(milliseconds: 300),
      );
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Hidden'), findsNothing);
      await tester.pumpAndSettle();
      expect(await result, 'ok');
    });

    testWidgets('cancel throws ACDLoadingCanceled', (tester) async {
      await tester.pumpWidget(_app());
      final Future<int> result = ACDDialog.loading(
        context: _ctx,
        future: Completer<int>().future, // never completes
        cancelable: true,
        minDisplay: Duration.zero,
      );
      Object? caught;
      unawaited(result.then<void>((_) {}, onError: (Object e) => caught = e));
      // A spinner never settles: pump fixed frames instead of pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(caught, isA<ACDLoadingCanceled>());
    });
  });

  group('toasts', () {
    testWidgets('promiseToast turns into the success message in place', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      final Completer<int> work = Completer<int>();
      final Future<int> result = ACDDialog.promiseToast<int>(
        context: _ctx,
        future: work.future,
        loading: 'Saving',
        success: (n) => 'Saved $n',
        error: (_) => 'Failed',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // entrance
      expect(find.text('Saving'), findsOneWidget);
      expect(ACDToastManager.activeCount(), 1);

      work.complete(3);
      await tester.pump();
      await tester.pump();
      expect(find.text('Saved 3'), findsOneWidget);
      expect(ACDToastManager.activeCount(), 1); // same toast, updated
      expect(await result, 3);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Saved 3'), findsNothing);
    });

    testWidgets('promiseToast shows the error and rethrows', (tester) async {
      await tester.pumpWidget(_app());
      Object? caught;
      unawaited(
        ACDDialog.promiseToast<int>(
          context: _ctx,
          future: Future<int>.error(Exception('x')),
          loading: 'Saving',
          success: (_) => 'Saved',
          error: (_) => 'Could not save',
        ).catchError((Object e) {
          caught = e;
          return 0;
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('Could not save'), findsOneWidget);
      expect(caught, isA<Exception>());
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('undoToast completes true when Undo is tapped', (tester) async {
      await tester.pumpWidget(_app());
      int undos = 0;
      final Future<bool> undone = ACDDialog.undoToast(
        context: _ctx,
        message: 'Deleted',
        onUndo: () => undos++,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // entrance only
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(await undone, isTrue);
      expect(undos, 1);
    });

    testWidgets('undoToast completes false after the window', (tester) async {
      await tester.pumpWidget(_app());
      final Future<bool> undone = ACDDialog.undoToast(
        context: _ctx,
        message: 'Deleted',
        duration: const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(await undone, isFalse);
    });

    testWidgets('a bottom toast can be flicked down', (tester) async {
      await tester.pumpWidget(_app());
      final ACDToastController toast = ACDToastManager.show(
        _ctx,
        const ACDToastConfig(
          message: 'Swipe me',
          gravity: ACDGravity.bottom,
          dragToDismiss: true,
          autoDismissAfter: Duration.zero,
        ),
      );
      await tester.pumpAndSettle();
      await tester.fling(find.text('Swipe me'), const Offset(0, 300), 1500);
      await tester.pumpAndSettle();
      expect(find.text('Swipe me'), findsNothing);
      expect(await toast.closed, ACDToastDismissReason.swipe);
    });
  });

  group('bottom sheet', () {
    testWidgets('shows docked to the bottom and returns a result', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      final ACDDialog sheet = ACDDialog.bottomSheet(context: _ctx)
        ..text(text: 'Share to');
      final Future<String?> result = sheet.showForResult<String>();
      await tester.pumpAndSettle();
      expect(find.text('Share to'), findsOneWidget);
      final Rect r = tester.getRect(find.byType(ACDSheetDrag));
      expect(r.bottom, closeTo(600, 1)); // flush with the screen bottom
      expect(r.width, closeTo(800, 1)); // full width

      sheet
        ..setResult('mail')
        ..dismiss();
      await tester.pumpAndSettle();
      expect(await result, 'mail');
    });

    testWidgets('dragging it down closes it', (tester) async {
      await tester.pumpWidget(_app());
      ACDDialog.bottomSheet(context: _ctx)
        ..text(text: 'Drag me', padding: const EdgeInsets.all(40))
        ..show();
      await tester.pumpAndSettle();
      await tester.fling(find.text('Drag me'), const Offset(0, 400), 2000);
      await tester.pumpAndSettle();
      expect(find.text('Drag me'), findsNothing);
    });

    testWidgets('canPop: false disables drag-to-dismiss', (tester) async {
      await tester.pumpWidget(_app());
      ACDDialog.bottomSheet(context: _ctx)
        ..canPop = false
        ..text(text: 'Stay', padding: const EdgeInsets.all(40))
        ..show();
      await tester.pumpAndSettle();
      await tester.fling(find.text('Stay'), const Offset(0, 400), 2000);
      await tester.pumpAndSettle();
      expect(find.text('Stay'), findsOneWidget);
    });
  });

  group('form fields', () {
    testWidgets('ACDSwitchFormField validates and resets', (tester) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      bool? saved;
      await tester.pumpWidget(
        _wrap(
          Form(
            key: form,
            child: ACDSwitchFormField(
              title: const Text('Terms'),
              validator: (v) => v == true ? null : 'Please accept',
              onSaved: (v) => saved = v,
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Please accept'), findsOneWidget);

      await tester.tap(find.byType(ACDSwitch));
      await tester.pumpAndSettle();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, isTrue);

      form.currentState!.reset();
      await tester.pumpAndSettle();
      form.currentState!.save();
      expect(saved, isFalse);
    });

    testWidgets('ACDRatingFormField validates', (tester) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _wrap(
          Form(
            key: form,
            child: ACDRatingFormField(
              validator: (r) => (r ?? 0) == 0 ? 'Rate us' : null,
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Rate us'), findsOneWidget);
      await tester.tapAt(
        tester.getTopLeft(find.byType(ACDRatingBar)) + const Offset(10, 16),
      );
      await tester.pump();
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('ACDAutocompleteFormField: picking sets the value, typing '
        'clears it, reset restores', (tester) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      String? saved;
      await tester.pumpWidget(
        _wrap(
          Form(
            key: form,
            child: ACDAutocompleteFormField<String>(
              suggestions: const ['France', 'Finland'],
              validator: (c) => c == null ? 'Pick one' : null,
              onSaved: (c) => saved = c,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Fra');
      await tester.pumpAndSettle();
      await tester.tap(find.text('France').last);
      await tester.pumpAndSettle();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, 'France');

      await tester.enterText(find.byType(TextField), 'Fran');
      await tester.pump();
      expect(form.currentState!.validate(), isFalse);

      form.currentState!.reset();
      await tester.pump();
      final TextField field = tester.widget(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });
  });

  testWidgets('ACDResendCountdown counts down, then resends and restarts', (
    tester,
  ) async {
    int sends = 0;
    await tester.pumpWidget(
      _wrap(
        ACDResendCountdown(
          duration: const Duration(seconds: 3),
          onResend: () => sends++,
        ),
      ),
    );
    expect(find.text('Resend code (0:03)'), findsOneWidget);
    await tester.tap(find.byType(ACDResendCountdown));
    expect(sends, 0); // still waiting

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Resend code'), findsOneWidget);
    await tester.tap(find.byType(ACDResendCountdown));
    await tester.pump();
    expect(sends, 1);
    expect(find.text('Resend code (0:03)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  group('ACDPinController', () {
    testWidgets('clear() wipes the cells and re-arms onCompleted', (
      tester,
    ) async {
      final ACDPinController pin = ACDPinController();
      addTearDown(pin.dispose);
      final List<String> completed = [];
      await tester.pumpWidget(
        _wrap(
          ACDPinField(length: 4, controller: pin, onCompleted: completed.add),
        ),
      );
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();
      expect(pin.isComplete, isTrue);

      pin.clear();
      await tester.pump();
      // Let the digits' exit transition finish (the caret keeps blinking,
      // so pumpAndSettle would never settle).
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('1'), findsNothing);
      expect(pin.isComplete, isFalse);

      await tester.enterText(find.byType(TextField), '5678');
      await tester.pump();
      expect(completed, ['1234', '5678']);
    });

    testWidgets('setCode() fills the field, trims to length and completes', (
      tester,
    ) async {
      final ACDPinController pin = ACDPinController();
      addTearDown(pin.dispose);
      String? completed;
      await tester.pumpWidget(
        _wrap(
          ACDPinField(
            length: 4,
            controller: pin,
            onCompleted: (c) => completed = c,
          ),
        ),
      );
      pin.setCode('987654');
      await tester.pump();
      expect(pin.text, '9876');
      expect(completed, '9876');
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('focus() and unfocus() drive the field', (tester) async {
      final ACDPinController pin = ACDPinController();
      addTearDown(pin.dispose);
      await tester.pumpWidget(_wrap(ACDPinField(length: 4, controller: pin)));
      pin.focus();
      await tester.pump();
      final EditableText editable = tester.widget(find.byType(EditableText));
      expect(editable.focusNode.hasFocus, isTrue);

      pin.unfocus();
      await tester.pump();
      expect(editable.focusNode.hasFocus, isFalse);
    });

    test('helpers are safe with no field attached', () {
      final ACDPinController pin = ACDPinController(text: '12');
      pin
        ..focus()
        ..unfocus()
        ..setCode('123456');
      expect(pin.text, '123456'); // no field: nothing to trim against
      expect(pin.isComplete, isFalse);
      pin.dispose();
    });
  });

  group('searchable list upgrades', () {
    Widget list({
      List<String> items = const ['a', 'b', 'c'],
      bool multiple = true,
      int? maxSelection,
      bool showSelectAll = false,
      String Function(String)? groupBy,
      ValueChanged<List<String>>? onMulti,
      Future<List<String>> Function(String)? onFind,
      bool cacheResults = false,
      Future<String?> Function(String)? onCreate,
      ValueChanged<String?>? onSingle,
    }) => _wrap(
      SizedBox(
        height: 500,
        child: ACDSearchableListTile<String>(
          items: items,
          multiple: multiple,
          maxSelection: maxSelection,
          showSelectAll: showSelectAll,
          groupBy: groupBy,
          showConfirmCancelButtons: false,
          onMultipleItemsChange: onMulti,
          onChange: onSingle,
          onFind: onFind,
          cacheResults: cacheResults,
          onCreate: onCreate,
          searchDebounce: Duration.zero,
        ),
      ),
    );

    testWidgets('maxSelection stops further picks', (tester) async {
      List<String>? picked;
      await tester.pumpWidget(
        list(maxSelection: 2, onMulti: (v) => picked = v),
      );
      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('b'));
      await tester.pump();
      await tester.tap(find.text('c'));
      await tester.pump();
      expect(picked, ['a', 'b']);
    });

    testWidgets('select all toggles every row', (tester) async {
      List<String>? picked;
      await tester.pumpWidget(
        list(showSelectAll: true, onMulti: (v) => picked = v),
      );
      await tester.tap(find.text('Select all'));
      await tester.pump();
      expect(picked, unorderedEquals(['a', 'b', 'c']));
      await tester.tap(find.text('Select all'));
      await tester.pump();
      expect(picked, isEmpty);
    });

    testWidgets('groupBy adds section headers', (tester) async {
      await tester.pumpWidget(
        list(
          items: const ['apple', 'avocado', 'banana'],
          groupBy: (s) => s[0].toUpperCase(),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('cacheResults asks onFind once per query', (tester) async {
      int calls = 0;
      await tester.pumpWidget(
        list(
          multiple: false,
          cacheResults: true,
          onFind: (q) async {
            calls++;
            return ['$q!'];
          },
        ),
      );
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xy');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('x!'), findsOneWidget);
    });

    testWidgets('onCreate adds and selects a new item', (tester) async {
      String? picked;
      await tester.pumpWidget(
        list(
          multiple: false,
          onSingle: (v) => picked = v,
          onCreate: (q) async => q.toUpperCase(),
        ),
      );
      await tester.enterText(find.byType(TextField), 'zed');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create "zed"'));
      await tester.pumpAndSettle();
      expect(picked, 'ZED');
    });
  });
}
