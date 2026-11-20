import 'package:material_ui/material_ui.dart';

import 'acd_stagger_host.dart';
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

class _ACDStaggeredSliverGridState extends State<ACDStaggeredSliverGrid>
    with
        SingleTickerProviderStateMixin,
        ACDStaggerHost<ACDStaggeredSliverGrid> {
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
    return SliverGrid(
      gridDelegate: widget.gridDelegate,
      delegate: SliverChildBuilderDelegate(
        _wrappedBuilder,
        childCount: widget.itemCount,
      ),
    );
  }
}
