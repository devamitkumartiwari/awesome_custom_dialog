import 'package:material_ui/material_ui.dart';

import '../acd_design.dart';
import '../acd_design_tokens.dart';

/// The validation message under a non-text form field (switch, rating),
/// styled like an `InputDecorator`'s error line. Announced to screen
/// readers when it appears.
class ACDFieldError extends StatelessWidget {
  /// Creates an [ACDFieldError] for [errorText]; renders nothing when null.
  const ACDFieldError({
    super.key,
    required this.errorText,
    required this.design,
  });

  /// The message, or `null` for no error.
  final String? errorText;

  /// The resolved design (picks the error colour).
  final ACDResolvedDesign design;

  @override
  Widget build(BuildContext context) {
    final String? text = errorText;
    if (text == null) return const SizedBox.shrink();
    final Color color = design.isCupertino
        ? ACDDesignTokens.of(context, design).error
        : Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Semantics(
        liveRegion: true,
        child: Text(
          text,
          style:
              Theme.of(context).textTheme.bodySmall?.copyWith(color: color) ??
              TextStyle(fontSize: 12, color: color),
        ),
      ),
    );
  }
}
