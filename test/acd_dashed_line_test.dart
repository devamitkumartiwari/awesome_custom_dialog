import 'dart:ui';

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:awesome_custom_dialog/src/dashed/acd_dash_path.dart';
import 'package:material_ui/material_ui.dart';
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

  for (final Axis axis in Axis.values) {
    testWidgets(
      'ACDDashedLine ($axis) strokes along its centre line, so the full '
      'thickness stays inside its own box (regression: drawn at 0)',
      (tester) async {
        await tester.pumpWidget(
          wrap(ACDDashedLine(axis: axis, length: 100, thickness: 4)),
        );
        final RenderBox box = tester.renderObject<RenderBox>(
          find.descendant(
            of: find.byType(ACDDashedLine),
            matching: find.byType(CustomPaint),
          ),
        );
        Rect? pathBounds;
        expect(
          box,
          paints..everything((Symbol method, List<dynamic> args) {
            if (method == #drawPath) {
              pathBounds ??= (args[0] as Path).getBounds();
              // first drawPath is the dash path
            }
            return true;
          }),
        );
        // The centre line sits at thickness/2 on the cross axis.
        if (axis == Axis.horizontal) {
          expect(pathBounds!.top, 2);
          expect(pathBounds!.bottom, 2);
        } else {
          expect(pathBounds!.left, 2);
          expect(pathBounds!.right, 2);
        }
      },
    );
  }
}
