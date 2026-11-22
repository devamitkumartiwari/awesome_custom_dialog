import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';

import '../motion/acd_motion.dart';
import '../motion/acd_stagger_options.dart';

/// Wraps an [ACDDialog]'s content widgets in a `Column` and reports when it
/// has been shown/dismissed. Used internally by `ACDDialog.show()` — not
/// normally constructed directly.
class ACDChildren extends StatefulWidget {
  /// The content widgets to lay out in a column.
  final List<Widget> widgetList;

  /// Called after the first frame this widget is shown in.
  final VoidCallback? onShown;

  /// Called when this widget is removed from the tree (dialog dismissed).
  final VoidCallback? onDismissed;

  /// When set, mirrors `ACDDialog.contentStagger` — each item in
  /// [widgetList] plays a staggered entrance/exit instead of appearing all
  /// at once.
  final ACDStaggerOptions? staggerOptions;

  /// Drives [staggerOptions]'s entrance (`true`)/exit (`false`) state.
  /// Ignored when [staggerOptions] is `null`.
  final ValueListenable<bool>? visible;

  /// Creates an [ACDChildren].
  const ACDChildren({
    super.key,
    this.widgetList = const [],
    this.onShown,
    this.onDismissed,
    this.staggerOptions,
    this.visible,
  });

  @override
  State<ACDChildren> createState() => _ACDChildrenState();
}

class _ACDChildrenState extends State<ACDChildren> {
  @override
  void initState() {
    super.initState();
    // BUG-02: defer callback to avoid setState-during-build framework error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onShown?.call();
    });
  }

  Widget _buildColumn(bool visible) {
    final ACDStaggerOptions? options = widget.staggerOptions;
    Widget animated(int i, Widget child) => options == null
        ? child
        : ACDMotion(
            key: ValueKey<int>(i),
            visible: visible,
            delay: options.delayForIndex(
              i,
              widget.widgetList.length,
              visible: visible,
            ),
            duration: options.itemDuration,
            curve: options.curve,
            effect: options.effect,
            exitEffect: options.exitEffect,
            child: child,
          );

    final bool hasFill = widget.widgetList.any((w) => w is ACDFillRemaining);
    if (!hasFill) {
      return Column(
        mainAxisSize: MainAxisSize.min, // IMP-07: wrap content, don't expand
        children: [
          for (int i = 0; i < widget.widgetList.length; i++)
            animated(i, widget.widgetList[i]),
        ],
      );
    }
    // A fill child takes whatever height is left — but only when there is a
    // limit to fill (a fixed-height dialog, or a sheet's max height).
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool bounded = constraints.hasBoundedHeight;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.widgetList.length; i++)
              switch (widget.widgetList[i]) {
                final ACDFillRemaining fill when bounded => Flexible(
                  child: animated(i, fill.child),
                ),
                final ACDFillRemaining fill => animated(i, fill.child),
                final Widget other => animated(i, other),
              },
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ValueListenable<bool>? visible = widget.visible;
    if (widget.staggerOptions == null || visible == null) {
      return _buildColumn(true);
    }
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder: (context, value, _) => _buildColumn(value),
    );
  }

  @override
  void dispose() {
    // BUG-09: always fires — covers barrier tap AND programmatic dismiss.
    // Deferred to a microtask: dispose runs while the element tree is
    // locked, so a callback calling setState (the common
    // `dismissCallBack = () => setState(...)`) would throw here — and a
    // throwing callback must never skip super.dispose().
    final VoidCallback? onDismissed = widget.onDismissed;
    if (onDismissed != null) scheduleMicrotask(onDismissed);
    super.dispose();
  }
}

/// Dialog content that may shrink to the height a fixed-height dialog has
/// left after its other content (a title, buttons…), instead of insisting
/// on its own preferred height and overflowing. Without a height limit it
/// lays out as usual.
///
/// `searchableList()` and `multiSearchableList()` use it; wrap your own
/// scrollable content in it the same way:
///
/// ```dart
/// ACDDialog().build(context)
///   ..height = 420
///   ..text(text: 'Pick a file')
///   ..widget(ACDFillRemaining(child: ListView(children: files)))
///   ..show();
/// ```
class ACDFillRemaining extends StatelessWidget {
  /// Creates an [ACDFillRemaining] around [child].
  const ACDFillRemaining({super.key, required this.child});

  /// The content that fills the remaining height.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
