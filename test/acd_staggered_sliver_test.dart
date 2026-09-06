import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrapSlivers(List<Widget> slivers) => MaterialApp(
    home: Scaffold(
      body: SizedBox(height: 400, child: CustomScrollView(slivers: slivers)),
    ),
  );

  const options = ACDStaggerOptions(
    interval: Duration(milliseconds: 20),
    itemDuration: Duration(milliseconds: 20),
    startDelay: Duration.zero,
  );

  group('ACDStaggeredSliverList', () {
    testWidgets('renders one widget per item inside a CustomScrollView', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapSlivers([
          ACDStaggeredSliverList(
            itemCount: 3,
            options: options,
            itemBuilder: (context, index) => Text('item-$index'),
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('item-0'), findsOneWidget);
      expect(find.text('item-2'), findsOneWidget);
    });

    testWidgets(
      'fires onAllEntranceComplete exactly once after the last item settles',
      (tester) async {
        int completeCount = 0;
        await tester.pumpWidget(
          wrapSlivers([
            ACDStaggeredSliverList(
              itemCount: 3,
              options: options,
              itemBuilder: (context, index) => Text('item-$index'),
              onAllEntranceComplete: () => completeCount++,
            ),
          ]),
        );

        await tester.pump();
        expect(completeCount, 0);

        await tester.pumpAndSettle();
        expect(completeCount, 1);
      },
    );

    testWidgets('empty list fires onAllEntranceComplete immediately', (
      tester,
    ) async {
      int completeCount = 0;
      await tester.pumpWidget(
        wrapSlivers([
          ACDStaggeredSliverList(
            itemCount: 0,
            itemBuilder: (context, index) => Text('item-$index'),
            onAllEntranceComplete: () => completeCount++,
          ),
        ]),
      );
      await tester.pump();

      expect(completeCount, 1);
    });

    testWidgets('composes with other slivers in one CustomScrollView', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapSlivers([
          const SliverToBoxAdapter(child: Text('Header')),
          ACDStaggeredSliverList(
            itemCount: 2,
            options: options,
            itemBuilder: (context, index) => Text('item-$index'),
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('item-0'), findsOneWidget);
      expect(find.text('item-1'), findsOneWidget);
    });
  });

  group('ACDStaggeredSliverGrid', () {
    testWidgets('renders one widget per cell inside a CustomScrollView', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapSlivers([
          ACDStaggeredSliverGrid(
            itemCount: 4,
            options: options,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemBuilder: (context, index) => Text('cell-$index'),
          ),
        ]),
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
          wrapSlivers([
            ACDStaggeredSliverGrid(
              itemCount: 3,
              options: options,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) => Text('cell-$index'),
              onAllEntranceComplete: () => completeCount++,
            ),
          ]),
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
        wrapSlivers([
          ACDStaggeredSliverGrid(
            itemCount: 0,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) => Text('cell-$index'),
            onAllEntranceComplete: () => completeCount++,
          ),
        ]),
      );
      await tester.pump();

      expect(completeCount, 1);
    });
  });
}
