import 'dart:async' show Completer, Timer, unawaited;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'acd_motion_effect.dart';
import 'acd_pop_animation.dart';
import 'acd_rest_effect_config.dart';
import 'acd_rest_effect_math.dart';

/// A dependency-free entrance/exit/rest/tap animation wrapper for any
/// widget, driven by a single shared [ACDMotionEffect] vocabulary.
///
/// ```dart
/// ACDMotion(
///   effect: ACDMotionEffect.fadeSlideIn(),
///   restEffect: const ACDRestEffectConfig(effect: ACDMotionRestEffect.pulse),
///   onTap: () => debugPrint('tapped'),
///   child: const FlutterLogo(),
/// )
/// ```
///
/// Nesting is structurally safe — every [ACDMotion] instance owns its own
/// [AnimationController]s via [TickerProviderStateMixin], never a shared or
/// hoisted one. Every frame's scale/rotation/skew is composed into a single
/// [Matrix4] (translation is applied separately via [FractionalTranslation],
/// since [ACDMotionEffect]'s offsets are size-relative fractions, not
/// pixels) — never nested `Transform.translate`/`.scale`/`.rotate` widgets.
class ACDMotion extends StatefulWidget {
  /// Creates an [ACDMotion].
  const ACDMotion({
    super.key,
    required this.child,
    this.visible = true,
    this.effect = const ACDMotionEffect(
      beginOpacity: 0,
      beginOffsetFactor: Offset(0, 0.3),
    ),
    this.exitEffect,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
    this.delay = Duration.zero,
    this.autoStart = true,
    this.restEffect,
    this.onTap,
    this.tapEffect,
    this.onTapDown,
    this.onTapUp,
    this.onLongPress,
    this.hapticFeedbackOnTap = false,
    this.deferTapCallbackUntilAnimationComplete = false,
    this.tapEffectRepeatCount = 1,
    this.mouseCursor,
    this.effectBuilder,
    this.onEntranceComplete,
    this.onExitComplete,
  });

  /// The wrapped widget.
  final Widget child;

  /// Controlled visibility. Flipping this to `false` plays [exitEffect]
  /// instead of unmounting — the widget stays in the tree at its settled
  /// exited visual state; actually removing it afterward remains the
  /// caller's job.
  final bool visible;

  /// Entrance effect, played once when this widget first mounts (if
  /// [autoStart]) or when [visible] flips from `false` to `true`.
  final ACDMotionEffect effect;

  /// Exit effect, played when [visible] flips from `true` to `false`.
  /// Defaults to [effect] reversed.
  final ACDMotionEffect? exitEffect;

  /// Duration of the entrance/exit transition.
  final Duration duration;

  /// Curve applied within [duration].
  final Curve curve;

  /// Delay before the entrance transition begins.
  final Duration delay;

  /// Whether to play the entrance transition immediately on mount. When
  /// `false`, the widget renders already-settled at [effect]'s end state
  /// with no animation, until [visible] is externally toggled.
  final bool autoStart;

  /// Looping "at-rest" effect, layered on top of the entrance/exit once
  /// settled.
  final ACDRestEffectConfig? restEffect;

  /// Enables the tap gesture layer and fires on a completed tap.
  final VoidCallback? onTap;

  /// One-shot effect played on tap. `null` plays a gentle built-in
  /// scale-pop instead.
  final ACDMotionEffect? tapEffect;

  /// Fires on pointer-down, independent of whether the tap completes.
  final VoidCallback? onTapDown;

  /// Fires on pointer-up, independent of whether the tap completes.
  final VoidCallback? onTapUp;

  /// Fires on a long-press.
  final VoidCallback? onLongPress;

  /// Fires `HapticFeedback.lightImpact()` on tap.
  final bool hapticFeedbackOnTap;

  /// When `true`, [onTap] fires only once [tapEffect]'s animation finishes,
  /// not immediately on gesture detection.
  final bool deferTapCallbackUntilAnimationComplete;

  /// How many times the tap effect plays per tap.
  final int tapEffectRepeatCount;

  /// Pointer cursor on desktop/web. Defaults to [SystemMouseCursors.click]
  /// when [onTap] is set.
  final MouseCursor? mouseCursor;

  /// Escape hatch fully replacing effect-driven rendering — receives the
  /// raw `0`–`1` entrance/exit progress and the child to transform however
  /// the caller wants.
  final Widget Function(BuildContext context, double progress, Widget child)?
  effectBuilder;

  /// Fires once the entrance transition finishes.
  final VoidCallback? onEntranceComplete;

  /// Fires once the exit transition finishes.
  final VoidCallback? onExitComplete;

  @override
  State<ACDMotion> createState() => _ACDMotionState();
}

