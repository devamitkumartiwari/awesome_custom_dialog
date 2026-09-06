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

  testWidgets('listOfACDListTile stagger wraps each row in ACDMotion', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..listOfACDListTile(
            items: const [
              ACDListTileItem(text: 'One'),
              ACDListTileItem(text: 'Two'),
            ],
            stagger: const ACDStaggerOptions(),
          )
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ACDMotion), findsNWidgets(2));
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
  });

  testWidgets('listOfACDListTile without stagger renders no ACDMotion', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..listOfACDListTile(items: const [ACDListTileItem(text: 'One')])
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ACDMotion), findsNothing);
  });

  testWidgets('listOfACDRadioButton stagger wraps each row in ACDMotion', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..listOfACDRadioButton(
            items: const [
              ACDRadioItem(text: 'A'),
              ACDRadioItem(text: 'B'),
            ],
            stagger: const ACDStaggerOptions(),
          )
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ACDMotion), findsNWidgets(2));
  });

  testWidgets('listOfACDCheckbox stagger wraps each row in ACDMotion', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog().build(context)
          ..listOfACDCheckbox(
            items: const [
              ACDCheckboxItem(text: 'A'),
              ACDCheckboxItem(text: 'B'),
            ],
            stagger: const ACDStaggerOptions(),
          )
          ..show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ACDMotion), findsNWidgets(2));
  });
}
