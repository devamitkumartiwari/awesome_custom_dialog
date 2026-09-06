import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "6. Searchable List".
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
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
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
                  child: const Text('Open List'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.text('Open List'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);

    await tester.enterText(find.byType(TextField), 'j');
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(8);
  });
}
