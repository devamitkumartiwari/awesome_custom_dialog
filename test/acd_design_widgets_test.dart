import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Phases 4–5: switch, slide action, rating, stepper, loaders, motion —
/// design variants, accessibility, keyboard and reduce-motion.
void main() {
  Widget materialApp(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
  Widget cupertinoApp(Widget child) => CupertinoApp(
    home: CupertinoPageScaffold(child: Center(child: child)),
  );

  group('bare CupertinoApp', () {
    testWidgets('ACDStepper with tappable markers no longer crashes', (
      tester,
    ) async {
      int? tapped;
      await tester.pumpWidget(
        cupertinoApp(
          ACDStepper(
            design: ACDDesign.cupertino,
            steps: const ['One', 'Two', 'Three'],
            activeStep: 1,
            onStepReached: (i) => tapped = i,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(InkWell), findsNothing);
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(tapped, 2);
    });

    testWidgets('ACDStepper default (Material) is also safe there', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertinoApp(
          ACDStepper(
            steps: const ['One', 'Two'],
            activeStep: 0,
            onStepReached: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Cupertino switch defaults to the iOS palette', (tester) async {
      await tester.pumpWidget(
        cupertinoApp(
          ACDSwitch(design: ACDDesign.cupertino, initialValue: true),
        ),
      );
      expect(tester.takeException(), isNull);
      final Iterable<Color?> fills = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(ACDSwitch),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map(
            (d) => switch (d.decoration) {
              final BoxDecoration b => b.color,
              final ShapeDecoration s => s.color,
              _ => null,
            },
          );
      expect(fills, contains(CupertinoColors.systemGreen.color));
    });

    testWidgets('Cupertino rating uses Cupertino star glyphs', (tester) async {
      await tester.pumpWidget(
        cupertinoApp(
          ACDRatingBar(design: ACDDesign.cupertino, initialRating: 2),
        ),
      );
      expect(find.byIcon(CupertinoIcons.star_fill), findsWidgets);
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });

  group('accessibility & keyboard', () {
    testWidgets('switch: toggled semantics + Space toggles', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool value = false;
      await tester.pumpWidget(
        materialApp(
          StatefulBuilder(
            builder: (context, setState) => ACDSwitch(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(ACDSwitch)),
        isSemantics(
          hasToggledState: true,
          isToggled: false,
          isEnabled: true,
          hasTapAction: true,
          value: 'Off',
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, isTrue);
      handle.dispose();
    });

    testWidgets('rating: arrow keys step the rating; slider semantics', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      double rating = 2;
      await tester.pumpWidget(
        materialApp(
          StatefulBuilder(
            builder: (context, setState) => ACDRatingBar(
              rating: rating,
              onRatingUpdate: (r) => setState(() => rating = r),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('')), findsWidgets);
      final SemanticsData data = tester
          .getSemantics(find.byType(ACDRatingBar))
          .getSemanticsData();
      expect(data.value, '2 of 5');
      expect(data.increasedValue, '3 of 5');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // keyboard focus
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(rating, 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(rating, 1);
      handle.dispose();
    });

    testWidgets('slide action can be confirmed without dragging', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool confirmed = false;
      await tester.pumpWidget(
        materialApp(
          SizedBox(
            width: 300,
            child: ACDSlideAction(
              label: 'Slide to pay',
              onConfirm: () => confirmed = true,
            ),
          ),
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Slide to pay'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
      handle.dispose();
    });

    testWidgets('percent loaders announce their value', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        materialApp(
          const Column(
            children: [
              SizedBox(
                width: 200,
                child: ACDLinearPercentIndicator(
                  initialValue: 0.4,
                  animate: false,
                ),
              ),
              ACDCircularPercentIndicator(
                radius: 40,
                initialValue: 0.75,
                animate: false,
              ),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('.*')), findsWidgets);
      expect(find.semantics.byValue('40%'), findsOne);
      expect(find.semantics.byValue('75%'), findsOne);
      handle.dispose();
    });

    testWidgets('stepper markers are labelled with position and state', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        materialApp(ACDStepper(steps: ['A', 'B', 'C'], activeStep: 1)),
      );
      expect(find.bySemanticsLabel('Step 1 of 3, finished'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 2 of 3, active'), findsOneWidget);
      handle.dispose();
    });
  });

  group('reduce motion', () {
    Widget reduced(Widget child) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: materialApp(child),
    );

    testWidgets('ACDMotion jumps to the end and still reports completion', (
      tester,
    ) async {
      bool done = false;
      await tester.pumpWidget(
        reduced(
          ACDMotion(
            effect: ACDMotionEffect.fadeIn,
            duration: const Duration(seconds: 5),
            onEntranceComplete: () => done = true,
            restEffect: ACDRestEffectConfig(effect: ACDMotionRestEffect.pulse),
            child: const Text('Hi'),
          ),
        ),
      );
      await tester.pump();
      expect(done, isTrue);
      final Opacity o = tester.widget<Opacity>(
        find
            .ancestor(of: find.text('Hi'), matching: find.byType(Opacity))
            .first,
      );
      expect(o.opacity, 1);
      // No endless rest loop: the tree settles.
      await tester.pumpAndSettle();
    });

    testWidgets('ACDAnimatedText shows all text at once', (tester) async {
      bool done = false;
      await tester.pumpWidget(
        reduced(
          ACDAnimatedText(
            text: 'Hello',
            effect: ACDMotionEffect.fadeIn,
            onComplete: () => done = true,
          ),
        ),
      );
      await tester.pump();
      expect(done, isTrue);
    });

    testWidgets('ACDAnimatedText reads as one label', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        materialApp(const ACDAnimatedText(text: 'Welcome back')),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Welcome back'), findsOneWidget);
      handle.dispose();
    });
  });

  test('stagger delay is capped for long lists', () {
    const ACDStaggerOptions o = ACDStaggerOptions(
      interval: Duration(milliseconds: 10),
    );
    expect(
      o.delayForIndex(5, 300, visible: true),
      const Duration(milliseconds: 50),
    );
    expect(
      o.delayForIndex(250, 300, visible: true),
      const Duration(milliseconds: 190), // slot 19 (cap 20)
    );
    const ACDStaggerOptions uncapped = ACDStaggerOptions(
      interval: Duration(milliseconds: 10),
      maxStaggeredItems: null,
    );
    expect(
      uncapped.delayForIndex(250, 300, visible: true),
      const Duration(milliseconds: 2500),
    );
  });
}
