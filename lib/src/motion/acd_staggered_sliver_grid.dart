import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;

import 'acd_motion.dart';
import 'acd_stagger_options.dart';

/// A dependency-free, staggered-entrance/exit sliver grid — the `Sliver`
/// counterpart of [ACDStaggeredGrid], for composing inside a
/// `CustomScrollView` alongside other slivers.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     const SliverAppBar(title: Text('Photos')),
///     ACDStaggeredSliverGrid(
///       itemCount: photos.length,
///       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///         crossAxisCount: 3,
///       ),
///       itemBuilder: (context, index) => PhotoTile(photos[index]),
///     ),
///   ],
/// )
/// ```
class ACDStaggeredSliverGrid extends StatefulWidget {
  /// Creates an [ACDStaggeredSliverGrid].
  const ACDStaggeredSliverGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.visible = true,
    this.options = const ACDStaggerOptions(),
    this.onAllEntranceComplete,
    this.onAllExitComplete,
  });

  /// Number of cells to build.
  final int itemCount;

  /// Builds the unwrapped content for the cell at `index` — the stagger
  /// wrapping is applied automatically.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Forwarded to the underlying `SliverGrid`.
  final SliverGridDelegate gridDelegate;

  /// Controlled visibility. Flip to `false` to play a staggered exit.
  final bool visible;

  /// Per-item timing/effect configuration.
  final ACDStaggerOptions options;

  /// Fires once every cell's entrance transition has finished.
  final VoidCallback? onAllEntranceComplete;

  /// Fires once every cell's exit transition has finished.
  final VoidCallback? onAllExitComplete;

  @override
  State<ACDStaggeredSliverGrid> createState() => _ACDStaggeredSliverGridState();
}

class _ACDStaggeredSliverGridState extends State<ACDStaggeredSliverGrid> {
  int _entranceDone = 0;
  int _exitDone = 0;

  @override
  void initState() {
    super.initState();
    _maybeFireEmptyCompletion();
  }

  @override
  void didUpdateWidget(covariant ACDStaggeredSliverGrid oldWidget) {
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
    return SliverGrid(
      gridDelegate: widget.gridDelegate,
      delegate: SliverChildBuilderDelegate(
        _wrappedBuilder,
        childCount: widget.itemCount,
      ),
    );
  }
}
