import 'package:flutter/foundation.dart';

/// The semantic role of an [ACDAction] — each design maps it to its native
/// emphasis: Material uses filled/text buttons and the error color; iOS uses
/// a bold default action and a red destructive action.
enum ACDActionRole {
  /// A regular action.
  normal,

  /// The recommended action (Material: filled button; iOS: bold).
  primary,

  /// A destructive action (red in both designs).
  destructive,

  /// Dismisses without acting (Material: text button; iOS: regular weight,
  /// placed per platform convention).
  cancel,
}

/// A design-neutral dialog action, mapped to Material buttons or iOS dialog
/// actions depending on the dialog's design.
///
/// ```dart
/// ACDDialog(design: ACDDesign.adaptive).build(context)
///   ..text(text: 'Delete this photo?')
///   ..actions([
///     ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
///     ACDAction(label: 'Delete', role: ACDActionRole.destructive,
///         value: true),
///   ])
///   ..show();
/// ```
@immutable
class ACDAction {
  /// Creates an action.
  const ACDAction({
    required this.label,
    this.role = ACDActionRole.normal,
    this.onPressed,
    this.value,
    this.dismissOnPressed = true,
    this.enabled = true,
  });

  /// Button label.
  final String label;

  /// Semantic role, used for styling.
  final ACDActionRole role;

  /// Called when pressed (before the dialog dismisses, when
  /// [dismissOnPressed] is `true`).
  final VoidCallback? onPressed;

  /// Value the dialog's `showForResult()` future completes with when this
  /// action is chosen.
  final Object? value;

  /// Whether pressing this action dismisses the dialog.
  final bool dismissOnPressed;

  /// Whether the action can be pressed.
  final bool enabled;
}
