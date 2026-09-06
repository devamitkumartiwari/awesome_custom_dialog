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
  const List<String> skills = ['Design', 'Engineering', 'Marketing', 'Sales'];

  testWidgets('capture dropdown field', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/dropdown-field');
    await capture.setSize();

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ACDDropdownField<String>(
                      items: countries,
                      decoration: const InputDecoration(labelText: 'Country'),
                      searchHint: 'Search countries',
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 20),
                    ACDDropdownField<String>(
                      items: skills,
                      mode: ACDDropdownMode.bottomSheet,
                      decoration: const InputDecoration(
                        labelText: 'Primary skill',
                      ),
                      onChanged: (_) {},
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

    // Default centered-dialog mode.
    await tester.tap(find.byType(ACDDropdownField<String>).first);
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);
    await tester.tap(find.text('France'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);

    // Bottom-sheet mode.
    await tester.tap(find.byType(ACDDropdownField<String>).last);
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(4);
    await tester.tap(find.text('Engineering'));
    for (int i = 0; i < 6; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }
    await capture.hold(8);
  });
}
