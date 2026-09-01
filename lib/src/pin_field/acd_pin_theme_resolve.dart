import 'acd_pin_field_state.dart';
import 'acd_pin_theme.dart';

/// Internal to the package: resolves the effective [ACDPinTheme] for a
/// cell's [state], merging the matching state-specific theme over
/// [defaultTheme]. Exhaustive `switch` expression on [ACDPinCellState] — see
/// [ACDPinCellState] for the state priority this encodes.
ACDPinTheme acdResolvePinTheme(
  ACDPinCellState state, {
  required ACDPinTheme defaultTheme,
  ACDPinTheme? focusedTheme,
  ACDPinTheme? submittedTheme,
  ACDPinTheme? followingTheme,
  ACDPinTheme? errorTheme,
  ACDPinTheme? disabledTheme,
}) {
  final ACDPinTheme? overlay = switch (state) {
    ACDPinCellDisabled() => disabledTheme,
    ACDPinCellError() => errorTheme,
    ACDPinCellSubmitted() => submittedTheme ?? focusedTheme,
    ACDPinCellFocused() => focusedTheme,
    ACDPinCellFollowing() => followingTheme,
    ACDPinCellDefault() => null,
  };
  return ACDPinTheme.resolve(defaultTheme, overlay);
}
