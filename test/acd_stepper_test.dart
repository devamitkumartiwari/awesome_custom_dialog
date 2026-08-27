import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  const steps = ['One', 'Two', 'Three'];

  testWidgets('ACDStepper renders one marker per step, horizontal', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(ACDStepper(steps: steps, activeStep: 1)));

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
    expect(find.text('1'), findsNothing); // finished step shows a check icon
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // active step shows its number
    expect(find.text('3'), findsOneWidget); // upcoming step shows its number
  });

  testWidgets('ACDStepper renders one marker per step, vertical', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(ACDStepper(steps: steps, activeStep: 0, direction: Axis.vertical)),
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
  });

  testWidgets('tapping a step calls onStepReached with its index', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(
      wrap(
        ACDStepper(
          steps: steps,
          activeStep: 0,
          onStepReached: (i) => tapped = i,
        ),
      ),
    );

    await tester.tap(find.text('3')); // the third marker's own label
    await tester.pump();

    expect(tapped, 2);
  });

  testWidgets('customStep fully overrides a step marker', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDStepper(
          steps: steps,
          activeStep: 0,
          customStep: (context, index, status) =>
              Icon(Icons.star, key: ValueKey('star$index')),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('gradient marker renders via an animated container', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDStepper(
          steps: steps,
          activeStep: 1,
          activeStepGradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ),
          animationDuration: const Duration(milliseconds: 500),
        ),
      ),
    );

    final AnimatedContainer active = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .firstWhere((c) => (c.decoration as BoxDecoration?)?.gradient != null);
    expect(active.duration, const Duration(milliseconds: 500));
  });
}
