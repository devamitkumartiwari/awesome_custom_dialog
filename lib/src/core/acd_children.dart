import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

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
    final List<Widget> children = options == null
        ? widget.widgetList
        : <Widget>[
            for (int i = 0; i < widget.widgetList.length; i++)
              ACDMotion(
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
                child: widget.widgetList[i],
              ),
          ];
    return Column(
      mainAxisSize: MainAxisSize.min, // IMP-07: wrap content, don't expand
      children: children,
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
    // BUG-09: always fires — covers barrier tap AND programmatic dismiss
    widget.onDismissed?.call();
    super.dispose();
  }
}
