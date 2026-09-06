import 'package:flutter/material.dart';

import '../core/acd_animation.dart';
import '../core/acd_gravity.dart';
import 'acd_toast_card.dart';
import 'acd_toast_config.dart';
import 'acd_toast_controller.dart';
import 'acd_toast_lifecycle.dart';
import 'acd_toast_overflow_policy.dart';
import 'acd_toast_transition.dart';

/// One per active [ACDGravity] position — the actual `OverlayEntry` content
/// `ACDToastManager` inserts. Owns every visible toast's `AnimationController`
/// (via `TickerProviderStateMixin`, since many can be animating
/// simultaneously), reconciles `maxVisible`/`ACDToastOverflowPolicy` whenever
/// the position's toast list changes, and renders the reflowing stack.
class ACDToastStack extends StatefulWidget {
  /// Creates an [ACDToastStack] for [position], driven by [listenable].
  const ACDToastStack({
    super.key,
    required this.position,
    required this.listenable,
  });

  /// Which screen position this stack renders at.
  final ACDGravity position;

  /// The live list of toasts (queued, inserted, or showing) at [position].
  final ValueNotifier<List<ACDToastController>> listenable;

  @override
  State<ACDToastStack> createState() => _ACDToastStackState();
}

class _ACDToastStackState extends State<ACDToastStack>
    with TickerProviderStateMixin {
  // Guards against reentrancy: markInserted()/dispose() (called from within
  // _reconcile's own loop) fire ACDToastController.onChanged, which the
  // manager wires to mutate the very ValueNotifier this State listens to —
  // without this guard that reentrantly re-enters _reconcile() mid-loop,
  // double-processing controllers (e.g. creating a second
  // AnimationController for one already being set up by the outer call).
  bool _reconciling = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onListChanged);
    _reconcile();
  }

  @override
  void didUpdateWidget(covariant ACDToastStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onListChanged);
      widget.listenable.addListener(_onListChanged);
      _reconcile();
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onListChanged);
    super.dispose();
  }

  void _onListChanged() {
    if (_reconciling) {
      return; // reentrant notification from within our own reconcile pass
    }
    _reconcile();
    if (mounted) setState(() {});
  }

  /// Activates as many still-[ACDToastQueued] toasts as `maxVisible`/
  /// [ACDToastOverflowPolicy] allow, creating each one's entrance
  /// `AnimationController` (and progress-bar controller, if configured) the
  /// moment it's activated.
  void _reconcile() {
    if (_reconciling) return;
    _reconciling = true;
    try {
      final List<ACDToastController> all = widget.listenable.value;

      int activeSlots = 0;
      for (final ACDToastController c in all) {
        if (c.state is! ACDToastQueued) activeSlots++;
      }

      for (final ACDToastController c in all) {
        if (c.state is! ACDToastQueued) continue;

        final int? maxVisible = c.config.maxVisible;
        final ACDToastOverflowPolicy policy =
            c.config.overflowPolicy ?? ACDToastOverflowPolicy.queue;
        bool canInsert =
            maxVisible == null ||
            policy == ACDToastOverflowPolicy.unlimited ||
            activeSlots < maxVisible;

        if (!canInsert && policy == ACDToastOverflowPolicy.dropOldest) {
          for (final ACDToastController other in all) {
            if (other.state is! ACDToastQueued && !other.isDismissing) {
              other.requestDismiss();
              break;
            }
          }
          canInsert = true;
        }

        if (!canInsert) {
          continue; // stays queued under ACDToastOverflowPolicy.queue
        }

        c.animationController = AnimationController(
          vsync: this,
          duration: c.config.duration ?? ACDToastConfig.fallback.duration!,
        );
        final Duration? autoDismiss = c.config.autoDismissAfter;
        final bool sticky = autoDismiss == null || autoDismiss == Duration.zero;
        if ((c.config.showProgressBar ?? false) && !sticky) {
          c.progressController = AnimationController(
            vsync: this,
            duration: autoDismiss,
          );
        }
        c.markInserted();
        activeSlots++;
        c.animationController!.forward().then((_) {
          if (!c.isDismissing) c.markShowing();
        });
      }
    } finally {
      _reconciling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final List<ACDToastController> visible = widget.listenable.value
        .where((c) => c.state is! ACDToastQueued)
        .toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final ACDToastConfig groupConfig = visible.first.config;
    final EdgeInsets margin = acdResolveMarginForGravity(
      widget.position,
      groupConfig.margin ?? ACDToastConfig.fallback.margin!,
      direction,
    );
    final double spacing =
        groupConfig.stackSpacing ?? ACDToastConfig.fallback.stackSpacing!;

    final bool topSafe =
        widget.position == ACDGravity.top ||
        widget.position == ACDGravity.leftTop ||
        widget.position == ACDGravity.rightTop;
    final bool bottomSafe =
        widget.position == ACDGravity.bottom ||
        widget.position == ACDGravity.leftBottom ||
        widget.position == ACDGravity.rightBottom;

    final List<Widget> children = [];
    for (int i = 0; i < visible.length; i++) {
      if (i > 0) children.add(SizedBox(height: spacing));
      final ACDToastController c = visible[i];
      final ACDAnimation? exitAnim =
          c.config.exitAnimation ?? c.config.animation;
      children.add(
        ACDToastTransition(
          key: ValueKey(c.id),
          controller: c.animationController!,
          animatedFunc:
              c.config.exitAnimatedFunc ??
              c.config.animatedFunc ??
              (exitAnim != null
                  ? acdToastPresetAnimFn(exitAnim, direction)
                  : null),
          child: ACDToastCard(
            controller: c,
            config: c.config,
            onDismissRequested: ({bool immediate = false}) =>
                c.requestDismiss(immediate: immediate),
          ),
        ),
      );
    }

    return IgnorePointer(
      ignoring: false,
      child: Align(
        alignment: acdGravityToAlignment(widget.position, direction),
        child: Padding(
          padding: margin,
          child: SafeArea(
            top: topSafe,
            bottom: bottomSafe,
            left: false,
            right: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }
}
