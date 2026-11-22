// Generates the example app's launcher icons and splash images for Android
// and iOS from one vector design, so every size is drawn sharp (no resizing).
//
// Run from example/:
//   flutter test tool/generate_brand_assets.dart
//
// The mark: a white dialog card with a teal success check, two text lines and
// a button, a translucent card behind it (custom, layered), and an amber
// sparkle ("awesome") on a deep-teal gradient.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

const ui.Color tealLight = ui.Color(0xFF14B8A6); // teal-500
const ui.Color tealMid = ui.Color(0xFF0D9488); // teal-600
const ui.Color tealDeep = ui.Color(0xFF115E59); // teal-800
const ui.Color amber = ui.Color(0xFFFCD34D); // amber-300
const ui.Color lineGrey = ui.Color(0xFFCBD5E1); // slate-300
const ui.Color white = ui.Color(0xFFFFFFFF);

// ---------------------------------------------------------------- drawing --

void paintBackground(ui.Canvas c, double s) {
  final rect = ui.Rect.fromLTWH(0, 0, s, s);
  c.drawRect(
    rect,
    ui.Paint()
      ..shader = ui.Gradient.linear(ui.Offset.zero, ui.Offset(s, s), [
        tealMid,
        tealDeep,
      ]),
  );
  // Soft light from the top-left.
  c.drawRect(
    rect,
    ui.Paint()
      ..shader = ui.Gradient.radial(ui.Offset(s * 0.2, s * 0.1), s * 0.9, [
        white.withValues(alpha: 0.22),
        white.withValues(alpha: 0),
      ]),
  );
}

ui.Path sparkle(ui.Offset o, double r) {
  // Four-point star with concave sides.
  final p = ui.Path()..moveTo(o.dx, o.dy - r);
  final k = r * 0.22;
  for (int i = 0; i < 4; i++) {
    final a = -math.pi / 2 + i * math.pi / 2;
    final tip = o + ui.Offset(math.cos(a) * r, math.sin(a) * r);
    final next =
        o +
        ui.Offset(math.cos(a + math.pi / 2) * r, math.sin(a + math.pi / 2) * r);
    final mid =
        o +
        ui.Offset(math.cos(a + math.pi / 4) * k, math.sin(a + math.pi / 4) * k);
    if (i == 0) p.moveTo(tip.dx, tip.dy);
    p.quadraticBezierTo(mid.dx, mid.dy, next.dx, next.dy);
  }
  return p..close();
}

/// Draws the mark inside [box]. [mono] draws a single-colour silhouette with
/// the card details cut out (Android 13 themed icons).
void paintMark(ui.Canvas c, ui.Rect box, {bool mono = false}) {
  final u = box.width;
  ui.Offset p(double x, double y) => box.topLeft + ui.Offset(x * u, y * u);
  ui.Rect r(double l, double t, double rr, double b) =>
      ui.Rect.fromPoints(p(l, t), p(rr, b));

  c.saveLayer(box.inflate(u * 0.2), ui.Paint());

  // Back card.
  c.drawRRect(
    ui.RRect.fromRectAndRadius(
      r(0.24, 0.10, 0.90, 0.68),
      ui.Radius.circular(u * 0.09),
    ),
    ui.Paint()..color = white.withValues(alpha: mono ? 0.55 : 0.35),
  );

  final card = ui.RRect.fromRectAndRadius(
    r(0.10, 0.24, 0.78, 0.90),
    ui.Radius.circular(u * 0.10),
  );
  if (!mono) {
    c.drawRRect(
      card.shift(ui.Offset(0, u * 0.025)),
      ui.Paint()
        ..color = const ui.Color(0x55042F2E)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, u * 0.03),
    );
  }
  c.drawRRect(card, ui.Paint()..color = white);

  // Details: coloured, or punched out of the silhouette.
  ui.Paint detail(ui.Color color) => mono
      ? (ui.Paint()..blendMode = ui.BlendMode.clear)
      : (ui.Paint()..color = color);

  final checkCentre = p(0.44, 0.42);
  c.drawCircle(checkCentre, u * 0.095, detail(tealLight));
  final check = ui.Path()
    ..moveTo(checkCentre.dx - u * 0.042, checkCentre.dy + u * 0.002)
    ..lineTo(checkCentre.dx - u * 0.010, checkCentre.dy + u * 0.034)
    ..lineTo(checkCentre.dx + u * 0.046, checkCentre.dy - u * 0.030);
  c.drawPath(
    check,
    (mono ? (ui.Paint()..color = white) : (ui.Paint()..color = white))
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = u * 0.028
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round,
  );

  ui.RRect bar(double l, double t, double rr, double b) =>
      ui.RRect.fromRectAndRadius(r(l, t, rr, b), ui.Radius.circular(u));
  c.drawRRect(bar(0.25, 0.580, 0.63, 0.614), detail(lineGrey));
  c.drawRRect(bar(0.31, 0.645, 0.57, 0.679), detail(lineGrey));
  c.drawRRect(bar(0.22, 0.735, 0.66, 0.815), detail(tealMid));

  // Sparkle.
  c.drawPath(
    sparkle(p(0.11, 0.12), u * 0.085),
    ui.Paint()..color = mono ? white : amber,
  );
  c.drawPath(
    sparkle(p(0.94, 0.80), u * 0.045),
    ui.Paint()..color = mono ? white : amber.withValues(alpha: 0.9),
  );

  c.restore();
}

