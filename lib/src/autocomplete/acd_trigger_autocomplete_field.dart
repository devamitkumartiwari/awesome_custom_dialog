import 'dart:async';

import 'package:flutter/material.dart';

import '../list_tile/acd_search_state.dart';

/// Describes one trigger character an [ACDTriggerAutocompleteField] should
/// react to — e.g. `@` for mentions, `#` for hashtags, `:` for emoji.
///
/// Options are intentionally untyped ([Object]) since a single field can
/// host triggers backed by different data types at once (mentions → `User`,
/// hashtags → `String`).
class ACDAutocompleteTrigger {
  /// Creates an [ACDAutocompleteTrigger].
  const ACDAutocompleteTrigger({
    required this.trigger,
    required this.optionsBuilder,
    this.itemBuilder,
    this.itemAsString,
    this.triggerOnlyAtStart = false,
    this.triggerOnlyAfterSpace = true,
    this.minCharsForSuggestions = 0,
  });

  /// The character that arms this trigger, e.g. `'@'`.
  final String trigger;

  /// Fetches matching options for the text typed since [trigger] armed.
  final Future<List<Object?>> Function(String query) optionsBuilder;

  /// Custom option-row builder. Defaults to a [ListTile] showing
  /// [itemAsString].
  final Widget Function(BuildContext context, Object? option)? itemBuilder;

  /// Renders an option as the text inserted on selection; defaults to
  /// `option.toString()`.
  final String Function(Object? option)? itemAsString;

  /// Only arms this trigger at the very start of the text.
  final bool triggerOnlyAtStart;

  /// Only arms this trigger when preceded by whitespace or the start of the
  /// text (ignored when [triggerOnlyAtStart] is true).
  final bool triggerOnlyAfterSpace;

  /// Minimum characters typed after [trigger] before suggestions are shown.
  final int minCharsForSuggestions;
}

