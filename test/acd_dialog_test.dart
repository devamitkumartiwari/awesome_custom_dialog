import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
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
}
