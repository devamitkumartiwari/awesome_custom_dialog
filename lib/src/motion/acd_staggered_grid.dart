import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;

import 'acd_motion.dart';
import 'acd_stagger_options.dart';

/// A dependency-free, staggered-entrance/exit `GridView` — see
/// [ACDStaggeredList] for the list equivalent and full behavior notes
/// (visibility toggling, exit ordering, completion callbacks). Each cell is
/// wrapped in an [ACDMotion] whose `delay` increases with its index.
///
/// ```dart
/// ACDStaggeredGrid(
///   itemCount: items.length,
///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///     crossAxisCount: 2,
///   ),
///   itemBuilder: (context, index) => Card(child: Text(items[index])),
/// )
/// ```
class ACDStaggeredGrid extends StatefulWidget {
  /// Creates an [ACDStaggeredGrid].
  const ACDStaggeredGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
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

  /// Number of cells to build.
  final int itemCount;

  /// Builds the unwrapped content for the cell at `index` — the stagger
  /// wrapping is applied automatically.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Forwarded to the underlying `GridView`.
  final SliverGridDelegate gridDelegate;

  /// Controlled visibility. Flip to `false` to play a staggered exit.
  final bool visible;

  /// Per-item timing/effect configuration.
  final ACDStaggerOptions options;

  /// Forwarded to the underlying `GridView`.
  final Axis scrollDirection;

  /// Forwarded to the underlying `GridView`.
  final bool reverse;

  /// Forwarded to the underlying `GridView`.
  final ScrollController? controller;

  /// Forwarded to the underlying `GridView`.
  final bool? primary;

  /// Forwarded to the underlying `GridView`.
  final ScrollPhysics? physics;

  /// Forwarded to the underlying `GridView`.
  final bool shrinkWrap;

  /// Forwarded to the underlying `GridView`.
  final EdgeInsetsGeometry? padding;

  /// Fires once every cell's entrance transition has finished.
  final VoidCallback? onAllEntranceComplete;

  /// Fires once every cell's exit transition has finished.
  final VoidCallback? onAllExitComplete;

  @override
  State<ACDStaggeredGrid> createState() => _ACDStaggeredGridState();
}

class _ACDStaggeredGridState extends State<ACDStaggeredGrid> {
  int _entranceDone = 0;
  int _exitDone = 0;

  @override
  void initState() {
    super.initState();
    _maybeFireEmptyCompletion();
  }

  @override
  void didUpdateWidget(covariant ACDStaggeredGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      _entranceDone = 0;
      _exitDone = 0;
      _maybeFireEmptyCompletion();
    }
  }

  // See ACDStaggeredList._maybeFireEmptyCompletion — same reasoning.
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

  Widget _wrappedBuilder(BuildContext context, int index) {
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
      child: widget.itemBuilder(context, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      gridDelegate: widget.gridDelegate,
      itemCount: widget.itemCount,
      itemBuilder: _wrappedBuilder,
    );
  }
}
