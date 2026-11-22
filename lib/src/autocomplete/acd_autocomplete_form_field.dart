import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import 'acd_autocomplete_field.dart';

/// An [ACDAutocompleteField] inside a [Form]. Its value is the *picked
/// suggestion*, not the raw text: typing after a pick clears the value, so
/// a validator can require a real choice from the list.
///
/// ```dart
/// ACDAutocompleteFormField<String>(
///   suggestions: countries,
///   decoration: const InputDecoration(labelText: 'Country'),
///   validator: (c) => c == null ? 'Pick a country from the list' : null,
///   onSaved: (c) => form.country = c,
/// )
/// ```
///
/// `Form.reset()` restores [initialValue] in the text field too.
class ACDAutocompleteFormField<T extends Object> extends FormField<T> {
  /// Creates an [ACDAutocompleteFormField].
  ACDAutocompleteFormField({
    super.key,
    required this.suggestions,
    this.itemAsString,
    this.onFind,
    this.controller,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.enabled = true,
    super.restorationId,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.minCharsForSuggestions = 1,
    this.highlightMatches = false,
    this.design,
  }) : super(
         builder: (FormFieldState<T> field) {
           final _ACDAutocompleteFormFieldState<T> state =
               field as _ACDAutocompleteFormFieldState<T>;
           final ACDAutocompleteFormField<T> w = state.widget;
           final Widget input = ACDAutocompleteField<T>(
             suggestions: w.suggestions,
             itemAsString: w.itemAsString,
             onFind: w.onFind,
             controller: state._effectiveController,
             minCharsForSuggestions: w.minCharsForSuggestions,
             highlightMatches: w.highlightMatches,
             design: w.design,
             decoration: w.decoration.copyWith(
               errorText: field.errorText,
               enabled: w.enabled,
             ),
             onSuggestionSelected: state._picked,
           );
           return w.enabled ? input : AbsorbPointer(child: input);
         },
       );

  /// The local suggestions (ignored when [onFind] is set).
  final List<T> suggestions;

  /// How a suggestion is shown and written into the field. Defaults to
  /// `toString()`.
  final String Function(T item)? itemAsString;

  /// Remote search, replacing [suggestions].
  final Future<List<T>> Function(String query)? onFind;

  /// An optional controller for the text. One is created when omitted.
  final TextEditingController? controller;

  /// Called with the picked item, or `null` when typing clears the pick.
  final ValueChanged<T?>? onChanged;

  /// The text field's decoration; [FormFieldState.errorText] is merged in.
  final InputDecoration decoration;

  /// Characters needed before suggestions appear.
  final int minCharsForSuggestions;

  /// Bolds the matched part of each suggestion.
  final bool highlightMatches;

  /// Material (default) / Cupertino / adaptive.
  final ACDDesign? design;

  @override
  FormFieldState<T> createState() => _ACDAutocompleteFormFieldState<T>();
}

class _ACDAutocompleteFormFieldState<T extends Object>
    extends FormFieldState<T> {
  TextEditingController? _owned;

  @override
  ACDAutocompleteFormField<T> get widget =>
      super.widget as ACDAutocompleteFormField<T>;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_owned ??= TextEditingController());

  String _label(T item) => widget.itemAsString?.call(item) ?? item.toString();

  @override
  void initState() {
    super.initState();
    final T? initial = widget.initialValue;
    if (initial != null && _effectiveController.text.isEmpty) {
      _effectiveController.text = _label(initial);
    }
    _effectiveController.addListener(_onText);
  }

  @override
  void didUpdateWidget(covariant ACDAutocompleteFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _owned)?.removeListener(_onText);
      _effectiveController.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onText);
    _owned?.dispose();
    super.dispose();
  }

  void _picked(T item) {
    didChange(item);
    widget.onChanged?.call(item);
  }

  /// Editing the text away from the picked item's label un-picks it.
  void _onText() {
    final T? current = value;
    if (current != null && _effectiveController.text != _label(current)) {
      didChange(null);
      widget.onChanged?.call(null);
    }
  }

  @override
  void reset() {
    super.reset();
    final T? initial = widget.initialValue;
    _effectiveController.text = initial == null ? '' : _label(initial);
  }
}
