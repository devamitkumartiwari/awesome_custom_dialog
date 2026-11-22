import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/internal/acd_field_error.dart';
import 'acd_switch.dart';

/// An [ACDSwitch] inside a [Form]: `validator`, `onSaved`, `reset()` and an
/// error line under it — e.g. a required "I accept the terms" toggle.
///
/// ```dart
/// ACDSwitchFormField(
///   title: const Text('I accept the terms'),
///   validator: (on) => on == true ? null : 'Please accept to continue',
///   onSaved: (on) => accepted = on ?? false,
/// )
/// ```
class ACDSwitchFormField extends FormField<bool> {
  /// Creates an [ACDSwitchFormField].
  ACDSwitchFormField({
    super.key,
    bool initialValue = false,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.enabled = true,
    super.restorationId,
    ValueChanged<bool>? onChanged,
    Widget? title,
    ACDDesign? design,
    String? semanticLabel,
    Color? activeTrackColor,
    Color? inactiveTrackColor,
    Color? thumbColor,
  }) : super(
         initialValue: initialValue,
         builder: (FormFieldState<bool> field) {
           final ACDResolvedDesign resolved = ACDDesign.resolve(
             field.context,
             design,
           );
           final Widget toggle = ACDSwitch(
             value: field.value ?? false,
             enabled: field.widget.enabled,
             design: design,
             semanticLabel: semanticLabel,
             activeTrackColor: activeTrackColor,
             inactiveTrackColor: inactiveTrackColor,
             thumbColor: thumbColor,
             onChanged: (bool v) {
               field.didChange(v);
               onChanged?.call(v);
             },
           );
           return Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (title == null)
                 toggle
               else
                 Row(
                   children: [
                     Expanded(child: title),
                     const SizedBox(width: 12),
                     toggle,
                   ],
                 ),
               ACDFieldError(errorText: field.errorText, design: resolved),
             ],
           );
         },
       );
}