/// A dependency-free, multi-trigger, mention-style autocomplete text field.
///
/// ```dart
/// ACDTriggerAutocompleteField(
///   triggers: [
///     ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findUsers),
///     ACDAutocompleteTrigger(trigger: '#', optionsBuilder: findHashtags),
///   ],
///   onOptionSelected: (trigger, option) => debugPrint('$option via ${trigger.trigger}'),
/// )
/// ```
///
/// v1 anchors the popup under the whole field rather than the caret
/// position — true caret-relative anchoring needs `TextPainter` caret-offset
/// math, out of scope for now.
class ACDTriggerAutocompleteField extends StatefulWidget {
  /// Creates an [ACDTriggerAutocompleteField].
  const ACDTriggerAutocompleteField({
    super.key,
    required this.triggers,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.onOptionSelected,
    this.searchDebounce = const Duration(milliseconds: 350),
    this.maxLines = 1,
    this.minLines,
    this.tileColor = Colors.white,
    this.itemTextColor,
    this.itemFontSize,
    this.itemFontWeight,
    this.itemFontFamily,
    this.itemStyle,
    this.popupHeight,
    this.popupWidthFactor = 1.0,
    this.popupElevation = 4,
    this.popupBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.popupColor,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  /// The triggers this field reacts to.
  final List<ACDAutocompleteTrigger> triggers;

  /// Externally-owned controller. Owned and disposed internally when null.
  final TextEditingController? controller;

  /// Externally-owned focus node. Owned and disposed internally when null.
  final FocusNode? focusNode;

  /// Initial text, when [controller] is null.
  final String? initialValue;

  /// Decoration for the underlying [TextField].
  final InputDecoration decoration;

  /// Fired when an option is picked, alongside the trigger it came from.
  final void Function(ACDAutocompleteTrigger trigger, Object? option)?
  onOptionSelected;

  /// Delay before a trigger's `optionsBuilder` runs after each keystroke.
  final Duration searchDebounce;

  /// Max lines for the underlying [TextField].
  final int? maxLines;

  /// Min lines for the underlying [TextField].
  final int? minLines;

  /// Background color of each option tile.
  final Color tileColor;

  /// Default option text color.
  final Color? itemTextColor;

  /// Default option text size.
  final double? itemFontSize;

  /// Default option text weight.
  final FontWeight? itemFontWeight;

  /// Default option text font family.
  final String? itemFontFamily;

  /// Full option text style, merged over
  /// [itemTextColor]/[itemFontSize]/[itemFontWeight]/[itemFontFamily] above.
  final TextStyle? itemStyle;

  /// Max popup height. Defaults to a sensible fixed height.
  final double? popupHeight;

  /// Popup width as a factor of the field's width.
  final double popupWidthFactor;

  /// Popup card elevation.
  final double popupElevation;

  /// Popup card corner rounding.
  final BorderRadius popupBorderRadius;

  /// Popup card background color.
  final Color? popupColor;

  /// Shown while an `optionsBuilder` is in flight.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Shown when a search yields no matches.
  final Widget Function(BuildContext context, String query)? emptyBuilder;

  /// Shown when an `optionsBuilder` throws.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<ACDTriggerAutocompleteField> createState() =>
      _ACDTriggerAutocompleteFieldState();
}

class _ArmedTrigger {
  _ArmedTrigger(this.trigger, this.startIndex);
  final ACDAutocompleteTrigger trigger;
  final int startIndex;
}

class _ACDTriggerAutocompleteFieldState
    extends State<ACDTriggerAutocompleteField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  Timer? _debounce;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  ACDSearchState<Object?> _state = const ACDSearchIdle([]);
  _ArmedTrigger? _armed;
  int _requestId = 0;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialValue));
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _removeOverlay();
  }

  void _onTextChanged() {
    final String text = _controller.text;
    final int cursor = _controller.selection.baseOffset;
    _debounce?.cancel();

    if (cursor < 0) {
      _closeArmed();
      return;
    }

    final _ArmedTrigger? armed = _findArmedTrigger(text, cursor);
    if (armed == null) {
      _closeArmed();
      return;
    }

    final String query = text.substring(armed.startIndex + 1, cursor);
    if (query.contains(' ')) {
      _closeArmed();
      return;
    }

    setState(() => _armed = armed);

    if (query.length < armed.trigger.minCharsForSuggestions) {
      setState(() => _state = const ACDSearchIdle([]));
      _removeOverlay();
      return;
    }

    setState(() => _state = const ACDSearchLoading());
    _showOverlay();
    _debounce = Timer(widget.searchDebounce, () => _runSearch(armed, query));
  }

  void _closeArmed() {
    if (_armed != null) setState(() => _armed = null);
    _removeOverlay();
  }

  _ArmedTrigger? _findArmedTrigger(String text, int cursor) {
    for (int i = cursor - 1; i >= 0; i--) {
      final String char = text[i];
      if (char == ' ') return null;

      final ACDAutocompleteTrigger? match = widget.triggers
          .cast<ACDAutocompleteTrigger?>()
          .firstWhere((t) => t!.trigger == char, orElse: () => null);
      if (match == null) continue;

      final bool atStart = i == 0;
      final bool afterSpace = i > 0 && text[i - 1] == ' ';
      if (match.triggerOnlyAtStart && !atStart) continue;
      if (!match.triggerOnlyAtStart &&
          match.triggerOnlyAfterSpace &&
          !atStart &&
          !afterSpace) {
        continue;
      }
      return _ArmedTrigger(match, i);
    }
    return null;
  }

  Future<void> _runSearch(_ArmedTrigger armed, String query) async {
    final int requestId = ++_requestId;
    try {
      final List<Object?> results = await armed.trigger.optionsBuilder(query);
      if (!mounted || requestId != _requestId || _armed != armed) return;
      setState(
        () => _state = results.isEmpty
            ? ACDSearchEmpty<Object?>(query)
            : ACDSearchLoaded<Object?>(results),
      );
    } catch (error, stackTrace) {
      if (!mounted || requestId != _requestId || _armed != armed) return;
      setState(
        () => _state = ACDSearchError<Object?>(error, query, stackTrace),
      );
    }
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }
    final OverlayState? overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    overlayState.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _select(Object? option) {
    final _ArmedTrigger? armed = _armed;
    if (armed == null) return;
    final String text =
        armed.trigger.itemAsString?.call(option) ?? option.toString();
    final int cursor = _controller.selection.baseOffset;
    final String current = _controller.text;
    final String replacement = '$text ';
    final String newText = current.replaceRange(
      armed.startIndex,
      cursor,
      replacement,
    );
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: armed.startIndex + replacement.length,
      ),
    );
    widget.onOptionSelected?.call(armed.trigger, option);
    _closeArmed();
  }

  Widget _buildOverlay(BuildContext context) {
    final RenderBox? anchorBox = this.context.findRenderObject() as RenderBox?;
    final double fieldHeight = anchorBox?.size.height ?? 56;
    final double fieldWidth = anchorBox?.size.width ?? 200;
    final double popupHeight = widget.popupHeight ?? 260;

    bool flipAbove = false;
    if (anchorBox != null && anchorBox.attached) {
      final Offset fieldBottomGlobal = anchorBox.localToGlobal(
        Offset(0, anchorBox.size.height),
      );
      final double screenHeight = MediaQuery.sizeOf(context).height;
      if (screenHeight - fieldBottomGlobal.dy < popupHeight) {
        flipAbove = true;
      }
    }

    return Positioned(
      width: fieldWidth * widget.popupWidthFactor,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: flipAbove ? Offset(0, -popupHeight) : Offset(0, fieldHeight),
        child: Material(
          elevation: widget.popupElevation,
          color: widget.popupColor,
          borderRadius: widget.popupBorderRadius,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: popupHeight),
            child: _buildOptionList(context),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionList(BuildContext context) {
    final ACDAutocompleteTrigger? trigger = _armed?.trigger;
    switch (_state) {
      case ACDSearchLoading<Object?>():
        return widget.loadingBuilder?.call(context) ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
      case ACDSearchError<Object?>(:final error):
        return widget.errorBuilder?.call(context, error) ??
            Padding(padding: const EdgeInsets.all(16), child: Text('$error'));
      case ACDSearchEmpty<Object?>(:final query):
        return widget.emptyBuilder?.call(context, query) ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No matches'),
            );
      case ACDSearchIdle<Object?>(:final items):
      case ACDSearchLoaded<Object?>(:final items):
        if (items.isEmpty || trigger == null) return const SizedBox.shrink();
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final Object? option = items[index];
            if (trigger.itemBuilder != null) {
              return InkWell(
                onTap: () => _select(option),
                child: trigger.itemBuilder!(context, option),
              );
            }
            return Material(
              color: widget.tileColor,
              child: ListTile(
                title: Text(
                  trigger.itemAsString?.call(option) ?? option.toString(),
                  style: (widget.itemStyle ?? const TextStyle()).merge(
                    TextStyle(
                      color: widget.itemTextColor,
                      fontSize: widget.itemFontSize,
                      fontWeight: widget.itemFontWeight,
                      fontFamily: widget.itemFontFamily,
                    ),
                  ),
                ),
                onTap: () => _select(option),
              ),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: widget.decoration,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
      ),
    );
  }
}
