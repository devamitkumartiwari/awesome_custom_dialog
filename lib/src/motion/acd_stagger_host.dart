import 'dart:math' as math;

import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:material_ui/material_ui.dart';

import '../design/internal/acd_platform_support.dart';
import 'acd_motion_effect.dart';
import 'acd_motion_frame.dart';
import 'acd_stagger_options.dart';

/// Internal: drives a whole staggered collection from **one** shared
/// `AnimationController` (the list's clock) instead of an `ACDMotion` — with
/// up to three controllers and a delay timer — per item.
///
/// Each item derives its own progress from the clock and its
/// [ACDStaggerOptions.delayForIndex] slot. Items built after their slot has
/// finished (scrolled into view later, or recycled) simply render settled:
/// nothing replays. The completion callbacks fire once when the clock
/// completes, which also works for lazily built lists whose off-screen items
/// never report in.
mixin ACDStaggerHost<T extends StatefulWidget>
    on SingleTickerProviderStateMixin<T> {
  /// Number of items in the collection.
  int get staggerItemCount;

  /// The collection's controlled visibility.
  bool get staggerVisible;

  /// Timing/effect configuration.
  ACDStaggerOptions get staggerOptions;

  /// Fired once the entrance finishes.
  VoidCallback? get staggerOnEntranceComplete;

  /// Fired once the exit finishes.
  VoidCallback? get staggerOnExitComplete;

  late final AnimationController _clock = AnimationController(vsync: this);
  bool _started = false;

  /// The visibility the clock is currently playing (entrance vs exit).
  late bool _playingVisible = staggerVisible;

  /// Total length of one entrance/exit pass for [count] items.
  Duration _totalFor(int count) {
    if (count == 0) return Duration.zero;
    final ACDStaggerOptions o = staggerOptions;
    final int slots = math.max(
      1,
      math.min(count, o.maxStaggeredItems ?? count),
    );
    return o.startDelay + o.interval * (slots - 1) + o.itemDuration;
  }

  @override
  void initState() {
    super.initState();
    // Starting hidden renders the exited end state with no animation.
    if (!_playingVisible) _clock.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Started here (not initState) so reduce motion is readable.
    if (!_started) {
      _started = true;
      if (_playingVisible) _play();
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (staggerVisible != _playingVisible) {
      _playingVisible = staggerVisible;
      _play();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _fireDone(bool visible) {
    (visible ? staggerOnEntranceComplete : staggerOnExitComplete)?.call();
  }

  Future<void> _play() async {
    final bool visible = _playingVisible;
    final Duration total = _totalFor(staggerItemCount);
    if (total == Duration.zero || acdReduceMotion(context)) {
      // Nothing to animate (empty list) or reduce motion: jump to the end
      // and report post-frame — never synchronously with a caller's build.
      _clock.stop();
      _clock.value = 1;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && visible == _playingVisible) _fireDone(visible);
      });
      return;
    }
    _clock.duration = total;
    try {
      await _clock.forward(from: 0).orCancel;
    } on TickerCanceled {
      return; // superseded by a visibility flip, or disposed
    }
    if (mounted && visible == _playingVisible) _fireDone(visible);
  }

  /// Wraps one item so it animates off the shared clock.
  Widget wrapStaggerItem(int index, Widget child) {
    final int count = staggerItemCount;
    return _ACDStaggerItem(
      key: ValueKey<int>(index),
      clock: _clock,
      total: _totalFor(count),
      delay: staggerOptions.delayForIndex(
        index,
        count,
        visible: _playingVisible,
      ),
      options: staggerOptions,
      effect: _playingVisible
          ? staggerOptions.effect
          : (staggerOptions.exitEffect ?? staggerOptions.effect.reversed),
      child: child,
    );
  }
}

class _ACDStaggerItem extends StatelessWidget {
  const _ACDStaggerItem({
    super.key,
    required this.clock,
    required this.total,
    required this.delay,
    required this.options,
    required this.effect,
    required this.child,
  });

  final AnimationController clock;
  final Duration total;
  final Duration delay;
  final ACDStaggerOptions options;
  final ACDMotionEffect effect;
  final Widget child;

  double _localProgress() {
    final int itemUs = options.itemDuration.inMicroseconds;
    if (itemUs == 0) return clock.value > 0 ? 1 : 0;
    final double elapsedUs = clock.value * total.inMicroseconds;
    return ((elapsedUs - delay.inMicroseconds) / itemUs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clock,
      builder: (context, child) {
        final double t = options.curve.transform(_localProgress());
        return acdApplyMotionSample(acdEvaluateMotion(effect, t), child!);
      },
      child: child,
    );
  }
}
