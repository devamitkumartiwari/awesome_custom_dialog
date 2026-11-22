import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'acd_motion_effect.dart';

/// Shared, immutable per-item timing/effect configuration for
/// [ACDStaggeredList], [ACDStaggeredGrid], and the opt-in `stagger`/
/// `contentStagger` parameters on `ACDDialog`'s list builders and content —
/// one animation-timing vocabulary instead of duplicated params per call
/// site.
final class ACDStaggerOptions {
  /// Creates an [ACDStaggerOptions].
  const ACDStaggerOptions({
    this.interval = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 400),
    this.startDelay = Duration.zero,
    this.curve = Curves.easeOut,
    this.effect = const ACDMotionEffect(
      beginOpacity: 0,
      beginOffsetFactor: Offset(0, 0.3),
    ),
    this.exitEffect,
    this.reverseOnExit = true,
    this.maxStaggeredItems = 20,
  }) : assert(
         maxStaggeredItems == null || maxStaggeredItems > 0,
         'maxStaggeredItems must be null or at least 1',
       );

  /// Delay added per successive item on top of [startDelay].
  final Duration interval;

  /// Duration of each item's own entrance/exit transition.
  final Duration itemDuration;

  /// Delay before the first item begins.
  final Duration startDelay;

  /// Curve applied within [itemDuration].
  final Curve curve;

  /// Entrance effect played by each item.
  final ACDMotionEffect effect;

  /// Exit effect played by each item. Defaults to [effect] reversed (via
  /// [ACDMotion]) when left `null`.
  final ACDMotionEffect? exitEffect;

  /// When `true` (the default), the last item to enter is the first to
  /// exit — a common "closing" feel. When `false`, items exit in the same
  /// order they entered.
  final bool reverseOnExit;

  /// Caps how many successive items get their own stagger slot. Items past
  /// the cap share the last slot, so long (lazily built) lists don't make
  /// item 200 wait 200 × [interval] before appearing when scrolled into
  /// view. `null` removes the cap.
  final int? maxStaggeredItems;

  /// Returns a copy with the given fields replaced.
  ACDStaggerOptions copyWith({
    Duration? interval,
    Duration? itemDuration,
    Duration? startDelay,
    Curve? curve,
    ACDMotionEffect? effect,
    ACDMotionEffect? exitEffect,
    bool? reverseOnExit,
    int? maxStaggeredItems,
  }) {
    return ACDStaggerOptions(
      interval: interval ?? this.interval,
      itemDuration: itemDuration ?? this.itemDuration,
      startDelay: startDelay ?? this.startDelay,
      curve: curve ?? this.curve,
      effect: effect ?? this.effect,
      exitEffect: exitEffect ?? this.exitEffect,
      reverseOnExit: reverseOnExit ?? this.reverseOnExit,
      maxStaggeredItems: maxStaggeredItems ?? this.maxStaggeredItems,
    );
  }

  /// The per-item delay for [index] out of [itemCount] total items, taking
  /// [reverseOnExit] into account when [visible] is `false`.
  Duration delayForIndex(int index, int itemCount, {required bool visible}) {
    final int effectiveIndex = (!visible && reverseOnExit)
        ? itemCount - 1 - index
        : index;
    final int? cap = maxStaggeredItems == null
        ? null
        : math.max(1, maxStaggeredItems!);
    final int slot = cap == null || effectiveIndex < cap
        ? effectiveIndex
        : cap - 1;
    return startDelay + interval * (slot < 0 ? 0 : slot);
  }
}
