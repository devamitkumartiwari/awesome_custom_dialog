import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/internal/acd_field_error.dart';
import 'acd_rating_bar.dart';
import 'acd_rating_interaction_mode.dart';

/// An [ACDRatingBar] inside a [Form]: `validator`, `onSaved`, `reset()` and
/// an error line under it.
///
/// ```dart
/// ACDRatingFormField(
///   validator: (r) => (r ?? 0) == 0 ? 'Please rate your stay' : null,
///   onSaved: (r) => review.stars = r!,
/// )
/// ```
class ACDRatingFormField extends FormField<double> {
  /// Creates an [ACDRatingFormField].
  ACDRatingFormField({
    super.key,
    double initialValue = 0,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.enabled = true,
    super.restorationId,
    ValueChanged<double>? onChanged,
    int itemCount = 5,
    double itemSize = 32,
    bool allowHalfRating = false,
    double minRating = 0,
    ACDDesign? design,
    String? semanticLabel,
    Color? filledColor,
    Color? unratedColor,
  }) : super(
         initialValue: initialValue,
         builder: (FormFieldState<double> field) {
           final ACDResolvedDesign resolved = ACDDesign.resolve(
             field.context,
             design,
           );
           return Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               ACDRatingBar(
                 rating: field.value ?? 0,
                 itemCount: itemCount,
                 itemSize: itemSize,
                 allowHalfRating: allowHalfRating,
                 minRating: minRating,
                 design: design,
                 semanticLabel: semanticLabel,
                 filledColor: filledColor,
                 unratedColor: unratedColor,
                 interactionMode: field.widget.enabled
                     ? ACDRatingInteractionMode.tapAndDrag
                     : ACDRatingInteractionMode.none,
                 onRatingUpdate: (double v) {
                   field.didChange(v);
                   onChanged?.call(v);
                 },
               ),
               ACDFieldError(errorText: field.errorText, design: resolved),
             ],
           );
         },
       );
}
