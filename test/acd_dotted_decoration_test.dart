import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  for (final shape in ACDDottedShape.values) {
    testWidgets('ACDDottedDecoration paints without error for $shape', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          Container(
            width: 100,
            height: 100,
            decoration: ACDDottedDecoration(shape: shape),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
