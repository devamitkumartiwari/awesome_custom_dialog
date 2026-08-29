import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {TextDirection direction = TextDirection.ltr}) =>
      MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(body: Center(child: child)),
        ),
      );

  testWidgets(
    'ACDRatingBar seeds initialRating only once, not on every rebuild',
    (tester) async {
      late StateSetter rebuildParent;
      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) {
              rebuildParent = setState;
              return ACDRatingBar(
                initialRating: 2,
                itemCount: 5,
                itemBuilder: (context, index, fillFraction, status) =>
                    Text('$index:${status.name}'),
              );
            },
          ),
        ),
      );

      expect(find.text('4:empty'), findsOneWidget);

      final Rect barRect = tester.getRect(find.byType(ACDRatingBar));
      await tester.tapAt(Offset(barRect.right - 1, barRect.center.dy));
      await tester.pumpAndSettle();
      expect(find.text('4:filled'), findsOneWidget);

      // An unrelated ancestor rebuild must not reset the rating back to
      // `initialRating` — the classic upstream regression this design
      // eliminates by construction.
      rebuildParent(() {});
      await tester.pump();
      expect(find.text('4:filled'), findsOneWidget);
    },
  );

  testWidgets('ACDRatingBar commits on a plain tap', (tester) async {
    double? result;
    await tester.pumpWidget(
      wrap(ACDRatingBar(itemCount: 5, onRatingUpdate: (v) => result = v)),
    );

    final Rect barRect = tester.getRect(find.byType(ACDRatingBar));
    await tester.tapAt(Offset(barRect.right - 1, barRect.center.dy));
    await tester.pumpAndSettle();

    expect(result, closeTo(5, 0.001));
  });

  testWidgets(
    'ACDRatingBar with updateOnDrag:false only commits once, at drag end',
    (tester) async {
      final List<double> updates = [];
      await tester.pumpWidget(
        wrap(ACDRatingBar(itemCount: 5, onRatingUpdate: updates.add)),
      );

      await tester.timedDrag(
        find.byType(ACDRatingBar),
        const Offset(150, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(updates, hasLength(1));
    },
  );

  testWidgets(
    'ACDRatingBar with updateOnDrag:true commits continuously during drag',
    (tester) async {
      final List<double> updates = [];
      await tester.pumpWidget(
        wrap(
          ACDRatingBar(
            itemCount: 5,
            updateOnDrag: true,
            onRatingUpdate: updates.add,
          ),
        ),
      );

      await tester.timedDrag(
        find.byType(ACDRatingBar),
        const Offset(150, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(updates.length, greaterThan(1));
    },
  );

  testWidgets('ACDRatingBar snaps a tap to ratingPrecision', (tester) async {
    double? result;
    await tester.pumpWidget(
      wrap(
        ACDRatingBar(
          itemCount: 5,
          ratingPrecision: 0.1,
          onRatingUpdate: (v) => result = v,
        ),
      ),
    );

    final Rect barRect = tester.getRect(find.byType(ACDRatingBar));
    await tester.tapAt(
      Offset(barRect.left + barRect.width * 0.33, barRect.center.dy),
    );
    await tester.pumpAndSettle();

    expect(result, closeTo(1.7, 1e-6));
  });

  testWidgets('ACDRatingBar fills from the trailing edge under RTL', (
    tester,
  ) async {
    double? result;
    await tester.pumpWidget(
      wrap(
        ACDRatingBar(itemCount: 5, onRatingUpdate: (v) => result = v),
        direction: TextDirection.rtl,
      ),
    );

    final Rect barRect = tester.getRect(find.byType(ACDRatingBar));
    await tester.tapAt(Offset(barRect.left + 1, barRect.center.dy));
    await tester.pumpAndSettle();

    expect(result, closeTo(5, 0.001));
  });

  testWidgets('ACDRatingBar interactionMode.none ignores all gestures', (
    tester,
  ) async {
    double? result;
    await tester.pumpWidget(
      wrap(
        ACDRatingBar(
          itemCount: 5,
          interactionMode: ACDRatingInteractionMode.none,
          onRatingUpdate: (v) => result = v,
        ),
      ),
    );

    final Rect barRect = tester.getRect(find.byType(ACDRatingBar));
    await tester.tapAt(Offset(barRect.right - 1, barRect.center.dy));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('ACDRatingBar clearOnReTap clears the current top rating', (
    tester,
  ) async {
    double? result;
    await tester.pumpWidget(
      wrap(
        ACDRatingBar(
          itemCount: 5,
          initialRating: 5,
          clearOnReTap: true,
          onRatingUpdate: (v) => result = v,
        ),
      ),
    );

    final Rect barRect = tester.getRect(find.byType(ACDRatingBar));
    await tester.tapAt(Offset(barRect.right - 1, barRect.center.dy));
    await tester.pumpAndSettle();

    expect(result, 0);
  });
}
