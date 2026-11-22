import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/acd_animation.dart';
import '../core/acd_gravity.dart';
import 'acd_toast_card.dart';
import 'acd_toast_config.dart';
import 'acd_toast_controller.dart';
import 'acd_toast_dismiss_reason.dart';
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
    // Normally a stack is only removed once empty. If it's torn down with
    // toasts still in it (its Overlay/ACDToastLayer went away), those
    // toasts can never show or close: stop their tickers now (they belong
    // to this State) and dispose them right after this frame's teardown, so
    // `closed` completes and the manager drops them.
    final List<ACDToastController> orphans = widget.listenable.value
        .where((c) => c.state is! ACDToastDisposed)
        .toList();
    for (final ACDToastController c in orphans) {
      c.animationController?.stop(canceled: true);
      c.progressController?.stop(canceled: true);
    }
    if (orphans.isNotEmpty) {
      scheduleMicrotask(() {
        for (final ACDToastController c in orphans) {
          c.dispose();
        }
      });
    }
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
        // A maxVisible below 1 would queue forever; treat it as 1.
        bool canInsert =
            maxVisible == null ||
            policy == ACDToastOverflowPolicy.unlimited ||
            activeSlots < math.max(1, maxVisible);

        if (!canInsert && policy == ACDToastOverflowPolicy.dropOldest) {
          for (final ACDToastController other in all) {
            if (other.state is! ACDToastQueued && !other.isDismissing) {
              other.requestDismiss(reason: ACDToastDismissReason.replaced);
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
        // Screen-reader users navigate element by element and can't reach
        // a toast's action buttons before a timer fires: keep actionable
        // toasts up until dismissed. (Read from the platform, not
        // MediaQuery — this also runs from initState.)
        c.holdForAccessibility =
            (c.config.actions?.isNotEmpty ?? false) &&
            WidgetsBinding
                .instance
                .platformDispatcher
                .accessibilityFeatures
                .accessibleNavigation;
        final bool sticky =
            autoDismiss == null ||
            autoDismiss == Duration.zero ||
            c.holdForAccessibility;
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
      // Entrance and exit share one controller (forward = in, reverse =
      // out), so pick the transition by phase. Previously the exit settings
      // were always preferred, so setting an exit animation silently
      // replaced the entrance too. requestDismiss() flips the state (and
      // notifies this stack) before reversing, so the exit applies in time.
      final ACDAnimation? anim = c.isDismissing
          ? (c.config.exitAnimation ?? c.config.animation)
          : c.config.animation;
      final Function(Widget, Animation<double>)? customFn = c.isDismissing
          ? (c.config.exitAnimatedFunc ?? c.config.animatedFunc)
          : c.config.animatedFunc;
      children.add(
        ACDToastTransition(
          // Identity, not id: a new toast may reuse the id of one still exiting.
          key: ObjectKey(c),
          controller: c.animationController!,
          animatedFunc:
              customFn ??
              (anim != null ? acdToastPresetAnimFn(anim, direction) : null),
          child: ACDToastCard(
            controller: c,
            config: c.config,
            onDismissRequested: ({
              bool immediate = false,
              ACDToastDismissReason reason = ACDToastDismissReason.programmatic,
            }) => c.requestDismiss(immediate: immediate, reason: reason),
          ),
        ),
      );
    }

    final Widget stack = IgnorePointer(
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

    // blockBackgroundInteraction: while any blocking toast is up (and not
    // already leaving), an invisible barrier under the stack swallows taps
    // on the rest of the app. The toasts themselves stay interactive.
    final bool block = visible.any(
      (c) => !c.isDismissing && (c.config.blockBackgroundInteraction ?? false),
    );
    if (!block) return stack;
    return Stack(
      children: [
        const Positioned.fill(
          child: ModalBarrier(dismissible: false, color: Color(0x00000000)),
        ),
        stack,
      ],
    );
  }
}
