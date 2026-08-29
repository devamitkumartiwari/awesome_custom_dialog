/// How `ACDDropdownField`/`ACDMultiDropdownField` present their popup when
/// the closed-state field is tapped.
enum ACDDropdownMode {
  /// A centered `ACDDialog` (built on the existing `searchableList()` /
  /// `multiSearchableList()` extensions).
  dialog,

  /// An `ACDDialog` pinned to the bottom edge, full width — the same
  /// `gravity: ACDGravity.bottom` technique `ACDDialog.snackbar()` uses.
  bottomSheet,

  /// A non-modal popup anchored directly under (or, if there isn't room,
  /// above) the field, matching its width.
  menu;

  /// Whether this mode positions its popup relative to the field itself
  /// (via `CompositedTransformFollower`) rather than centering/pinning it
  /// on the whole screen.
  bool get isAnchored => this == ACDDropdownMode.menu;
}
