import 'package:flutter/material.dart';

/// The four ready-made looks for [ACDSnackbarContent] and
/// `ACDDialog.snackbar()`.
enum ACDContentType {
  /// Green, with a checkmark icon.
  success,

  /// Red, with a close/X icon.
  failure,

  /// Orange, with an exclamation icon.
  warning,

  /// Blue, with a question-mark icon.
  help,
}

/// The default color and icon for each [ACDContentType].
extension ACDContentTypeX on ACDContentType {
  /// The default accent color for this content type.
  Color get color => switch (this) {
    ACDContentType.success => const Color(0xFF2D6A4F),
    ACDContentType.failure => const Color(0xFFC72C41),
    ACDContentType.warning => const Color(0xFFFCA652),
    ACDContentType.help => const Color(0xFF3282B8),
  };

  /// The default icon for this content type.
  IconData get icon => switch (this) {
    ACDContentType.success => Icons.done_rounded,
    ACDContentType.failure => Icons.close_rounded,
    ACDContentType.warning => Icons.priority_high_rounded,
    ACDContentType.help => Icons.question_mark_rounded,
  };
}
