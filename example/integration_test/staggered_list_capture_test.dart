import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "17. Staggered Lists & Grids".
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const List<String> fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
  ];

  testWidgets('capture staggered list', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/staggered-list');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: SafeArea(
              child: ACDStaggeredList(
                itemCount: fruits.length,
                options: const ACDStaggerOptions(
                  interval: Duration(milliseconds: 90),
                ),
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(fruits[index]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < 20; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 70));
    }
    await capture.hold(10);
  });
}
