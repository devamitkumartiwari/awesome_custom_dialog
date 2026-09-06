import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: SizedBox(height: 400, child: child)),
  );

  const options = ACDStaggerOptions(
    interval: Duration(milliseconds: 20),
    itemDuration: Duration(milliseconds: 20),
    startDelay: Duration.zero,
  );

  testWidgets('renders one widget per cell', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDStaggeredGrid(
          itemCount: 4,
          options: options,
          // A single row (crossAxisCount == itemCount) so every cell is
          // within the viewport and gets built by the lazy GridView.
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemBuilder: (context, index) => Text('cell-$index'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('cell-0'), findsOneWidget);
    expect(find.text('cell-3'), findsOneWidget);
  });

  testWidgets(
    'fires onAllEntranceComplete exactly once after the last cell settles',
    (tester) async {
      int completeCount = 0;
      await tester.pumpWidget(
        wrap(
          ACDStaggeredGrid(
            itemCount: 3,
            options: options,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) => Text('cell-$index'),
            onAllEntranceComplete: () => completeCount++,
          ),
        ),
      );

      await tester.pump();
      expect(completeCount, 0);

      await tester.pumpAndSettle();
      expect(completeCount, 1);
    },
  );

  testWidgets('empty grid fires onAllEntranceComplete immediately', (
    tester,
  ) async {
    int completeCount = 0;
    await tester.pumpWidget(
      wrap(
        ACDStaggeredGrid(
          itemCount: 0,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) => Text('cell-$index'),
          onAllEntranceComplete: () => completeCount++,
        ),
      ),
    );
    await tester.pump();

    expect(completeCount, 1);
  });
}
