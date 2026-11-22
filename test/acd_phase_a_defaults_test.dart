import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// 2.0 default changes: 48 dp / 44 pt tap targets, warning contrast,
/// multi-select chips — plus the rating-bar rect-based hit-testing fix.
void main() {
  Widget materialApp(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  double contrast(Color a, Color b) {
    final double la = a.computeLuminance();
    final double lb = b.computeLuminance();
    final double hi = la > lb ? la : lb;
    final double lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  group('warning contrast', () {
    test('snackbar warning colour passes WCAG AA with white text', () {
      expect(
        contrast(ACDContentType.warning.color, Colors.white),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('Material warning preset icon uses the contrast-safe token', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => (ACDDialog().build(
                context,
              )..warning(title: 'Careful', message: 'Heads up')).show(),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 600));
      final Icon icon = tester.widget<Icon>(find.byIcon(Icons.warning_rounded));
      // Light theme surface is near-white: an icon needs ≥ 3:1.
      expect(contrast(icon.color!, Colors.white), greaterThanOrEqualTo(3.0));
    });
  });

  group('tap targets', () {
    testWidgets('toast close button is 48 dp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ACDDialog.toast(
                  context: context,
                  message: 'Saved',
                  showDuration: Duration.zero,
                  closeButtonMode: ACDToastCloseButtonMode.always,
                ).show(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final Finder close = find.bySemanticsLabel('Close');
      expect(close, findsOneWidget);
      final Size size = tester.getSize(close);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      ACDToastManager.dismissAll();
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('snackbar close button is 48 dp and still dismisses', (
      tester,
    ) async {
      int closed = 0;
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 360,
            child: ACDSnackbarContent(
              title: 'Hi',
              message: 'There',
              contentType: ACDContentType.help,
              onClose: () => closed++,
            ),
          ),
        ),
      );
      final Finder button = find.byType(IconButton);
      final Size size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      await tester.tap(button);
      expect(closed, 1);
    });

    testWidgets('dropdown clear button is 48 dp and clears', (tester) async {
      String? value = 'b';
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 300,
            child: ACDDropdownField<String>(
              items: const ['a', 'b'],
              initialValue: 'b',
              showClearButton: true,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );
      final Finder clear = find.bySemanticsLabel('Clear');
      final Size size = tester.getSize(clear);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      await tester.tap(clear);
      await tester.pump();
      expect(value, isNull);
    });

    testWidgets('switch has a 48 dp touch height (track keeps its size)', (
      tester,
    ) async {
      await tester.pumpWidget(materialApp(const ACDSwitch()));
      expect(tester.getSize(find.byType(ACDSwitch)).height, 48);
    });

    testWidgets('small rating stars get a 48 dp touch band', (tester) async {
      await tester.pumpWidget(materialApp(ACDRatingBar(itemSize: 20)));
      expect(tester.getSize(find.byType(ACDRatingBar)).height, 48);
    });

    testWidgets('tappable stepper markers are 48 dp; display-only are not', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          ACDStepper(
            steps: const ['One', 'Two'],
            activeStep: 0,
            onStepReached: (_) {},
          ),
        ),
      );
      final Finder marker = find.bySemanticsLabel(RegExp('Step 1 of 2'));
      expect(tester.getSize(marker).height, greaterThanOrEqualTo(48));

      await tester.pumpWidget(
        materialApp(ACDStepper(steps: const ["One", "Two"], activeStep: 0)),
      );
      expect(
        tester.getSize(find.bySemanticsLabel(RegExp('Step 1 of 2'))).height,
        lessThan(48),
      );
    });
  });

  group('rating hit-testing', () {
    testWidgets('a tap in the gap after star 2 rates 2 (spacing honoured)', (
      tester,
    ) async {
      double? rating;
      await tester.pumpWidget(
        materialApp(
          ACDRatingBar(
            itemSize: 20,
            itemSpacing: 20,
            onRatingUpdate: (r) => rating = r,
          ),
        ),
      );
      final Rect bar = tester.getRect(find.byType(ACDRatingBar));
      // Stars at x = 0..20, 40..60, 80..100 … — x = 75 is the gap after #2.
      // The old even-split math would have said 75 / 180 × 5 → 3.
      await tester.tapAt(Offset(bar.left + 75, bar.center.dy));
      await tester.pump(const Duration(milliseconds: 400));
      expect(rating, 2);

      await tester.tapAt(Offset(bar.left + 81, bar.center.dy));
      await tester.pump(const Duration(milliseconds: 400));
      expect(rating, 3);
    });
  });

  group('multi-select chips (2.0 default)', () {
    testWidgets('shows chips, collapses the rest into +N, removes on delete', (
      tester,
    ) async {
      List<String>? changed;
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 400,
            child: ACDMultiDropdownField<String>(
              items: const ['a', 'b', 'c', 'd', 'e'],
              initialValue: const ['a', 'b', 'c', 'd', 'e'],
              onChanged: (v) => changed = v,
            ),
          ),
        ),
      );
      expect(find.byType(InputChip), findsNWidgets(3));
      expect(find.text('+2'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove a'));
      await tester.pump();
      expect(changed, ['b', 'c', 'd', 'e']);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('displayMode.text restores the comma-joined value', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 400,
            child: ACDMultiDropdownField<String>(
              items: const ['a', 'b'],
              initialValue: const ['a', 'b'],
              displayMode: ACDMultiDisplay.text,
            ),
          ),
        ),
      );
      expect(find.byType(InputChip), findsNothing);
      expect(find.text('a, b'), findsOneWidget);
    });

    testWidgets('Cupertino pills in a bare CupertinoApp, 44 pt remove', (
      tester,
    ) async {
      List<String>? changed;
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: SizedBox(
                width: 400,
                child: ACDMultiDropdownField<String>(
                  design: ACDDesign.cupertino,
                  items: const ['a', 'b'],
                  initialValue: const ['a', 'b'],
                  onChanged: (v) => changed = v,
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final Finder remove = find.bySemanticsLabel('Remove b');
      expect(tester.getSize(remove), const Size(44, 44));
      await tester.tap(remove);
      await tester.pump();
      expect(changed, ['a']);
    });
  });
}
