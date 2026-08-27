import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  final items = const [
    ACDStepperItemData(id: 1, data: 'Order placed'),
    ACDStepperItemData(id: 2, data: 'Shipped'),
    ACDStepperItemData(id: 3, data: 'Delivered'),
  ];

  testWidgets('renders one row per item via contentBuilder', (tester) async {
    await tester.pumpWidget(
      wrap(
        ACDStepperListView<String>(
          items: items,
          contentBuilder: (context, item, index) => Text(item.data),
        ),
      ),
    );

    expect(find.text('Order placed'), findsOneWidget);
    expect(find.text('Shipped'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    // Default avatar shows the 1-based index.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('avatarBuilder and labelBuilder overrides render when supplied', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ACDStepperListView<String>(
          items: items,
          avatarBuilder: (context, item, index) =>
              const Icon(Icons.check_circle),
          labelBuilder: (context, item, index) => Text('Step ${index + 1}'),
          contentBuilder: (context, item, index) => Text(item.data),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Step 3'), findsOneWidget);
  });

  testWidgets(
    'connector line is hidden after the last item unless showLineOnLast',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          ACDStepperListView<String>(
            items: items,
            contentBuilder: (context, item, index) => Text(item.data),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        wrap(
          ACDStepperListView<String>(
            items: items,
            showLineOnLast: true,
            contentBuilder: (context, item, index) => Text(item.data),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
