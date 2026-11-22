import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:awesome_custom_dialog_example/app_settings.dart';
import 'package:awesome_custom_dialog_example/home_screen.dart';
import 'package:awesome_custom_dialog_example/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures the README's still screenshots (dark mode, full app frame):
/// the example's home screen, a dialog over it, and the same dialog with
/// the Cupertino design. Each is a single frame in its own folder.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(
    WidgetTester tester,
    String name,
    ACDDesign design, {
    bool openDialog = false,
  }) async {
    final capture = GifCapture(tester, 'build/gif_frames/screenshot-$name');
    await capture.setSize();
    // Through the app's own setting, so the design switcher label matches.
    designNotifier.value = design;
    await tester.pumpWidget(
      capture.wrap(
        ACDDesignScope(
          design: design,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: const HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (openDialog) {
      ACDDialog().build(tester.element(find.byType(HomeScreen)))
        ..text(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          text: 'Delete this photo?',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        )
        ..text(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          text: 'It will be removed from all your devices.',
        )
        ..actions(const [
          ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
          ACDAction(
            label: 'Delete',
            role: ACDActionRole.destructive,
            value: true,
          ),
        ])
        ..show();
      await tester.pumpAndSettle();
    }
    await capture.snapshot();
  }

  testWidgets('capture screenshots', (tester) async {
    await shoot(tester, 'home', ACDDesign.material);
    await shoot(
      tester,
      'dialog-material',
      ACDDesign.material,
      openDialog: true,
    );
    await shoot(
      tester,
      'dialog-cupertino',
      ACDDesign.cupertino,
      openDialog: true,
    );
  });
}
