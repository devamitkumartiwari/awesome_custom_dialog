/// The direction(s) an [ACDSlideAction] can be dragged to confirm.
enum ACDSlideActionDirection {
  /// Drag from the leading edge towards the trailing edge (mirrored
  /// automatically under RTL `Directionality`).
  startToEnd,

  /// Drag from the trailing edge towards the leading edge (mirrored
  /// automatically under RTL `Directionality`).
  endToStart,

  /// The thumb starts centered and can be dragged to either edge.
  dual,
}
