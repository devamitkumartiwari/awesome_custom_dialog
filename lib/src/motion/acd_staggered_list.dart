import 'package:material_ui/material_ui.dart';

import 'acd_motion.dart';
import 'acd_motion_effect.dart';
import 'acd_stagger_host.dart';
import 'acd_stagger_options.dart';

/// A dependency-free, staggered-entrance/exit `ListView` — items play the
/// same [ACDMotionEffect]s as [ACDMotion], each starting a little later by
/// index, so they cascade in one after another instead of all at once.
///
/// The whole list runs off **one** shared animation clock (not a controller
/// per item). Items that are first built after their turn has passed —
/// e.g. scrolled into view later — appear already settled rather than
/// replaying the entrance.
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

class _ACDStaggeredListState extends State<ACDStaggeredList>
    with SingleTickerProviderStateMixin, ACDStaggerHost<ACDStaggeredList> {
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
