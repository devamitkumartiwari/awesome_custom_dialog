import 'package:material_ui/material_ui.dart';

/// A [TextEditingController] for [ACDPinField] with PIN-specific helpers:
/// [clear] after a wrong code, [setCode] to fill it programmatically, and
/// [focus]/[unfocus] without managing a `FocusNode` yourself.
///
/// ```dart
/// final pin = ACDPinController();
///
/// ACDPinField(length: 6, controller: pin, onCompleted: verify);
///
/// Future<void> verify(String code) async {
///   if (!await api.verify(code)) {
///     pin
///       ..clear()
///       ..focus(); // ready for the next attempt
///   }
/// }
/// ```
///
/// It's a regular `TextEditingController`, so listening to it, reading
/// [text] and disposing it work as usual — dispose it in your `State`.
class ACDPinController extends TextEditingController {
  /// Creates an [ACDPinController], optionally pre-filled with [text].
  ACDPinController({super.text});

  // The focus node of the ACDPinField currently using this controller.
  FocusNode? _focusNode;
  int? _length;

  /// Wipes every entered digit and puts the caret at the start. The field
  /// updates its cells and form value, and fires `onCompleted` again once
  /// it's re-filled.
  @override
  void clear() {
    value = TextEditingValue.empty;
  }

  /// Replaces the code with [code] and puts the caret at the end — e.g. a
  /// code read from an SMS. The field reacts as if it was typed
  /// (`onChanged`, and `onCompleted` when it fills every cell). Longer codes
  /// are trimmed to the field's length.
  void setCode(String code) {
    final int? length = _length;
    final String next = length != null && code.length > length
        ? code.substring(0, length)
        : code;
    value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  /// Whether every cell of the attached field is filled. `false` while no
  /// field uses this controller.
  bool get isComplete {
    final int? length = _length;
    return length != null && text.length >= length;
  }

  /// Focuses the attached field (bringing up the keyboard). A no-op while
  /// no field uses this controller.
  void focus() => _focusNode?.requestFocus();

  /// Unfocuses the attached field (hiding the keyboard).
  void unfocus() => _focusNode?.unfocus();

  /// Called by [ACDPinField]; not for app code.
  void attachField(FocusNode focusNode, int length) {
    _focusNode = focusNode;
    _length = length;
  }

  /// Called by [ACDPinField]; not for app code.
  void detachField(FocusNode focusNode) {
    if (identical(_focusNode, focusNode)) {
      _focusNode = null;
      _length = null;
    }
  }
}
