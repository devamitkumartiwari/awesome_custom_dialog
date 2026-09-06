import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;

import 'acd_motion.dart';
import 'acd_stagger_options.dart';

/// A dependency-free, staggered-entrance/exit `ListView` — each item is
/// wrapped in an [ACDMotion] whose `delay` increases with its index, so
/// items appear to cascade in one after another instead of all at once.
///
/// ```dart
/// ACDStaggeredList(
///   itemCount: items.length,
///   itemBuilder: (context, index) => ListTile(title: Text(items[index])),
/// )
/// ```
///
/// Toggle [visible] to `false` to play a staggered exit (in reverse order
/// by default, see [ACDStaggerOptions.reverseOnExit]) instead of unmounting
/// immediately — matching [ACDMotion]'s own entrance/exit model rather than
/// introducing a second animation vocabulary.
class ACDStaggeredList extends StatefulWidget {
  /// Creates an [ACDStaggeredList].
  const ACDStaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.visible = true,
    this.options = const ACDStaggerOptions(),
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.onAllEntranceComplete,
    this.onAllExitComplete,
  });

  /// Number of items to build.
  final int itemCount;

  /// Builds the unwrapped content for the item at `index` — the stagger
  /// wrapping is applied automatically.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Builds a separator between items, like `ListView.separated`. Leave
  /// `null` for no separators.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Controlled visibility. Flip to `false` to play a staggered exit.
  final bool visible;

  /// Per-item timing/effect configuration.
  final ACDStaggerOptions options;

  /// Forwarded to the underlying `ListView`.
  final Axis scrollDirection;

  /// Forwarded to the underlying `ListView`.
  final bool reverse;

  /// Forwarded to the underlying `ListView`.
  final ScrollController? controller;

  /// Forwarded to the underlying `ListView`.
  final bool? primary;

  /// Forwarded to the underlying `ListView`.
  final ScrollPhysics? physics;

  /// Forwarded to the underlying `ListView`.
  final bool shrinkWrap;

  /// Forwarded to the underlying `ListView`.
  final EdgeInsetsGeometry? padding;

  /// Fires once every item's entrance transition has finished.
  final VoidCallback? onAllEntranceComplete;

  /// Fires once every item's exit transition has finished.
  final VoidCallback? onAllExitComplete;

  @override
  State<ACDStaggeredList> createState() => _ACDStaggeredListState();
}

class _ACDStaggeredListState extends State<ACDStaggeredList> {
  int _entranceDone = 0;
  int _exitDone = 0;

  @override
  void initState() {
    super.initState();
    _maybeFireEmptyCompletion();
  }

  @override
  void didUpdateWidget(covariant ACDStaggeredList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      _entranceDone = 0;
      _exitDone = 0;
      _maybeFireEmptyCompletion();
    }
  }

  // An empty list has no items to report completion for — fire immediately
  // (post-frame, so it's never synchronous with a caller's setState/build)
  // rather than leaving the caller waiting forever.
  void _maybeFireEmptyCompletion() {
    if (widget.itemCount != 0) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.visible) {
        widget.onAllEntranceComplete?.call();
      } else {
        widget.onAllExitComplete?.call();
      }
    });
  }

  void _handleEntranceComplete() {
    _entranceDone++;
    if (_entranceDone == widget.itemCount) {
      widget.onAllEntranceComplete?.call();
    }
  }

  void _handleExitComplete() {
    _exitDone++;
    if (_exitDone == widget.itemCount) {
      widget.onAllExitComplete?.call();
    }
  }

  Widget _wrap(BuildContext context, int index, Widget child) {
    return ACDMotion(
      key: ValueKey<int>(index),
      visible: widget.visible,
      delay: widget.options.delayForIndex(
        index,
        widget.itemCount,
        visible: widget.visible,
      ),
      duration: widget.options.itemDuration,
      curve: widget.options.curve,
      effect: widget.options.effect,
      exitEffect: widget.options.exitEffect,
      onEntranceComplete: _handleEntranceComplete,
      onExitComplete: _handleExitComplete,
      child: child,
    );
  }

  Widget _wrappedBuilder(BuildContext context, int index) =>
      _wrap(context, index, widget.itemBuilder(context, index));

  @override
  Widget build(BuildContext context) {
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemCount: widget.itemCount,
        itemBuilder: _wrappedBuilder,
        separatorBuilder: widget.separatorBuilder!,
      );
    }

    return ListView.builder(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemCount: widget.itemCount,
      itemBuilder: _wrappedBuilder,
    );
  }
}
