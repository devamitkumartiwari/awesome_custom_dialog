import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';

/// Shared brand seed for every README demo GIF — a modern indigo/violet
/// matching the accent already used in the dialog-styling demo
/// (`0xFF6A11CB`/`0xFF2575FC`), applied consistently via Material 3 so
/// every button/chip/switch/slider across all 20 GIFs shares one cohesive,
/// deliberate palette instead of Flutter's default debug blue.
const Color demoSeedColor = Color(0xFF6C5CE7);

/// Every README GIF and screenshot is dark mode: a deep, slightly violet
/// near-black that matches the seed instead of a flat pure black.
const Color demoBackground = Color(0xFF131218);

/// The theme every capture script's `MaterialApp` should use, for a
/// consistent, modern Material 3 look across the whole README.
final ThemeData demoTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: demoSeedColor,
  scaffoldBackgroundColor: demoBackground,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.zero),
);

/// Deterministic PNG-frame capture for producing README GIFs. Pumps and
/// drives a widget under test, snapshotting each frame via
/// [RenderRepaintBoundary.toImage] — so animations/gestures are captured
/// pixel-for-pixel without a screen recording. Runs as an `integration_test`
/// on a real device/desktop target (not a plain `flutter_test` unit test)
/// specifically so real fonts render — the plain `flutter_test` environment
/// substitutes a block-glyph test font, which isn't acceptable in a
/// screenshot meant for the README.
class GifCapture {
  GifCapture(this.tester, this.outDir) : _boundaryKey = GlobalKey();

  final WidgetTester tester;
  final String outDir;
  final GlobalKey _boundaryKey;

  /// Where frames are written. On a phone the relative [outDir] has no
  /// writable home, so it goes under the app's cache directory instead —
  /// pull it with `adb shell run-as <app id> …` (see tool/pull_gif_frames.sh).
  String get _root => (Platform.isAndroid || Platform.isIOS)
      ? '${Directory.systemTemp.path}/$outDir'
      : outDir;
  int _frame = 0;

  /// Wraps [child] for capture — pass the result to [WidgetTester.pumpWidget].
  Widget wrap(Widget child) => RepaintBoundary(key: _boundaryKey, child: child);

  /// Fixes the logical window size so every GIF is the same portrait shape
  /// regardless of the host device's real window/screen size.
  Future<void> setSize({
    double width = 360,
    double height = 720,
    double pixelRatio = 2,
  }) async {
    await _loadHostFonts();
    // Start from an empty frame folder, so a shorter re-capture never keeps
    // stale trailing frames from an earlier run.
    final Directory frames = Directory(_root);
    if (frames.existsSync()) frames.deleteSync(recursive: true);
    await tester.binding.setSurfaceSize(Size(width, height));
    tester.view.devicePixelRatio = pixelRatio;
    // The layout must see the same 360x720 screen as the captured frame,
    // not the phone's real (taller) display.
    tester.view.physicalSize = Size(width * pixelRatio, height * pixelRatio);
    // On a real phone the on-screen keyboard (opened by enterText), the
    // status/navigation bars and the user's font size would all leak into
    // the layout. None of them is part of the captured frame, so pin them:
    // every GIF is the full, unsqueezed 360x720 app screen.
    tester.view.viewInsets = FakeViewPadding.zero;
    tester.view.viewPadding = FakeViewPadding.zero;
    tester.view.padding = FakeViewPadding.zero;
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      tester.view.resetViewInsets();
      tester.view.resetViewPadding();
      tester.view.resetPadding();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
  }

  static bool _fontsLoaded = false;

  /// On a PC (`flutter test`, not a phone) text would render in the test
  /// font's placeholder boxes. Load the real fonts instead, from paths given
  /// as `--dart-define`s (see tool/capture_gifs.sh):
  /// - `ACD_MATERIAL_FONTS`: the Flutter SDK's `bin/cache/artifacts/material_fonts`
  /// - `ACD_CUPERTINO_ICONS`: `cupertino_icons`' `assets/CupertinoIcons.ttf`
  /// Roboto also stands in for the Cupertino system text families.
  Future<void> _loadHostFonts() async {
    if (_fontsLoaded || Platform.isAndroid || Platform.isIOS) return;
    _fontsLoaded = true;
    const String fontsDir = String.fromEnvironment('ACD_MATERIAL_FONTS');
    const String cupertinoIcons = String.fromEnvironment('ACD_CUPERTINO_ICONS');
    if (fontsDir.isEmpty) return;
    await tester.runAsync(() async {
      Future<ByteData> bytes(String path) async =>
          ByteData.sublistView(await File(path).readAsBytes());
      Future<void> load(String family, List<String> paths) async {
        final FontLoader loader = FontLoader(family);
        for (final String path in paths) {
          loader.addFont(bytes(path));
        }
        await loader.load();
      }

      final List<String> roboto = [
        for (final String w in const [
          'thin',
          'light',
          'regular',
          'medium',
          'bold',
          'black',
          'italic',
        ])
          '$fontsDir/roboto-$w.ttf',
      ];
      for (final String family in const [
        'Roboto',
        'CupertinoSystemText',
        'CupertinoSystemDisplay',
      ]) {
        await load(family, roboto);
      }
      await load('MaterialIcons', ['$fontsDir/materialicons-regular.otf']);
      if (cupertinoIcons.isNotEmpty) {
        await load('packages/cupertino_icons/CupertinoIcons', [cupertinoIcons]);
      }
    });
  }

  /// Snapshots the current frame to `outDir/frame_%04d.png`. Call right
  /// after a `pump`/gesture, once the boundary has painted the state you
  /// want captured.
  Future<void> snapshot() async {
    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary = tester
          .renderObject<RenderRepaintBoundary>(find.byKey(_boundaryKey));
      final ui.Image image = await boundary.toImage(pixelRatio: 1);
      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();
      final File file = File(
        '$_root/frame_${_frame.toString().padLeft(4, '0')}.png',
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
    _frame++;
  }

  /// Pumps [duration] then snapshots — the common "advance and capture" step.
  Future<void> pumpAndCapture([
    Duration duration = const Duration(milliseconds: 80),
  ]) async {
    await tester.pump(duration);
    await snapshot();
  }

  /// Snapshots the same settled frame [times] times — used to pad a hold
  /// (e.g. "stay on the success state for a second") without needing extra
  /// animation frames.
  Future<void> hold(int times) async {
    for (int i = 0; i < times; i++) {
      await pumpAndCapture(const Duration(milliseconds: 1));
    }
  }
}