// ------------------------------------------------------------- rendering --

typedef Painter = void Function(ui.Canvas c, double s);

Future<void> render(
  String path,
  int px,
  Painter painter, {
  bool opaque = false,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  painter(canvas, px.toDouble());
  final image = await recorder.endRecording().toImage(px, px);
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(
    encodePng(px, px, data!.buffer.asUint8List(), opaque: opaque),
  );
}

/// Minimal PNG encoder. [opaque] writes RGB with no alpha channel, which
/// the App Store requires for the 1024 px marketing icon.
Uint8List encodePng(int w, int h, Uint8List rgba, {bool opaque = false}) {
  final channels = opaque ? 3 : 4;
  final raw = BytesBuilder();
  for (int y = 0; y < h; y++) {
    raw.addByte(0);
    for (int x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      final a = rgba[i + 3];
      if (opaque) {
        // Un-premultiply onto white is unnecessary: opaque art has a = 255.
        raw.add([rgba[i], rgba[i + 1], rgba[i + 2]]);
      } else if (a == 0) {
        raw.add([0, 0, 0, 0]);
      } else {
        // rawRgba is premultiplied; PNG wants straight alpha.
        int un(int v) => math.min(255, (v * 255 / a).round());
        raw.add([un(rgba[i]), un(rgba[i + 1]), un(rgba[i + 2]), a]);
      }
    }
  }
  final out = BytesBuilder()
    ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  void chunk(String type, List<int> body) {
    final t = type.codeUnits;
    out.add(_u32(body.length));
    out.add(t);
    out.add(body);
    out.add(_u32(_crc([...t, ...body])));
  }

  chunk('IHDR', [..._u32(w), ..._u32(h), 8, channels == 4 ? 6 : 2, 0, 0, 0]);
  chunk('IDAT', ZLibEncoder(level: 9).convert(raw.takeBytes()));
  chunk('IEND', const []);
  return out.takeBytes();
}

List<int> _u32(int v) => [
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];

final List<int> _crcTable = List.generate(256, (n) {
  int c = n;
  for (int k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc(List<int> bytes) {
  int c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

// ------------------------------------------------------------ compositions --

ui.Rect centred(double s, double fraction) {
  final m = s * fraction;
  return ui.Rect.fromLTWH((s - m) / 2, (s - m) / 2, m, m);
}

/// Full-bleed square icon (iOS; the OS applies its own mask).
void fullIcon(ui.Canvas c, double s) {
  paintBackground(c, s);
  paintMark(c, centred(s, 0.72));
}

/// Legacy Android icon with its own rounded-square or circle shape.
Painter legacyIcon({required bool round}) => (c, s) {
  final shape = ui.Rect.fromLTWH(s * 0.04, s * 0.04, s * 0.92, s * 0.92);
  final clip = ui.Path();
  round
      ? clip.addOval(shape)
      : clip.addRRect(
          ui.RRect.fromRectAndRadius(shape, ui.Radius.circular(s * 0.2)),
        );
  c.save();
  c.clipPath(clip);
  paintBackground(c, s);
  paintMark(c, centred(s, round ? 0.6 : 0.66));
  c.restore();
};

/// Adaptive foreground: content kept inside the 66/108 safe circle.
void adaptiveForeground(ui.Canvas c, double s) =>
    paintMark(c, centred(s, 0.54));

void adaptiveMonochrome(ui.Canvas c, double s) =>
    paintMark(c, centred(s, 0.54), mono: true);

/// Android 12+ splash icon: 288 dp canvas, visible inside a 192 dp circle.
void splashIcon(ui.Canvas c, double s) => paintMark(c, centred(s, 0.56));

/// Bare mark for the pre-Android-12 and iOS launch screens.
void splashLogo(ui.Canvas c, double s) =>
    paintMark(c, ui.Rect.fromLTWH(0, 0, s, s));

// ------------------------------------------------------------------ main --

void main() {
  testWidgets('generate brand assets', (tester) async {
    await tester.runAsync(() async {
      const android = 'android/app/src/main/res';
      const densities = {
        'mdpi': 1.0,
        'hdpi': 1.5,
        'xhdpi': 2.0,
        'xxhdpi': 3.0,
        'xxxhdpi': 4.0,
      };
      for (final MapEntry(key: d, value: m) in densities.entries) {
        int dp(double v) => (v * m).round();
        await render(
          '$android/mipmap-$d/ic_launcher.png',
          dp(48),
          legacyIcon(round: false),
        );
        await render(
          '$android/mipmap-$d/ic_launcher_round.png',
          dp(48),
          legacyIcon(round: true),
        );
        await render(
          '$android/mipmap-$d/ic_launcher_foreground.png',
          dp(108),
          adaptiveForeground,
        );
        await render(
          '$android/mipmap-$d/ic_launcher_monochrome.png',
          dp(108),
          adaptiveMonochrome,
        );
        await render(
          '$android/drawable-$d/splash_icon.png',
          dp(288),
          splashIcon,
        );
        await render(
          '$android/drawable-$d/splash_logo.png',
          dp(144),
          splashLogo,
        );
      }

      const ios = 'ios/Runner/Assets.xcassets';
      const iconSizes = {
        '20x20@1x': 20, '20x20@2x': 40, '20x20@3x': 60, //
        '29x29@1x': 29, '29x29@2x': 58, '29x29@3x': 87,
        '40x40@1x': 40, '40x40@2x': 80, '40x40@3x': 120,
        '60x60@2x': 120, '60x60@3x': 180,
        '76x76@1x': 76, '76x76@2x': 152, '83.5x83.5@2x': 167,
        '1024x1024@1x': 1024,
      };
      for (final MapEntry(key: name, value: px) in iconSizes.entries) {
        await render(
          '$ios/AppIcon.appiconset/Icon-App-$name.png',
          px,
          fullIcon,
          opaque: true,
        );
      }
      for (final (suffix, scale) in [('', 1), ('@2x', 2), ('@3x', 3)]) {
        await render(
          '$ios/LaunchImage.imageset/LaunchImage$suffix.png',
          144 * scale,
          splashLogo,
        );
      }

      // Preview sheet for reviewing the design (not used by the app).
      await render('tool/brand_preview.png', 1024, (c, s) {
        c.drawRect(
          ui.Rect.fromLTWH(0, 0, s, s),
          ui.Paint()..color = const ui.Color(0xFFF1F5F9),
        );
        void at(double x, double y, double size, Painter p) {
          c.save();
          c.translate(x, y);
          p(c, size);
          c.restore();
        }

        // iOS-style squircle-ish preview, Android circle, mono, splash.
        c.save();
        c.clipRRect(
          ui.RRect.fromRectAndRadius(
            const ui.Rect.fromLTWH(40, 40, 440, 440),
            const ui.Radius.circular(100),
          ),
        );
        at(40, 40, 440, fullIcon);
        c.restore();
        c.save();
        c.clipPath(
          ui.Path()..addOval(const ui.Rect.fromLTWH(544, 40, 440, 440)),
        );
        c.translate(544, 40);
        c.drawRect(
          const ui.Rect.fromLTWH(0, 0, 440, 440),
          ui.Paint()
            ..shader = ui.Gradient.linear(
              ui.Offset.zero,
              const ui.Offset(440, 440),
              [tealMid, tealDeep],
            ),
        );
        adaptiveForeground(c, 440);
        c.restore();
        c.drawRect(
          const ui.Rect.fromLTWH(40, 544, 440, 440),
          ui.Paint()..color = tealDeep,
        );
        c.save();
        c.translate(40, 544);
        adaptiveMonochrome(c, 440);
        c.restore();
        c.drawRect(
          const ui.Rect.fromLTWH(544, 544, 440, 440),
          ui.Paint()..color = const ui.Color(0xFF0F766E),
        );
        c.save();
        c.translate(544, 544);
        splashIcon(c, 440);
        c.restore();
      });
    });
  });
}
