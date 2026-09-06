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

  testWidgets('renders one widget per item', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDStaggeredList(
          itemCount: 3,
          options: options,
          itemBuilder: (context, index) => Text('item-$index'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('item-0'), findsOneWidget);
    expect(find.text('item-1'), findsOneWidget);
    expect(find.text('item-2'), findsOneWidget);
  });

  testWidgets('passes reverse/scrollDirection through to the ListView', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDStaggeredList(
          itemCount: 2,
          reverse: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Text('item-$index'),
        ),
      ),
    );
    await tester.pump();

    final ListView listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.reverse, isTrue);
    expect(listView.scrollDirection, Axis.horizontal);
  });

  testWidgets(
    'fires onAllEntranceComplete exactly once after the last item settles',
    (tester) async {
      int completeCount = 0;
      await tester.pumpWidget(
        wrap(
          ACDStaggeredList(
            itemCount: 3,
            options: options,
            itemBuilder: (context, index) => Text('item-$index'),
            onAllEntranceComplete: () => completeCount++,
          ),
        ),
      );

      // Nothing has settled on the very first frame yet.
      await tester.pump();
      expect(completeCount, 0);

      await tester.pumpAndSettle();
      expect(completeCount, 1);

      // Stays at exactly one even after settling further.
      await tester.pump(const Duration(milliseconds: 200));
      expect(completeCount, 1);
    },
  );

  testWidgets('empty list fires onAllEntranceComplete immediately', (
    tester,
  ) async {
    int completeCount = 0;
    await tester.pumpWidget(
      wrap(
        ACDStaggeredList(
          itemCount: 0,
          itemBuilder: (context, index) => Text('item-$index'),
          onAllEntranceComplete: () => completeCount++,
        ),
      ),
    );
    await tester.pump();

    expect(completeCount, 1);
  });

  testWidgets(
    'toggling visible to false plays a staggered exit and fires onAllExitComplete once',
    (tester) async {
      int exitCompleteCount = 0;
      final ValueKey<String> key = const ValueKey('list');

      Widget build(bool visible) => wrap(
        ACDStaggeredList(
          key: key,
          itemCount: 2,
          visible: visible,
          options: options,
          itemBuilder: (context, index) => Text('item-$index'),
          onAllExitComplete: () => exitCompleteCount++,
        ),
      );

      await tester.pumpWidget(build(true));
      // Let entrance fully settle.
      await tester.pumpAndSettle();

      await tester.pumpWidget(build(false));
      await tester.pump();
      expect(exitCompleteCount, 0);

      await tester.pumpAndSettle();
      expect(exitCompleteCount, 1);
    },
  );
}
