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
    'toast shows with default styling and auto-dismisses after the default duration',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog.toast(
            context: context,
            message: 'Copied to clipboard',
          ).show();
        }),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 300),
      ); // entrance transition

      expect(find.text('Copied to clipboard'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2)); // default auto-dismiss
      await tester.pump(const Duration(milliseconds: 300)); // exit transition
      await tester.pumpAndSettle();

      expect(find.text('Copied to clipboard'), findsNothing);
    },
  );

  testWidgets(
    'cancelPrevious dismisses the previously showing toast before showing the new one',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog.toast(
            context: context,
            message: 'first',
            showDuration: Duration.zero,
          ).show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('first'), findsOneWidget);

      ACDDialog.toast(
        context: tester.element(find.text('Open')),
        message: 'second',
        showDuration: Duration.zero,
      ).show();
      await tester.pumpAndSettle();

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
    },
  );

  testWidgets('dismiss() is safe to call twice without throwing '
      '(regression for AnimationController.dispose() called more than once)', (
    tester,
  ) async {
    late ACDDialog toast;
    await tester.pumpWidget(
      wrap((context) {
        toast = ACDDialog.toast(
          context: context,
          message: 'hello',
          showDuration: Duration.zero,
        );
        toast.show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    toast.dismiss();
    await tester.pump(const Duration(milliseconds: 50));
    expect(() => toast.dismiss(), returnsNormally);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'dismissAll() removes a toast that was enqueued but not yet inserted '
    '(regression for dismissAll not clearing pending/queued toasts)',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog.toast(
            context: context,
            message: 'delayed',
            showDelay: const Duration(seconds: 5),
          ).show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.text('delayed'), findsNothing); // still waiting on showDelay

      ACDToastManager.dismissAll();
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(find.text('delayed'), findsNothing); // never shown at all
    },
  );

  testWidgets(
    'toast never touches the app Navigator — pushing a new route does not '
    'affect an active toast',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog.toast(
            context: context,
            message: 'stays put',
            showDuration: const Duration(seconds: 10),
          ).show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('stays put'), findsOneWidget);

      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute(builder: (_) => const Text('other page')),
      );
      await tester.pumpAndSettle();

      expect(find.text('other page'), findsOneWidget);
      expect(find.text('stays put'), findsOneWidget);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('stays put'), findsOneWidget);

      ACDToastManager.dismissAll();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'a sticky toast (Duration.zero) never auto-dismisses on its own',
    (tester) async {
      await tester.pumpWidget(
        wrap((context) {
          ACDDialog.toast(
            context: context,
            message: 'sticky',
            showDuration: Duration.zero,
          ).show();
        }),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(minutes: 5));
      expect(find.text('sticky'), findsOneWidget);

      ACDToastManager.dismissAll();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('custom colors render exactly as given, never coerced through a MaterialColor '
      'swatch', (tester) async {
    const Color customColor = Color(0xFF123456);
    await tester.pumpWidget(
      wrap((context) {
        ACDDialog.toast(
          context: context,
          message: 'colored',
          backgroundColor: customColor,
          showDuration: const Duration(seconds: 10),
        ).show();
      }),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final Container container = tester.widget<Container>(
      find
          .ancestor(of: find.text('colored'), matching: find.byType(Container))
          .first,
    );
    final BoxDecoration decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, customColor);

    ACDToastManager.dismissAll();
    await tester.pumpAndSettle();
  });
}
