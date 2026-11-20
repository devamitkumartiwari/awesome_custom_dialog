/// How `ACDDropdownField`/`ACDMultiDropdownField` present their popup when
/// the closed-state field is tapped.
enum ACDDropdownMode {
  /// A centered `ACDDialog` (built on the existing `searchableList()` /
  /// `multiSearchableList()` extensions).
  dialog,

  /// An `ACDDialog` pinned to the bottom edge, full width — the same
  /// `gravity: ACDGravity.bottom` technique `ACDDialog.snackbar()` uses.
  bottomSheet,

  /// A popover anchored directly under (or, if there isn't room, above) the
  /// field, matching its width. Esc, back or a tap outside closes it.
  menu,

  /// iOS action sheet: one row per item plus Cancel (multi-select: rows
  /// toggle, "Done" commits). Needs a Cupertino design — falls back to
  /// [bottomSheet] under Material.
  actionSheet,

  /// iOS wheel picker in a sheet with Cancel / Done (single-select; a
  /// multi-select field uses [actionSheet]). Needs a Cupertino design —
  /// falls back to [bottomSheet] under Material.
  picker,

  /// Picks per design: Material → [dialog]; Cupertino → [actionSheet] for
  /// up to 7 local items (or multi-select), [picker] for longer local
  /// lists, [bottomSheet] with search when results come from `onFind`.
  adaptive;

  /// Whether this mode positions its popup relative to the field itself
  /// rather than centering/pinning it on the whole screen.
  bool get isAnchored => this == ACDDropdownMode.menu;
}

/// How [ACDMultiDropdownField] shows its selection in the closed field.
enum ACDMultiDisplay {
  /// Removable chips (2.0 default): Material `InputChip`s / iOS pills, with
  /// a "+N" chip once `maxVisibleChips` is exceeded.
  chips,

  /// The pre-2.0 comma-joined text.
  text,
}
