import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  for (final shape in ACDDashedBorderShape.values.where(
    (s) => s != ACDDashedBorderShape.customPath,
  )) {
    testWidgets(
      'ACDDashedBorder renders child and paints without error for $shape',
      (tester) async {
        await tester.pumpWidget(
          wrap(ACDDashedBorder(shape: shape, child: const Text('Hello'))),
        );
        expect(find.text('Hello'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('ACDDashedBorder supports a custom path', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDDashedBorder(
          shape: ACDDashedBorderShape.customPath,
          customPathBuilder: (size) =>
              Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          child: const Text('Custom'),
        ),
      ),
    );
    expect(find.text('Custom'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
