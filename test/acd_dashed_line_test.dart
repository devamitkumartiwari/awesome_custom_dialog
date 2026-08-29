import 'dart:ui';

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:awesome_custom_dialog/src/dashed/acd_dash_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('ACDDashedLine renders horizontally without error', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const ACDDashedLine(length: 200)));
    expect(find.byType(ACDDashedLine), findsOneWidget);
  });

  testWidgets('ACDDashedLine renders vertically without error', (tester) async {
    await tester.pumpWidget(
      wrap(const ACDDashedLine(axis: Axis.vertical, length: 100)),
    );
    expect(find.byType(ACDDashedLine), findsOneWidget);
  });

  test('acdDashPath splits a straight path into dash-length segments', () {
    final Path straight = Path()
      ..moveTo(0, 0)
      ..lineTo(100, 0);

    final Path dashed = acdDashPath(straight, pattern: const [10, 5]);
    final List<PathMetric> metrics = dashed.computeMetrics().toList();

    expect(
      metrics.length,
      7,
    ); // dashes at 0,15,30,45,60,75,90 (last clamped to 100)
    final double totalDrawn = metrics.fold(0.0, (sum, m) => sum + m.length);
    expect(totalDrawn, closeTo(70, 0.5));
  });
}
