import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Phase 3: ACDDialog (card, buttons, presets, lists, small widgets,
/// actions/showForResult), toast and snackbar across designs.
void main() {
  Widget cupertinoHost(void Function(BuildContext) onOpen) => CupertinoApp(
    home: CupertinoPageScaffold(
      child: Center(
        child: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => onOpen(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );

  Widget materialHost(void Function(BuildContext) onOpen) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => onOpen(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );

  tearDown(ACDToastManager.dismissAll);

  group('ACDDialog in a bare CupertinoApp (design: cupertino)', () {
    testWidgets('presets, buttons, text field, lists render natively', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertinoHost((context) {
          ACDDialog(design: ACDDesign.cupertino).build(context)
            ..success(title: 'Saved', message: 'All good')
            ..acdTextField(hint: 'Name')
            ..acdProgress()
            ..acdDivider()
            ..twoButton(text1: 'No', text2: 'Yes')
            ..listOfACDRadioButton(
              items: const [
                ACDRadioItem(text: 'A'),
                ACDRadioItem(text: 'B'),
              ],
              initialValue: 0,
            )
            ..show();
        }),
      );
      await tester.tap(find.text('Open'));
      // Fixed pumps: the activity indicator spins forever, so the tree
      // never "settles".
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      // Single-choice iOS list: selection is a trailing checkmark.
      expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
    });

    testWidgets('design set *after* builder calls still applies', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertinoHost((context) {
          final ACDDialog dialog = ACDDialog().build(context)
            ..oneButton(text: 'Fine');
          dialog
            ..design = ACDDesign.cupertino
            ..show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsNothing);
      expect(
        find.ancestor(
          of: find.text('Fine'),
          matching: find.byType(CupertinoButton),
        ),
        findsOneWidget,
      );
    });
  });

  group('actions() + showForResult()', () {
    for (final ACDDesign design in ACDDesign.values) {
      testWidgets('returns the chosen action value ($design)', (tester) async {
        Future<bool?>? result;
        await tester.pumpWidget(
          materialHost((context) {
            result =
                (ACDDialog(design: design).build(context)
                      ..text(text: 'Delete?')
                      ..actions(const [
                        ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
                        ACDAction(
                          label: 'Delete',
                          role: ACDActionRole.destructive,
                          value: true,
                        ),
                      ]))
                    .showForResult<bool>();
          }),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(await result, isTrue);
        expect(find.text('Delete?'), findsNothing);
      });
    }

    testWidgets('completes with null when dismissed via the barrier', (
      tester,
    ) async {
      Future<String?>? result;
      await tester.pumpWidget(
        materialHost((context) {
          result =
              (ACDDialog().build(context)
                    ..text(text: 'Pick')
                    ..actions(const [ACDAction(label: 'A', value: 'a')]))
                  .showForResult<String>();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5)); // barrier
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('Material actions: primary is a FilledButton', (tester) async {
      await tester.pumpWidget(
        materialHost((context) {
          (ACDDialog().build(context)..actions(const [
                ACDAction(label: 'Later'),
                ACDAction(label: 'Update', role: ACDActionRole.primary),
              ]))
              .show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.ancestor(
          of: find.text('Update'),
          matching: find.byType(FilledButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Cupertino actions: >2 actions stack vertically', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertinoHost((context) {
          (ACDDialog(design: ACDDesign.cupertino).build(context)
                ..actions(const [
                  ACDAction(label: 'One'),
                  ACDAction(label: 'Two'),
                  ACDAction(label: 'Three', role: ACDActionRole.cancel),
                ]))
              .show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoButton), findsWidgets);
      expect(find.byType(TextButton), findsNothing);
      final double y1 = tester.getCenter(find.text('One')).dy;
      final double y2 = tester.getCenter(find.text('Two')).dy;
      expect(y2, greaterThan(y1));
    });
  });

  testWidgets('Material default: card is still a transparent Material and '
      'buttons are TextButtons', (tester) async {
    await tester.pumpWidget(
      materialHost((context) {
        ACDDialog().build(context)
          ..text(text: 'Hi')
          ..oneButton(text: 'OK')
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      find.ancestor(of: find.text('OK'), matching: find.byType(TextButton)),
      findsOneWidget,
    );
    expect(find.byType(CupertinoButton), findsNothing);
  });

  testWidgets('reduce motion: preset animations become a plain fade', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: materialHost((context) {
          ACDDialog().build(context)
            ..animation = ACDAnimation.rotate
            ..text(text: 'Calm')
            ..show();
        }),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.ancestor(
        of: find.text('Calm'),
        matching: find.byType(RotationTransition),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });

  group('toast & snackbar', () {
    testWidgets('Cupertino toast renders the iOS HUD without Material', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertinoHost((context) {
          ACDDialog.toast(
            context: context,
            message: 'Copied',
            design: ACDDesign.cupertino,
            showDuration: const Duration(seconds: 1),
          ).show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('Copied'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('Copied'), matching: find.byType(Material)),
        findsNothing,
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('snackbar close button works without a ScaffoldMessenger', (
      tester,
    ) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 400,
              child: ACDSnackbarContent(
                title: 'Hi',
                message: 'There',
                design: ACDDesign.cupertino,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(CupertinoIcons.xmark));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
