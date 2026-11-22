import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:awesome_custom_dialog_example/app_settings.dart';
import 'package:awesome_custom_dialog_example/screens/switch_screen.dart';
import 'package:awesome_custom_dialog_example/widgets/design_switcher.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors MyApp: the scope and theme platform follow the app settings.
Widget _app(Widget home) => ListenableBuilder(
  listenable: appSettings,
  builder: (context, _) => ACDDesignScope(
    design: designNotifier.value,
    child: MaterialApp(
      theme: ThemeData(platform: platformNotifier.value),
      home: home,
    ),
  ),
);

void main() {
  setUp(() {
    designNotifier.value = ACDDesign.material;
    platformNotifier.value = TargetPlatform.android;
  });

  ACDResolvedDesign resolvedAt(WidgetTester tester) =>
      ACDDesign.resolve(tester.element(find.byType(SwitchScreen)));

  testWidgets('demo screens show the switcher and it changes the design', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SwitchScreen()));
    expect(find.byType(DesignSwitcherButton), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
    expect(resolvedAt(tester), ACDResolvedDesign.material);

    await tester.tap(find.byType(DesignSwitcherButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cupertino').last);
    await tester.pumpAndSettle();
    expect(designNotifier.value, ACDDesign.cupertino);
    expect(resolvedAt(tester), ACDResolvedDesign.cupertino);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adaptive follows the platform preview', (tester) async {
    designNotifier.value = ACDDesign.adaptive;
    await tester.pumpWidget(_app(const SwitchScreen()));
    expect(resolvedAt(tester), ACDResolvedDesign.material);
    expect(find.text('Auto · M3'), findsOneWidget);

    await tester.tap(find.byType(DesignSwitcherButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('iOS').last);
    await tester.pumpAndSettle();
    expect(platformNotifier.value, TargetPlatform.iOS);
    expect(resolvedAt(tester), ACDResolvedDesign.cupertino);
    expect(find.textContaining('rendering Cupertino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
