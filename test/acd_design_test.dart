import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:awesome_custom_dialog/src/design/internal/acd_adaptive_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<ACDResolvedDesign> resolveIn(
    WidgetTester tester,
    Widget Function(Widget probe) host, {
    ACDDesign? override,
  }) async {
    late ACDResolvedDesign resolved;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            resolved = ACDDesign.resolve(context, override);
            return const SizedBox();
          },
        ),
      ),
    );
    return resolved;
  }

  Widget materialApp(Widget child) => MaterialApp(home: child);
  Widget cupertinoApp(Widget child) => CupertinoApp(home: child);

  group('ACDDesign.resolve precedence', () {
    testWidgets('no override and no scope → material (the default)', (
      tester,
    ) async {
      expect(await resolveIn(tester, materialApp), ACDResolvedDesign.material);
    });

    testWidgets('scope applies when the widget sets nothing', (tester) async {
      expect(
        await resolveIn(
          tester,
          (p) => ACDDesignScope(
            design: ACDDesign.cupertino,
            child: materialApp(p),
          ),
        ),
        ACDResolvedDesign.cupertino,
      );
    });

    testWidgets('the widget override wins over the scope', (tester) async {
      expect(
        await resolveIn(
          tester,
          (p) => ACDDesignScope(
            design: ACDDesign.cupertino,
            child: materialApp(p),
          ),
          override: ACDDesign.material,
        ),
        ACDResolvedDesign.material,
      );
    });
  });

  group('ACDDesign.adaptive', () {
    testWidgets('iOS → cupertino', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final r = await resolveIn(
        tester,
        materialApp,
        override: ACDDesign.adaptive,
      );
      debugDefaultTargetPlatformOverride = null;
      expect(r, ACDResolvedDesign.cupertino);
    });

    testWidgets('Android → material', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final r = await resolveIn(
        tester,
        materialApp,
        override: ACDDesign.adaptive,
      );
      debugDefaultTargetPlatformOverride = null;
      expect(r, ACDResolvedDesign.material);
    });

    testWidgets(
      'a bare CupertinoApp (no Material localizations) → cupertino on any '
      'platform',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final r = await resolveIn(
          tester,
          cupertinoApp,
          override: ACDDesign.adaptive,
        );
        debugDefaultTargetPlatformOverride = null;
        expect(r, ACDResolvedDesign.cupertino);
      },
    );
  });

  testWidgets(
    'Material adapters stay safe in a bare CupertinoApp (Material ancestor '
    'and localizations are supplied when missing)',
    (tester) async {
      await tester.pumpWidget(
        cupertinoApp(
          const Column(
            children: [
              ACDAdaptiveTextField(design: ACDResolvedDesign.material),
              ACDAdaptiveTappable(
                design: ACDResolvedDesign.material,
                child: Text('tap'),
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    },
  );

  testWidgets('Cupertino adapters build Cupertino primitives', (tester) async {
    await tester.pumpWidget(
      cupertinoApp(
        Column(
          children: [
            const ACDAdaptiveTextField(design: ACDResolvedDesign.cupertino),
            const ACDAdaptiveProgress(design: ACDResolvedDesign.cupertino),
            ACDAdaptiveCheckbox(
              design: ACDResolvedDesign.cupertino,
              value: true,
              onChanged: (_) {},
            ),
            const ACDAdaptiveListTile(
              design: ACDResolvedDesign.cupertino,
              title: Text('Row'),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.byType(CupertinoCheckbox), findsOneWidget);
    expect(find.byType(CupertinoListTile), findsOneWidget);
  });

  testWidgets('tokens follow dark mode for both designs', (tester) async {
    late ACDDesignTokens m;
    late ACDDesignTokens c;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: CupertinoTheme(
          data: const CupertinoThemeData(brightness: Brightness.dark),
          child: Builder(
            builder: (context) {
              m = ACDDesignTokens.of(context, ACDResolvedDesign.material);
              c = ACDDesignTokens.of(context, ACDResolvedDesign.cupertino);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(m.brightness, Brightness.dark);
    expect(c.brightness, Brightness.dark);
    // Dark surfaces, light text.
    expect(m.surface.computeLuminance(), lessThan(0.2));
    expect(c.onSurface.computeLuminance(), greaterThan(0.8));
  });
}
