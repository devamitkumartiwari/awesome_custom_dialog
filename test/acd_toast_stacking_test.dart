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

  tearDown(() {
    ACDToastManager.dismissAll();
    ACDToastManager.clearDefaults();
  });

  testWidgets(
    'maxVisible caps simultaneously visible toasts and queues the rest',
    (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        wrap((context) {
          ctx = context;
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();

      for (int i = 0; i < 3; i++) {
        ACDDialog.toast(
          context: ctx,
          message: 'toast $i',
          id: 'toast-$i',
          maxVisible: 2,
          cancelPrevious: false,
          showDuration: const Duration(seconds: 10),
        ).show();
      }
      await tester.pumpAndSettle();

      expect(find.text('toast 0'), findsOneWidget);
      expect(find.text('toast 1'), findsOneWidget);
      expect(find.text('toast 2'), findsNothing); // queued behind maxVisible

      expect(ACDToastManager.activeCount(position: ACDGravity.bottom), 3);

      ACDToastManager.dismissById('toast-0');
      await tester.pumpAndSettle();

      expect(find.text('toast 0'), findsNothing);
      expect(find.text('toast 1'), findsOneWidget);
      expect(
        find.text('toast 2'),
        findsOneWidget,
      ); // promoted once a slot freed

      ACDToastManager.dismissAll();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('dropOldest overflow policy dismisses the oldest to make room', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      wrap((context) {
        ctx = context;
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();

    for (int i = 0; i < 3; i++) {
      ACDDialog.toast(
        context: ctx,
        message: 'toast $i',
        maxVisible: 2,
        overflowPolicy: ACDToastOverflowPolicy.dropOldest,
        cancelPrevious: false,
        showDuration: const Duration(seconds: 10),
      ).show();
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('toast 0'), findsNothing); // dropped to make room
    expect(find.text('toast 1'), findsOneWidget);
    expect(find.text('toast 2'), findsOneWidget);

    ACDToastManager.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'findById/dismissById locate and remove a specific toast among several active',
    (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        wrap((context) {
          ctx = context;
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();

      ACDDialog.toast(
        context: ctx,
        message: 'a',
        id: 'a',
        cancelPrevious: false,
        showDuration: const Duration(seconds: 10),
      ).show();
      ACDDialog.toast(
        context: ctx,
        message: 'b',
        id: 'b',
        cancelPrevious: false,
        showDuration: const Duration(seconds: 10),
      ).show();
      await tester.pumpAndSettle();

      expect(ACDToastManager.findById('a'), isNotNull);
      expect(ACDToastManager.findById('nope'), isNull);

      ACDToastManager.dismissById('a');
      await tester.pumpAndSettle();

      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneWidget);

      ACDToastManager.dismissAll();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('toasts at different gravity positions stack independently', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      wrap((context) {
        ctx = context;
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();

    ACDDialog.toast(
      context: ctx,
      message: 'top toast',
      gravity: ACDGravity.top,
      cancelPrevious: false,
      showDuration: const Duration(seconds: 10),
    ).show();
    ACDDialog.toast(
      context: ctx,
      message: 'bottom toast',
      cancelPrevious: false,
      showDuration: const Duration(seconds: 10),
    ).show();
    await tester.pumpAndSettle();

    expect(find.text('top toast'), findsOneWidget);
    expect(find.text('bottom toast'), findsOneWidget);
    expect(ACDToastManager.activeCount(position: ACDGravity.top), 1);
    expect(ACDToastManager.activeCount(position: ACDGravity.bottom), 1);

    ACDToastManager.dismissAll();
    await tester.pumpAndSettle();
  });
}