class _ACDMotionState extends State<ACDMotion> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final AnimationController _restController = AnimationController(
    vsync: this,
  );
  late final AnimationController _tapController = AnimationController(
    vsync: this,
    duration: acdPopAnimationDuration,
  );
  late final Animation<double> _defaultTapScale = _tapController.drive(
    acdPopScaleTween(),
  );

  late ACDMotionEffect _activeEffect;
  Timer? _entranceDelayTimer;
  Timer? _restDelayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      _activeEffect = widget.effect;
      if (widget.autoStart) {
        unawaited(_playEntrance());
      } else {
        _controller.value = 1;
        _maybeStartRest();
      }
    } else {
      _activeEffect = widget.exitEffect ?? widget.effect.reversed;
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant ACDMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        unawaited(_playEntrance());
      } else {
        unawaited(_playExit());
      }
    }
  }

  @override
  void dispose() {
    _entranceDelayTimer?.cancel();
    _restDelayTimer?.cancel();
    _controller.dispose();
    _restController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _playEntrance() async {
    _restController.stop();
    _restDelayTimer?.cancel();
    _entranceDelayTimer?.cancel();
    if (widget.delay > Duration.zero) {
      final Completer<void> completer = Completer<void>();
      _entranceDelayTimer = Timer(widget.delay, completer.complete);
      await completer.future;
      if (!mounted) return;
    }
    _activeEffect = widget.effect;
    _controller.duration = widget.duration;
    await _controller.forward(from: 0);
    if (!mounted) return;
    widget.onEntranceComplete?.call();
    _maybeStartRest();
  }

  Future<void> _playExit() async {
    _restController.stop();
    _restDelayTimer?.cancel();
    _entranceDelayTimer?.cancel();
    _activeEffect = widget.exitEffect ?? widget.effect.reversed;
    _controller.duration = widget.duration;
    await _controller.forward(from: 0);
    if (!mounted) return;
    widget.onExitComplete?.call();
  }

  void _maybeStartRest() {
    final ACDRestEffectConfig? rest = widget.restEffect;
    if (rest == null || !mounted || !widget.visible) return;
    _restController.duration = rest.resolvedPeriod;
    _restDelayTimer?.cancel();
    void start() {
      if (!mounted || !widget.visible) return;
      if (rest.repeatCount == null) {
        _restController.repeat();
      } else {
        _restController.repeat(count: rest.repeatCount);
      }
    }

    if (rest.delay > Duration.zero) {
      _restDelayTimer = Timer(rest.delay, start);
    } else {
      start();
    }
  }

  Future<void> _playTapEffect() async {
    for (int i = 0; i < widget.tapEffectRepeatCount; i++) {
      if (!mounted) return;
      _tapController.duration = widget.tapEffect == null
          ? acdPopAnimationDuration
          : widget.duration;
      await _tapController.forward(from: 0);
      if (!mounted) return;
      if (widget.tapEffect != null) {
        await _tapController.reverse();
      }
    }
  }

  void _handleTap() {
    if (widget.hapticFeedbackOnTap) HapticFeedback.lightImpact();
    unawaited(_playTapEffect());
    if (widget.onTap == null) return;
    if (widget.deferTapCallbackUntilAnimationComplete) {
      unawaited(
        _playTapEffect().then((_) {
          if (mounted) widget.onTap!();
        }),
      );
    } else {
      widget.onTap!();
    }
  }

  ({Matrix4 matrix, double opacity, Offset offsetFactor, Offset blur})
  _evaluate(ACDMotionEffect effect, double t) {
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

  @override
  Widget build(BuildContext context) {
    if (widget.effectBuilder != null) {
      return AnimatedBuilder(
        animation: CurvedAnimation(parent: _controller, curve: widget.curve),
        builder: (context, child) =>
            widget.effectBuilder!(context, _controller.value, child!),
        child: widget.child,
      );
    }

    Widget content = AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _restController,
        _tapController,
      ]),
      builder: (context, child) {
        final double t = widget.curve.transform(
          _controller.value.clamp(0.0, 1.0),
        );
        final entrance = _evaluate(_activeEffect, t);

        Matrix4 matrix = entrance.matrix;
        Offset offsetFactor = entrance.offsetFactor;
        double opacity = entrance.opacity;
        Offset blur = entrance.blur;

        final ACDRestEffectConfig? rest = widget.restEffect;
        if (rest != null && widget.visible && _controller.value == 1) {
          final double phase = rest.resolvedPeriod == Duration.zero
              ? 0
              : _restController.value;
          final Matrix4 restMatrix =
              rest.customEffect?.call(phase) ??
              acdRestEffectMatrix(
                effect: rest.effect,
                phase: phase,
                strength: rest.resolvedStrength,
              );
          matrix = matrix.multiplied(restMatrix);
        }

        if (widget.tapEffect != null) {
          final tap = _evaluate(widget.tapEffect!, _tapController.value);
          matrix = matrix.multiplied(tap.matrix);
          opacity *= tap.opacity;
          offsetFactor += tap.offsetFactor;
          blur += tap.blur;
        } else if (_tapController.value > 0) {
          final double s = _defaultTapScale.value;
          matrix = matrix.multiplied(
            Matrix4.identity()..scaleByDouble(s, s, 1.0, 1.0),
          );
        }

        Widget result = child!;
        if (blur.dx > 0 || blur.dy > 0) {
          result = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: blur.dx, sigmaY: blur.dy),
            child: result,
          );
        }
        result = Opacity(opacity: opacity.clamp(0.0, 1.0), child: result);
        result = Transform(
          transform: matrix,
          alignment: Alignment.center,
          child: result,
        );
        if (offsetFactor != Offset.zero) {
          result = FractionalTranslation(
            translation: offsetFactor,
            child: result,
          );
        }
        return result;
      },
      child: widget.child,
    );

    final bool hasGestures =
        widget.onTap != null ||
        widget.onTapDown != null ||
        widget.onTapUp != null ||
        widget.onLongPress != null;
    if (hasGestures) {
      content = MouseRegion(
        cursor: widget.mouseCursor ?? SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap != null ? _handleTap : null,
          onTapDown: widget.onTapDown != null
              ? (_) => widget.onTapDown!()
              : null,
          onTapUp: widget.onTapUp != null ? (_) => widget.onTapUp!() : null,
          onLongPress: widget.onLongPress,
          child: content,
        ),
      );
    }

    return content;
  }
}
