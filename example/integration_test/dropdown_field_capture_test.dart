import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for "7. Dropdown Field" — cycles the default
/// centered-dialog `mode` and `ACDDropdownMode.bottomSheet` for variety.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const List<String> countries = ['Canada', 'France', 'Germany', 'India'];

  testWidgets('capture dropdown field', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/dropdown-field');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ACDDropdownField<String>(
                  items: countries,
                  decoration: const InputDecoration(labelText: 'Country'),
                  searchHint: 'Search countries',
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await tester.tap(find.byType(ACDDropdownField<String>));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(6);
    await tester.tap(find.text('France'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(10);
  });
}
