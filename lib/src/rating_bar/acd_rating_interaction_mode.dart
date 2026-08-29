/// How an [ACDRatingBar] responds to user input.
enum ACDRatingInteractionMode {
  /// Both tapping an item and dragging across the row set the rating.
  tapAndDrag,

  /// Only a discrete tap sets the rating — dragging does nothing.
  tapOnly,

  /// Only a drag gesture sets the rating — a stationary tap does nothing.
  dragOnly,

  /// Fully read-only: no gesture detection is attached at all. Use this in
  /// place of a separate "indicator" widget.
  none,
}
