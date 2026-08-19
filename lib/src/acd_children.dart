import 'package:flutter/material.dart';

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

  /// Creates an [ACDChildren].
  const ACDChildren({
    super.key,
    this.widgetList = const [],
    this.onShown,
    this.onDismissed,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // IMP-07: wrap content, don't expand
      children: widget.widgetList,
    );
  }

  @override
  void dispose() {
    // BUG-09: always fires — covers barrier tap AND programmatic dismiss
    widget.onDismissed?.call();
    super.dispose();
  }
}
