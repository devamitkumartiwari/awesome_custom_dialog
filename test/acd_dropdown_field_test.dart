import 'dart:async';

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('ACDDropdownField selects an item via dialog mode', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      wrap(
        ACDDropdownField<String>(
          items: const ['Alpha', 'Beta', 'Gamma'],
          onChanged: (value) => picked = value,
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.text('Beta'), findsOneWidget);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(picked, 'Beta');
    expect(find.text('Beta'), findsOneWidget); // now shown in closed state
  });

  testWidgets('ACDDropdownField validator blocks an empty Form', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      wrap(
        Form(
          key: formKey,
          child: ACDDropdownField<String>(
            items: const ['Alpha', 'Beta'],
            validator: (v) => v == null ? 'Required' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('ACDDropdownField showClearButton clears the selection', (
    tester,
  ) async {
    String? picked = 'preset';
    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) => ACDDropdownField<String>(
            items: const ['Alpha', 'Beta'],
            initialValue: picked,
            showClearButton: true,
            onChanged: (value) => setState(() => picked = value),
          ),
        ),
      ),
    );

    expect(find.text('preset'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(picked, isNull);
  });

  testWidgets('ACDDropdownField menu mode opens an anchored popup', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDDropdownField<String>(
          items: const ['Alpha', 'Beta'],
          mode: ACDDropdownMode.menu,
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget); // the search box
  });

  testWidgets('ACDMultiDropdownField confirms a multi-selection', (
    tester,
  ) async {
    List<String>? picked;
    await tester.pumpWidget(
      wrap(
        ACDMultiDropdownField<String>(
          items: const ['Alpha', 'Beta', 'Gamma'],
          onChanged: (values) => picked = values,
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha'));
    await tester.tap(find.text('Gamma'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(picked, containsAll(<String>['Alpha', 'Gamma']));
    expect(picked!.length, 2);
  });

  testWidgets('favoriteItems are pinned to the top of the idle list', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDDropdownField<String>(
          items: const ['Alpha', 'Beta', 'Gamma'],
          favoriteItems: const ['Gamma'],
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    final finder = find.byType(ListTile);
    expect(
      (tester.widget<ListTile>(finder.at(0)).title! as Text).data,
      'Gamma',
    );
  });

  testWidgets('isDisabledItem prevents selecting that row', (tester) async {
    String? picked;
    await tester.pumpWidget(
      wrap(
        ACDDropdownField<String>(
          items: const ['Alpha', 'Beta'],
          isDisabledItem: (item) => item == 'Beta',
          onChanged: (value) => picked = value,
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(picked, isNull); // dialog is still open — tap was ignored
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('compareFn drives selection equality for a custom type', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDDropdownField<_Item>(
          items: const [_Item(1, 'One'), _Item(2, 'Two')],
          itemAsString: (i) => i.label,
          compareFn: (a, b) => a.id == b.id,
          initialValue: const _Item(2, 'Two (stale label)'),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    // The row with id 2 should render as selected (a check icon) even
    // though it isn't == to the stale initialValue instance.
    final tile = tester.widget<ListTile>(
      find.ancestor(of: find.text('Two'), matching: find.byType(ListTile)),
    );
    expect(tile.trailing, isA<Icon>());
  });

  testWidgets('onFindPaged loads the first page on open and appends more '
      'on scroll', (tester) async {
    final calls = <int>[];
    Future<List<String>> loadPage(String query, int page) async {
      calls.add(page);
      if (page >= 2) return const [];
      return List.generate(30, (i) => 'Item ${page * 30 + i}');
    }

    await tester.pumpWidget(
      wrap(
        SizedBox(
          height: 400,
          child: ACDDropdownField<String>(
            items: const [],
            onFindPaged: loadPage,
            popupHeight: 300,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(calls, [0]);
    expect(find.text('Item 0'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    expect(calls, containsAll(<int>[0, 1]));
  });

  testWidgets(
    'a new query while a load-more is in flight still paginates the new '
    'results (the superseded response is discarded)',
    (tester) async {
      final calls = <String>[];
      final Completer<List<String>> hung = Completer<List<String>>();
      Future<List<String>> loadPage(String query, int page) {
        calls.add('$query:$page');
        if (query.isEmpty && page == 1) return hung.future; // never resolves
        if (page >= 2) return Future.value(const <String>[]);
        return Future.value(
          List.generate(30, (i) => '$query Item ${page * 30 + i}'),
        );
      }

      await tester.pumpWidget(
        wrap(
          SizedBox(
            height: 400,
            child: ACDDropdownField<String>(
              items: const [],
              onFindPaged: loadPage,
              popupHeight: 300,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Trigger load-more for '' page 1 — it hangs.
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pump();
      expect(calls, contains(':1'));

      // New query resets while that load-more is still in flight.
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump(const Duration(seconds: 1)); // debounce
      await tester.pumpAndSettle();
      expect(calls, contains('x:0'));

      // Scrolling the new results must still paginate.
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pumpAndSettle();
      expect(calls, contains('x:1'));
    },
  );
}

class _Item {
  const _Item(this.id, this.label);

  final int id;
  final String label;
}
