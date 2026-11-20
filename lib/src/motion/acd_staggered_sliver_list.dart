import 'package:material_ui/material_ui.dart';

import 'acd_stagger_host.dart';
import 'acd_stagger_options.dart';

/// A dependency-free, staggered-entrance/exit sliver list — the `Sliver`
/// counterpart of [ACDStaggeredList], for composing inside a
/// `CustomScrollView` alongside other slivers (a sliver app bar, a sliver
/// grid, a plain list, etc.).
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     const SliverAppBar(title: Text('Inbox')),
///     ACDStaggeredSliverList(
///       itemCount: messages.length,
///       itemBuilder: (context, index) => MessageTile(messages[index]),
///     ),
///   ],
/// )
/// ```
class ACDStaggeredSliverList extends StatefulWidget {
  /// Creates an [ACDStaggeredSliverList].
  const ACDStaggeredSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.visible = true,
    this.options = const ACDStaggerOptions(),
    this.onAllEntranceComplete,
    this.onAllExitComplete,
  });

  /// Number of items to build.
  final int itemCount;

  /// Builds the unwrapped content for the item at `index` — the stagger
  /// wrapping is applied automatically.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Controlled visibility. Flip to `false` to play a staggered exit.
  final bool visible;

  /// Per-item timing/effect configuration.
  final ACDStaggerOptions options;

  /// Fires once every item's entrance transition has finished.
  final VoidCallback? onAllEntranceComplete;

  /// Fires once every item's exit transition has finished.
  final VoidCallback? onAllExitComplete;

  @override
  State<ACDStaggeredSliverList> createState() => _ACDStaggeredSliverListState();
}

class _ACDStaggeredSliverListState extends State<ACDStaggeredSliverList>
    with
        SingleTickerProviderStateMixin,
        ACDStaggerHost<ACDStaggeredSliverList> {
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        _wrappedBuilder,
        childCount: widget.itemCount,
      ),
    );
  }
}
