import 'dart:async' show Completer, Timer, unawaited;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'acd_motion.dart';
import 'acd_motion_effect.dart';
import 'acd_rest_effect_config.dart';

({Matrix4 matrix, double opacity, Offset offsetFactor, Offset blur})
_evaluateTextEffect(ACDMotionEffect effect, double t) {
  final double opacity = ui.lerpDouble(
    effect.beginOpacity,
    effect.endOpacity,
    t,
  )!;
  final double scale = ui.lerpDouble(effect.beginScale, effect.endScale, t)!;
  final double rotation =
      ui.lerpDouble(effect.beginRotationTurns, effect.endRotationTurns, t)! *
      2 *
      math.pi;
  final double skewX = ui.lerpDouble(effect.beginSkewX, effect.endSkewX, t)!;
  final double skewY = ui.lerpDouble(effect.beginSkewY, effect.endSkewY, t)!;
  final Offset offsetFactor = Offset.lerp(
    effect.beginOffsetFactor,
    effect.endOffsetFactor,
    t,
  )!;
  final Offset blur = Offset.lerp(
    effect.beginBlurSigma,
    effect.endBlurSigma,
    t,
  )!;
  final Matrix4 matrix = Matrix4.identity()
    ..rotateZ(rotation)
    ..scaleByDouble(scale, scale, 1.0, 1.0)
    ..setEntry(0, 1, skewX)
    ..setEntry(1, 0, skewY);
  return (
    matrix: matrix,
    opacity: opacity,
    offsetFactor: offsetFactor,
    blur: blur,
  );
}

/// Per-character staggered text animation, sharing [ACDMotionEffect]/
/// [ACDRestEffectConfig] with the [ACDMotion] family.
///
/// Grapheme-cluster aware (correct with emoji/combining marks, via
/// `String.characters`) and respects `Directionality`/[textDirection] for
/// stagger order without disturbing bidi text shaping — only the
/// stagger-timing assignment reverses under RTL, never the rendered
/// character order. The whole stagger is driven by a single
/// [AnimationController], so [onComplete] fires deterministically even
/// when [text] ends in whitespace.
///
/// ```dart
/// ACDAnimatedText(
///   text: 'Hello, world!',
///   effect: ACDMotionEffect.fadeSlideIn(),
///   onComplete: () => debugPrint('done'),
/// )
/// ```
class ACDAnimatedText extends StatefulWidget {
  /// Creates an [ACDAnimatedText].
  const ACDAnimatedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.visible = true,
    this.effect = const ACDMotionEffect(
      beginOpacity: 0,
      beginOffsetFactor: Offset(0, 0.3),
    ),
    this.exitEffect,
    this.initialDelay = Duration.zero,
    this.staggerDelay = const Duration(milliseconds: 40),
    this.spaceDelay,
    this.charDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.restEffect,
    this.onComplete,
    this.onExitComplete,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textDirection,
  });

  /// The text to animate.
  final String text;

  /// Text style. Defaults to the ambient `DefaultTextStyle`.
  final TextStyle? style;

  /// Paragraph alignment.
  final TextAlign? textAlign;

  /// Controlled visibility — flipping to `false` plays [exitEffect] on the
  /// whole rendered block (not per-character).
  final bool visible;

  /// Per-character entrance effect.
  final ACDMotionEffect effect;

  /// Whole-block exit effect. Defaults to [effect] reversed.
  final ACDMotionEffect? exitEffect;

  /// Delay before the first character starts.
  final Duration initialDelay;

  /// Delay between successive non-space characters starting.
  final Duration staggerDelay;

  /// Delay for a space character specifically, for natural word-by-word
  /// pacing. Still assigns the space a real timeline slot (never skips
  /// it), so it cannot reintroduce a missed-completion bug. Defaults to
  /// [staggerDelay].
  final Duration? spaceDelay;

  /// Each character's own entrance duration.
  final Duration charDuration;

  /// Curve applied within each character's entrance.
  final Curve curve;

  /// Looping "at-rest" effect applied to the whole rendered block once
  /// settled (not per-character).
  final ACDRestEffectConfig? restEffect;

  /// Fires once every character has finished entering.
  final VoidCallback? onComplete;

  /// Fires once the exit transition finishes.
  final VoidCallback? onExitComplete;

  /// Maximum lines before truncating/wrapping stops.
  final int? maxLines;

  /// Overflow behavior.
  final TextOverflow overflow;

  /// Explicit RTL override for stagger order. Defaults to the ambient
  /// `Directionality`.
  final TextDirection? textDirection;

  @override
  State<ACDAnimatedText> createState() => _ACDAnimatedTextState();
}

