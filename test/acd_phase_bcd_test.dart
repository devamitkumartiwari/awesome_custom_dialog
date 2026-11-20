import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Phases B–D: frame-driven thumbs + fling physics, shared stagger clock,
/// single-pass stepper, OverlayPortal popups, multi-char/caret triggers,
/// toast close reasons, PIN shake, predictive back, indeterminate/wavy
/// loaders, iOS dropdown action sheet / picker.
void main() {
  Widget materialApp(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
  Widget cupertinoApp(Widget child) => CupertinoApp(
    home: CupertinoPageScaffold(child: Center(child: child)),
  );

  group('physics', () {
    // A wide switch (168 px of travel) so position and velocity can
    // disagree. Explicit timestamps: the velocity tracker reads event time,
    // and TestGesture would otherwise stamp every event at zero.
    Future<bool?> dragThenFlick(
      WidgetTester tester, {
      required double slowDx,
      required double flickDx,
    }) async {
      bool? value;
      await tester.pumpWidget(
        materialApp(ACDSwitch(width: 200, onChanged: (v) => value = v)),
      );
      final Rect box = tester.getRect(find.byType(ACDSwitch));
      final TestGesture g = await tester.startGesture(
        Offset(box.left + 20, box.center.dy),
      );
      Duration t = Duration.zero;
      Future<void> move(double dx, int ms) async {
        t += Duration(milliseconds: ms);
        await g.moveBy(Offset(dx, 0), timeStamp: t);
        await tester.pump(Duration(milliseconds: ms));
      }

      for (int i = 0; i < 10; i++) {
        await move(slowDx / 10, 60);
      }
      await move(0, 300); // pause: no residual velocity
      for (int i = 0; i < 5; i++) {
        await move(flickDx / 5, 8);
      }
      await g.up(timeStamp: t);
      await tester.pumpAndSettle();
      return value;
    }

    testWidgets('a fast flick on decides on, even below halfway', (
      tester,
    ) async {
      // Ends ≈ 40 % along, but flung toward "on".
      expect(await dragThenFlick(tester, slowDx: 48, flickDx: 20), isTrue);
    });

    testWidgets('a fast flick back keeps it off, even past halfway', (
      tester,
    ) async {
      // Ends ≈ 60 % along, but flung back toward "off".
      expect(await dragThenFlick(tester, slowDx: 150, flickDx: -25), isNull);
    });

    testWidgets('a slow release goes by position', (tester) async {
      expect(await dragThenFlick(tester, slowDx: 150, flickDx: 0), isTrue);
    });

    testWidgets('a decisive flick from ~half way confirms the slide action', (
      tester,
    ) async {
      int confirmed = 0;
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 280,
            child: ACDSlideAction(onConfirm: () => confirmed++),
          ),
        ),
      );
      final Rect bar = tester.getRect(find.byType(ACDSlideAction));
      await tester.flingFrom(
        Offset(bar.left + 30, bar.center.dy),
        const Offset(110, 0),
        2500,
      );
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(confirmed, 1);
    });

    testWidgets('a slow partial slide springs back without confirming', (
      tester,
    ) async {
      int confirmed = 0;
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 280,
            child: ACDSlideAction(onConfirm: () => confirmed++),
          ),
        ),
      );
      final Rect bar = tester.getRect(find.byType(ACDSlideAction));
      await tester.timedDragFrom(
        Offset(bar.left + 30, bar.center.dy),
        const Offset(80, 0),
        const Duration(milliseconds: 800),
      );
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(confirmed, 0);
    });
  });

  group('shared stagger clock', () {
    testWidgets('no per-item ACDMotion, and scrolled-in items arrive settled', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            height: 300,
            child: ACDStaggeredList(
              itemCount: 50,
              itemBuilder: (context, i) =>
                  SizedBox(height: 50, child: Text('item-$i')),
            ),
          ),
        ),
      );
      expect(find.byType(ACDMotion), findsNothing);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pump(); // first frame after scrolling: no replay
      final Opacity opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('item-25'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('reduce motion settles instantly and still reports done', (
      tester,
    ) async {
      int done = 0;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: materialApp(
            SizedBox(
              height: 300,
              child: ACDStaggeredList(
                itemCount: 5,
                itemBuilder: (context, i) => Text('item-$i'),
                onAllEntranceComplete: () => done++,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(done, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('stepper single-pass layout', () {
    testWidgets('connector runs from the marker to the bottom of a tall row', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 200,
            child: ACDStepper(
              direction: Axis.vertical,
              steps: const [
                'A very long first step title that wraps over lines',
                'Two',
              ],
              activeStep: 0,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(IntrinsicHeight), findsNothing);
      final Rect title = tester.getRect(
        find.textContaining('A very long first'),
      );
      // The first row is taller than the 40 px marker…
      expect(title.height, greaterThan(40));
      // …and the second marker starts right below it (no overlap).
      final Rect second = tester.getRect(find.text('2'));
      expect(second.top, greaterThanOrEqualTo(title.bottom - 1));
    });
  });

  group('trigger field', () {
    Future<List<Object?>> emoji(String q) async =>
        ['smile', 'sad'].where((e) => e.startsWith(q)).toList();
    Future<List<Object?>> tags(String q) async =>
        ['soccer'].where((e) => e.startsWith(q)).toList();

    testWidgets('the longest trigger wins (:: over :)', (tester) async {
      ACDAutocompleteTrigger? used;
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 300,
            child: ACDTriggerAutocompleteField(
              searchDebounce: Duration.zero,
              triggers: [
                ACDAutocompleteTrigger(trigger: ':', optionsBuilder: tags),
                ACDAutocompleteTrigger(trigger: '::', optionsBuilder: emoji),
              ],
              onOptionSelected: (t, _) => used = t,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '::sm');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.text('smile'), findsOneWidget);
      await tester.tap(find.text('smile'));
      await tester.pump();
      expect(used?.trigger, '::');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'smile ',
      );
    });

    testWidgets('caret anchor follows the trigger horizontally', (
      tester,
    ) async {
      Future<List<Object?>> people(String q) async => ['alice'];
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 400,
            child: ACDTriggerAutocompleteField(
              searchDebounce: Duration.zero,
              popupAnchor: ACDPopupAnchor.caret,
              popupWidthFactor: 0.4,
              triggers: [
                ACDAutocompleteTrigger(trigger: '@', optionsBuilder: people),
              ],
            ),
          ),
        ),
      );
      Future<double> popupLeft(String text) async {
        await tester.enterText(find.byType(TextField), text);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));
        await tester.pump();
        return tester.getTopLeft(find.text('alice')).dx;
      }

      final double near = await popupLeft('@a');
      final double far = await popupLeft('hello there @a');
      expect(far, greaterThan(near + 40));
    });

    testWidgets('arrow keys + Enter pick an option', (tester) async {
      Object? picked;
      Future<List<Object?>> people(String q) async => ['alice', 'albert'];
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 300,
            child: ACDTriggerAutocompleteField(
              searchDebounce: Duration.zero,
              triggers: [
                ACDAutocompleteTrigger(trigger: '@', optionsBuilder: people),
              ],
              onOptionSelected: (_, o) => picked = o,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '@a');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, 'albert');
    });
  });

  group('autocomplete OverlayPortal', () {
    testWidgets('popup inherits the field theme and Esc closes it', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 300,
            child: Theme(
              data: ThemeData(
                textTheme: const TextTheme(bodyLarge: TextStyle(fontSize: 31)),
              ),
              child: const ACDAutocompleteField<String>(
                suggestions: ['apple', 'apricot'],
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pump();
      expect(find.text('apple'), findsOneWidget);
      // Built under the field (not the root overlay): the local theme flows
      // into the popup.
      expect(
        Theme.of(tester.element(find.text('apple')))
            .textTheme
            .bodyLarge
            ?.fontSize,
        31,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('apple'), findsNothing);
    });
  });

  group('toast closed reasons', () {
    tearDown(() {
      ACDToastManager.dismissAll();
      ACDToastManager.clearDefaults();
    });

    Future<ACDDialog> open(
      WidgetTester tester, {
      Duration? showDuration,
      ACDToastCloseButtonMode? closeMode,
      String message = 'Saved',
    }) async {
      late ACDDialog dialog;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => (dialog = ACDDialog.toast(
                  context: context,
                  message: message,
                  showDuration: showDuration,
                  closeButtonMode: closeMode,
                )).show(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      return dialog;
    }

    Future<void> settle(WidgetTester tester) async {
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('timeout', (tester) async {
      final ACDDialog toast = await open(tester);
      ACDToastDismissReason? reason;
      toast.toastClosed!.then((r) => reason = r);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 400));
      expect(reason, ACDToastDismissReason.timeout);
    });

    testWidgets('programmatic', (tester) async {
      final ACDDialog toast = await open(tester, showDuration: Duration.zero);
      ACDToastDismissReason? reason;
      toast.toastClosed!.then((r) => reason = r);
      await toast.dismiss();
      await settle(tester);
      expect(reason, ACDToastDismissReason.programmatic);
    });

    testWidgets('user (close button)', (tester) async {
      final ACDDialog toast = await open(
        tester,
        showDuration: Duration.zero,
        closeMode: ACDToastCloseButtonMode.always,
      );
      ACDToastDismissReason? reason;
      toast.toastClosed!.then((r) => reason = r);
      await tester.tap(find.bySemanticsLabel('Close'));
      await settle(tester);
      expect(reason, ACDToastDismissReason.user);
    });

    testWidgets('replaced by a newer toast', (tester) async {
      final ACDDialog first = await open(tester, showDuration: Duration.zero);
      ACDToastDismissReason? reason;
      first.toastClosed!.then((r) => reason = r);
      await tester.tap(find.text('Open'));
      await settle(tester);
      expect(reason, ACDToastDismissReason.replaced);
    });
  });

  group('PIN error shake', () {
    double shakeOffset(WidgetTester tester) {
      final Iterable<Transform> transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(ACDPinField),
          matching: find.byType(Transform),
        ),
      );
      double maxDx = 0;
      for (final Transform t in transforms) {
        final double dx = t.transform.getTranslation().x.abs();
        if (dx > maxDx) maxDx = dx;
      }
      return maxDx;
    }

    Widget pin({String? error}) =>
        ACDPinField(length: 4, forceErrorText: error);

    testWidgets('shakes once when an error appears', (tester) async {
      await tester.pumpWidget(materialApp(pin()));
      await tester.pumpWidget(materialApp(pin(error: 'Wrong PIN')));
      await tester.pump(); // post-frame start
      await tester.pump(const Duration(milliseconds: 30));
      expect(shakeOffset(tester), greaterThan(0.5));
      await tester.pump(const Duration(milliseconds: 500));
      expect(shakeOffset(tester), lessThan(0.01));
    });

    testWidgets('no shake under reduce motion', (tester) async {
      Widget app(String? error) => MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: materialApp(pin(error: error)),
      );
      await tester.pumpWidget(app(null));
      await tester.pumpWidget(app('Wrong PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      expect(shakeOffset(tester), lessThan(0.01));
    });

    testWidgets('keeps focus while shaking', (tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      Widget build(String? error) => materialApp(
        ACDPinField(length: 4, focusNode: node, forceErrorText: error),
      );
      await tester.pumpWidget(build(null));
      node.requestFocus();
      await tester.pump();
      await tester.pumpWidget(build('Wrong PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(node.hasFocus, isTrue);
    });
  });

  group('predictive back', () {
    Future<void> backGesture(
      WidgetTester tester,
      String method, [
      double progress = 0,
    ]) async {
      final ByteData message = const StandardMethodCodec().encodeMethodCall(
        MethodCall(method, <String, Object?>{
          'touchOffset': <double>[5.0, 300.0],
          'progress': progress,
          'swipeEdge': 0, // left
        }),
      );
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/backgesture',
        message,
        (_) {},
      );
      await tester.pump();
    }

    testWidgets('dialog shrinks while swiping and closes on commit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  (ACDDialog().build(context)..text(text: 'Hello')).show(),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);

      await backGesture(tester, 'startBackGesture');
      await backGesture(tester, 'updateBackGestureProgress', 0.5);
      final Transform scale = tester
          .widgetList<Transform>(
            find.ancestor(
              of: find.text('Hello'),
              matching: find.byType(Transform),
            ),
          )
          .firstWhere((t) => t.transform.storage[0] < 0.999);
      // ~0.93 at half progress (eased), never below the 0.9 floor.
      expect(scale.transform.storage[0], inInclusiveRange(0.9, 0.99));

      await backGesture(tester, 'commitBackGesture');
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('canPop: false keeps the dialog open', (tester) async {
      bool? didPop;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  (ACDDialog().build(context)
                        ..canPop = false
                        ..onPopInvoked = ((bool popped, _) => didPop = popped)
                        ..text(text: 'Stay'))
                      .show(),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final NavigatorState nav = tester.state(find.byType(Navigator));
      await nav.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Stay'), findsOneWidget);
      expect(didPop, isFalse);
    });
  });

  group('loaders', () {
    testWidgets('indeterminate linear: "Loading", no value, keeps moving', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          const SizedBox(
            width: 200,
            child: ACDLinearPercentIndicator(indeterminate: true),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('wavy linear freezes under reduce motion', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: materialApp(
            const SizedBox(
              width: 200,
              child: ACDLinearPercentIndicator(
                value: 0.6,
                style: ACDLoaderStyle.wavy,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.bySemanticsLabel(RegExp('')), findsWidgets);
    });

    testWidgets('indeterminate circular is the iOS spinner under Cupertino', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertinoApp(
          const ACDCircularPercentIndicator(
            radius: 30,
            indeterminate: true,
            design: ACDDesign.cupertino,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('wavy circular renders and reports its value', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const ACDCircularPercentIndicator(
            radius: 30,
            value: 0.4,
            style: ACDLoaderStyle.wavy,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(RegExp('')), findsWidgets);
    });
  });

  group('dropdown iOS modes', () {
    testWidgets('action sheet in a bare CupertinoApp picks an item', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        cupertinoApp(
          SizedBox(
            width: 320,
            child: ACDDropdownField<String>(
              design: ACDDesign.cupertino,
              mode: ACDDropdownMode.actionSheet,
              items: const ['Red', 'Green', 'Blue'],
              onChanged: (v) => picked = v,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ACDDropdownField<String>));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      await tester.tap(find.text('Green'));
      await tester.pumpAndSettle();
      expect(picked, 'Green');
      expect(find.byType(CupertinoActionSheet), findsNothing);
    });

    testWidgets('multi-select action sheet toggles then commits on Done', (
      tester,
    ) async {
      List<String>? picked;
      await tester.pumpWidget(
        cupertinoApp(
          SizedBox(
            width: 320,
            child: ACDMultiDropdownField<String>(
              design: ACDDesign.cupertino,
              mode: ACDDropdownMode.adaptive,
              items: const ['Red', 'Green', 'Blue'],
              onChanged: (v) => picked = v,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ACDMultiDropdownField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Red'));
      await tester.pump();
      await tester.tap(find.text('Blue'));
      await tester.pump();
      expect(picked, isNull); // not until Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(picked, ['Red', 'Blue']);
    });

    testWidgets('picker commits the wheel value on Done', (tester) async {
      String? picked;
      await tester.pumpWidget(
        cupertinoApp(
          SizedBox(
            width: 320,
            child: ACDDropdownField<String>(
              design: ACDDesign.cupertino,
              mode: ACDDropdownMode.picker,
              items: const ['One', 'Two', 'Three'],
              onChanged: (v) => picked = v,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ACDDropdownField<String>));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoPicker), findsOneWidget);
      await tester.drag(
        find.byType(CupertinoPicker),
        const Offset(0, -50),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(picked, 'Two');
    });

    testWidgets('iOS modes fall back to a sheet under Material', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 320,
            child: ACDDropdownField<String>(
              mode: ACDDropdownMode.actionSheet,
              items: const ['Red', 'Green'],
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ACDDropdownField<String>));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.byType(CupertinoActionSheet), findsNothing);
      expect(find.text('Green'), findsOneWidget);
    });

    testWidgets('Material menu mode opens anchored and Esc closes it', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 320,
            child: ACDDropdownField<String>(
              mode: ACDDropdownMode.menu,
              items: const ['Red', 'Green'],
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ACDDropdownField<String>));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Green'), findsOneWidget);
      final Rect field = tester.getRect(find.byType(ACDDropdownField<String>));
      expect(
        tester.getTopLeft(find.text('Green')).dy,
        greaterThan(field.bottom - 1),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Green'), findsNothing);
    });
  });
}
