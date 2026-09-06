import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "6. Searchable List" — the single-select
/// `searchableList()` and the multi-select `multiSearchableList()`, for
/// full coverage of both selection modes.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const List<String> countries = [
    'Canada',
    'France',
    'Germany',
    'India',
    'Japan',
    'Kenya',
    'Mexico',
    'Norway',
  ];

  testWidgets('capture searchable list', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/searchable-list');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Builder(
              builder: (context) => Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ACDDialog().build(context)
                          ..height = 400
                          ..searchableList<String>(
                            items: countries,
                            searchHint: 'Search countries',
                            onChange: (_) {},
                          )
                          ..show();
                      },
                      child: const Text('Single select'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ACDDialog().build(context)
                          ..height = 440
                          ..multiSearchableList<String>(
                            items: countries,
                            searchHint: 'Search countries',
                            onMultipleItemsChange: (_) {},
                          )
                          ..show();
                      },
                      child: const Text('Multi select'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);

    // Single-select: search then pick.
    await tester.tap(find.text('Single select'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);
    await tester.enterText(find.byType(TextField), 'j');
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(6);
    await tester.tap(find.text('Japan'));
    for (int i = 0; i < 9; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }
    await capture.hold(4);

    // Multi-select: check a couple, confirm.
    await tester.tap(find.text('Multi select'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);
    await tester.tap(find.text('Canada'));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await tester.tap(find.text('Germany'));
    await capture.pumpAndCapture(const Duration(milliseconds: 60));
    await capture.hold(8);
    await tester.tap(find.text('OK'));
    for (int i = 0; i < 9; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 50));
    }
    await capture.hold(4);
  });
}
