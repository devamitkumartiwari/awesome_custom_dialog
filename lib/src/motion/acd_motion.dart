import 'dart:async' show Completer, Timer, unawaited;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../design/internal/acd_platform_support.dart';
import 'acd_motion_effect.dart';
import 'acd_motion_frame.dart';
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

  // Reduce motion (MediaQuery.disableAnimations): entrances/exits jump to
  // their end state (callbacks still fire) and looping rest effects never
  // start. Read in didChangeDependencies — MediaQuery isn't readable in
  // initState.
  bool _reduceMotion = false;
  bool _pendingInitialEntrance = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      _activeEffect = widget.effect;
      if (widget.autoStart) {
        // Started from didChangeDependencies (runs synchronously right
        // after initState), once reduce-motion is known.
        _pendingInitialEntrance = true;
      } else {
        _controller.value = 1;
      }
    } else {
      _activeEffect = widget.exitEffect ?? widget.effect.reversed;
      _controller.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduce = acdReduceMotion(context);
    final bool changed = reduce != _reduceMotion;
    _reduceMotion = reduce;
    if (!_initialized) {
      _initialized = true;
      if (_pendingInitialEntrance) {
        _pendingInitialEntrance = false;
        unawaited(_playEntrance());
      } else if (widget.visible && !widget.autoStart) {
        _maybeStartRest();
      }
    }
    if (changed && reduce) {
      _restDelayTimer?.cancel();
      _restController
        ..stop()
        ..value = 0;
    }
  }

  /// Runs the entrance/exit controller to completion; `false` if it was
  /// interrupted (e.g. an exit superseding an entrance).
  Future<bool> _runTransition() async {
    _controller.duration = widget.duration;
    if (_reduceMotion) {
      _controller.value = 1;
      return true;
    }
    try {
      await _controller.forward(from: 0).orCancel;
      return true;
    } on TickerCanceled {
      return false;
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
    if (_reduceMotion) setState(() {}); // repaint with the end state now
    if (!await _runTransition() || !mounted) return;
    widget.onEntranceComplete?.call();
    _maybeStartRest();
  }

  Future<void> _playExit() async {
    _restController.stop();
    _restDelayTimer?.cancel();
    _entranceDelayTimer?.cancel();
    _activeEffect = widget.exitEffect ?? widget.effect.reversed;
    if (_reduceMotion) setState(() {});
    if (!await _runTransition() || !mounted) return;
    widget.onExitComplete?.call();
  }

  void _maybeStartRest() {
    final ACDRestEffectConfig? rest = widget.restEffect;
    if (rest == null || !mounted || !widget.visible || _reduceMotion) return;
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
    // Play the tap effect exactly once per tap; when deferring, chain the
    // callback onto that same run (previously a second, restarting run was
    // started, so the effect visibly played twice).
    final Future<void> effect = _playTapEffect();
    if (widget.onTap != null && widget.deferTapCallbackUntilAnimationComplete) {
      unawaited(
        effect.then((_) {
          if (mounted) widget.onTap!();
        }),
      );
      return;
    }
    unawaited(effect);
    widget.onTap?.call();
  }

  ACDMotionSample _evaluate(ACDMotionEffect effect, double t) =>
      acdEvaluateMotion(effect, t);

  @override
  Widget build(BuildContext context) {
    if (widget.effectBuilder != null) {
      // Listen to the controller directly: the builder receives the raw
      // progress by contract, and a CurvedAnimation allocated per build
      // would leak a status listener on _controller every rebuild.
      return AnimatedBuilder(
        animation: _controller,
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

        return acdApplyMotionSample((
          matrix: matrix,
          opacity: opacity,
          offsetFactor: offsetFactor,
          blur: blur,
        ), child!);
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

    // A looping rest effect repaints every frame: isolate it so the rest of
    // the screen isn't repainted with it.
    if (widget.restEffect != null) content = RepaintBoundary(child: content);
    return content;
  }
}