class _ACDAnimatedTextState extends State<ACDAnimatedText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1),
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_playEntrance());
  }

  @override
  void didUpdateWidget(covariant ACDAnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      unawaited(_playEntrance());
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _playEntrance() async {
    _delayTimer?.cancel();
    if (widget.initialDelay > Duration.zero) {
      final Completer<void> completer = Completer<void>();
      _delayTimer = Timer(widget.initialDelay, completer.complete);
      await completer.future;
      if (!mounted) return;
    }
    await _staggerController.forward(from: 0);
    if (mounted) widget.onComplete?.call();
  }

  List<Duration> _computeLogicalStartOffsets(List<String> chars, bool rtl) {
    final int n = chars.length;
    final List<Duration> byStaggerIndex = List<Duration>.filled(
      n,
      Duration.zero,
    );
    Duration running = Duration.zero;
    for (int s = 0; s < n; s++) {
      byStaggerIndex[s] = running;
      final int logicalAtS = rtl ? n - 1 - s : s;
      final bool isSpace = chars[logicalAtS].trim().isEmpty;
      running += isSpace
          ? (widget.spaceDelay ?? widget.staggerDelay)
          : widget.staggerDelay;
    }
    return [
      for (int logical = 0; logical < n; logical++)
        byStaggerIndex[rtl ? n - 1 - logical : logical],
    ];
  }

  Widget _buildStaggeredText(BuildContext context) {
    final List<String> chars = widget.text.characters.toList();
    final TextDirection direction =
        widget.textDirection ?? Directionality.of(context);
    final bool rtl = direction == TextDirection.rtl;
    final TextStyle effectiveStyle =
        widget.style ?? DefaultTextStyle.of(context).style;

    if (chars.isEmpty) {
      return Text(
        '',
        style: effectiveStyle,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    final List<Duration> starts = _computeLogicalStartOffsets(chars, rtl);
    final Duration span = starts.reduce((a, b) => a > b ? a : b);
    final Duration total = span + widget.charDuration;
    final int totalMicros = total.inMicroseconds == 0
        ? 1
        : total.inMicroseconds;
    if (_staggerController.duration != total) {
      _staggerController.duration = total;
    }

    return Text.rich(
      TextSpan(
        children: [
          for (int i = 0; i < chars.length; i++)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: AnimatedBuilder(
                animation: _staggerController,
                builder: (context, child) {
                  final double startFrac =
                      starts[i].inMicroseconds / totalMicros;
                  final double endFrac =
                      ((starts[i] + widget.charDuration).inMicroseconds /
                              totalMicros)
                          .clamp(startFrac, 1.0);
                  final double t = endFrac <= startFrac
                      ? 1.0
                      : widget.curve.transform(
                          ((_staggerController.value - startFrac) /
                                  (endFrac - startFrac))
                              .clamp(0.0, 1.0),
                        );
                  final ev = _evaluateTextEffect(widget.effect, t);
                  Widget glyph = Text(chars[i], style: effectiveStyle);
                  glyph = Opacity(
                    opacity: ev.opacity.clamp(0.0, 1.0),
                    child: glyph,
                  );
                  glyph = Transform(
                    transform: ev.matrix,
                    alignment: Alignment.center,
                    child: glyph,
                  );
                  if (ev.offsetFactor != Offset.zero) {
                    glyph = FractionalTranslation(
                      translation: ev.offsetFactor,
                      child: glyph,
                    );
                  }
                  return glyph;
                },
              ),
            ),
        ],
      ),
      textAlign: widget.textAlign ?? TextAlign.start,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ACDMotion(
      visible: widget.visible,
      effect: const ACDMotionEffect(),
      exitEffect: widget.exitEffect ?? widget.effect.reversed,
      autoStart: false,
      restEffect: widget.restEffect,
      onExitComplete: widget.onExitComplete,
      child: _buildStaggeredText(context),
    );
  }
}
