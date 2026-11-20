import 'package:material_ui/material_ui.dart';

import 'acd_motion_effect.dart';
import 'acd_stagger_host.dart';
import 'acd_stagger_options.dart';

/// A dependency-free, staggered-entrance/exit `GridView` — see
/// [ACDStaggeredList] for the list equivalent and full behavior notes
/// (visibility toggling, exit ordering, completion callbacks). Cells play
/// [ACDMotionEffect]s off one shared clock, each starting later by index.
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

class _ACDStaggeredGridState extends State<ACDStaggeredGrid>
    with SingleTickerProviderStateMixin, ACDStaggerHost<ACDStaggeredGrid> {
  // One shared clock for every item — see ACDStaggerHost.
  @override
  int get staggerItemCount => widget.itemCount;

  @override
  bool get staggerVisible => widget.visible;

  @override
  ACDStaggerOptions get staggerOptions => widget.options;

  @override
  VoidCallback? get staggerOnEntranceComplete => widget.onAllEntranceComplete;

  @override
  VoidCallback? get staggerOnExitComplete => widget.onAllExitComplete;

  Widget _wrappedBuilder(BuildContext context, int index) =>
      wrapStaggerItem(index, widget.itemBuilder(context, index));

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
