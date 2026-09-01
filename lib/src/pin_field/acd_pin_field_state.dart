/// The per-cell visual state of an [ACDPinField] — exhaustively handled via
/// a `switch` expression to resolve which [ACDPinTheme] applies, mirroring
/// `ACDSearchState`'s pattern (`lib/src/list_tile/acd_search_state.dart`).
///
/// Priority when multiple could apply simultaneously (highest first):
/// [ACDPinCellDisabled] > [ACDPinCellError] > [ACDPinCellSubmitted] >
/// [ACDPinCellFocused] > [ACDPinCellFollowing] > [ACDPinCellDefault].
sealed class ACDPinCellState {
  const ACDPinCellState();
}

/// No digit typed yet, not focused — the resting state.
final class ACDPinCellDefault extends ACDPinCellState {
  /// Creates an [ACDPinCellDefault] state.
  const ACDPinCellDefault();
}

/// A digit is present, but this cell isn't the focused one (a filled cell
/// behind the caret).
final class ACDPinCellFollowing extends ACDPinCellState {
  /// Creates an [ACDPinCellFollowing] state.
  const ACDPinCellFollowing();
}

/// The field has focus and this is the cell the caret is currently at.
final class ACDPinCellFocused extends ACDPinCellState {
  /// Creates an [ACDPinCellFocused] state.
  const ACDPinCellFocused();
}

/// The pin is complete (`length` digits entered).
final class ACDPinCellSubmitted extends ACDPinCellState {
  /// Creates an [ACDPinCellSubmitted] state.
  const ACDPinCellSubmitted();
}

/// The field currently has a validation/forced error.
final class ACDPinCellError extends ACDPinCellState {
  /// Creates an [ACDPinCellError] state.
  const ACDPinCellError();
}

/// The field is disabled.
final class ACDPinCellDisabled extends ACDPinCellState {
  /// Creates an [ACDPinCellDisabled] state.
  const ACDPinCellDisabled();
}
