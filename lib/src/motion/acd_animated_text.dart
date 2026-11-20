import 'dart:async' show Completer, Timer, unawaited;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../design/internal/acd_platform_support.dart';
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
/// `String.characters`) and respects `Directionality`/[textDirection]:
/// characters stagger in reading order, so under RTL the sweep starts at
/// the right edge, without disturbing bidi text shaping. The whole stagger is driven by a single
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

  /// Text direction for layout and stagger order (the stagger always
  /// follows reading order). Defaults to the ambient `Directionality`.
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
    // Started from didChangeDependencies (runs synchronously right after
    // initState): the entrance reads reduce-motion from MediaQuery, which
    // isn't readable inside initState.
  }

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      unawaited(_playEntrance());
    }
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
    // Size the controller before starting: changing `duration` mid-run
    // doesn't affect the active simulation, so leaving this to build() made
    // the very first entrance finish in the 1ms placeholder duration.
    _staggerController.duration = _totalDuration(
      _computeLogicalStartOffsets(widget.text.characters.toList()),
    );
    if (acdReduceMotion(context)) {
      _staggerController.value = 1; // show the text at once
    } else {
      try {
        await _staggerController.forward(from: 0).orCancel;
      } on TickerCanceled {
        return; // superseded by a newer entrance
      }
    }
    if (mounted) widget.onComplete?.call();
  }

  /// Start offset for each character, staggered in logical (reading) order.
  ///
  /// Since Flutter 3.50, text layout places [WidgetSpan]s in bidirectional
  /// visual order, so logical order already sweeps right-to-left under RTL —
  /// no direction-specific reordering is needed (or correct) here.
  List<Duration> _computeLogicalStartOffsets(List<String> chars) {
    final List<Duration> starts = List<Duration>.filled(
      chars.length,
      Duration.zero,
    );
    Duration running = Duration.zero;
    for (int i = 0; i < chars.length; i++) {
      starts[i] = running;
      final bool isSpace = chars[i].trim().isEmpty;
      running += isSpace
          ? (widget.spaceDelay ?? widget.staggerDelay)
          : widget.staggerDelay;
    }
    return starts;
  }

  Duration _totalDuration(List<Duration> starts) {
    final Duration span = starts.isEmpty
        ? Duration.zero
        : starts.reduce((a, b) => a > b ? a : b);
    return span + widget.charDuration;
  }

  Widget _buildStaggeredText(BuildContext context) {
    final List<String> chars = widget.text.characters.toList();
    final TextDirection direction =
        widget.textDirection ?? Directionality.of(context);
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

    final List<Duration> starts = _computeLogicalStartOffsets(chars);
    final Duration total = _totalDuration(starts);
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
      textDirection: direction,
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
      // Screen readers get the whole string once — not one letter per
      // animated glyph span.
      child: Semantics(
        label: widget.text,
        child: ExcludeSemantics(child: _buildStaggeredText(context)),
      ),
    );
  }
}
