import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared brand seed for every README demo GIF — a modern indigo/violet
/// matching the accent already used in the dialog-styling demo
/// (`0xFF6A11CB`/`0xFF2575FC`), applied consistently via Material 3 so
/// every button/chip/switch/slider across all 20 GIFs shares one cohesive,
/// deliberate palette instead of Flutter's default debug blue.
const Color demoSeedColor = Color(0xFF6C5CE7);

/// A soft, warm off-white — elegant and neutral without the flat, slightly
/// clinical look of `Colors.grey.shade100`.
const Color demoBackground = Color(0xFFF8F7FC);

/// The theme every capture script's `MaterialApp` should use, for a
/// consistent, modern Material 3 look across the whole README.
final ThemeData demoTheme = ThemeData(
  useMaterial3: true,
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
    await tester.binding.setSurfaceSize(Size(width, height));
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(() => tester.view.resetDevicePixelRatio());
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
        '$outDir/frame_${_frame.toString().padLeft(4, '0')}.png',
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
