import 'dart:async';

import 'package:flutter/rendering.dart' show RenderEditable;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_cupertino_field_style.dart';
import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../list_tile/acd_search_state.dart';

// Word boundaries that end a trigger query (space, newline, tab).
bool _isBoundary(String char) => char == ' ' || char == '\n' || char == '\t';

/// Where an [ACDTriggerAutocompleteField] anchors its suggestion popup.
enum ACDPopupAnchor {
  /// Under (or above) the whole field — the default.
  field,

  /// Under (or above) the trigger being typed, following the text as it
  /// wraps and scrolls. Pair with a `popupWidthFactor` below `1.0` so the
  /// popup has room to move sideways.
  caret,
}

/// Describes one trigger an [ACDTriggerAutocompleteField] should react to —
/// e.g. `@` for mentions, `#` for hashtags, `:` or a multi-character `::`
/// for emoji. When triggers overlap, the longest one typed wins.
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
  }) : assert(trigger.length > 0, 'A trigger must not be empty');

  /// The text that arms this trigger, e.g. `'@'` or `'::'`. Must be
  /// non-empty and contain no whitespace.
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
/// The popup sits under the whole field by default; pass
/// `popupAnchor: ACDPopupAnchor.caret` to follow the trigger being typed
/// instead. Arrow keys move through the options, Enter picks, Esc closes.
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
    this.tileColor,
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
    this.design,
    this.cupertinoStyle,
    this.popupAnchor = ACDPopupAnchor.field,
  });

  /// Where the suggestion popup is anchored: the whole field (default) or
  /// the trigger being typed.
  final ACDPopupAnchor popupAnchor;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign].
  final ACDDesign? design;

  /// Cupertino-only field styling (used when the design resolves to
  /// Cupertino).
  final ACDCupertinoFieldStyle? cupertinoStyle;

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

  /// Background color of each option tile. Defaults to white (Material) or
  /// the popup surface (Cupertino).
  final Color? tileColor;

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
  // The popup lives in this widget's subtree (rebuilds with it, inherits
  // its theme/scope, torn down with it).
  final OverlayPortalController _portal = OverlayPortalController();

  // Keyboard-highlighted option (arrow keys), or -1 for none.
  int _highlighted = -1;
  ACDSearchState<Object?> _state = const ACDSearchIdle([]);
  _ArmedTrigger? _armed;
  int _requestId = 0;
  ACDResolvedDesign _design = ACDResolvedDesign.material;

  // Last (trigger position, query) searched — caret moves that leave the
  // active query unchanged must not restart the search.
  (int, String)? _lastSearch;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialValue));
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    assert(
      widget.triggers.every((t) => !t.trigger.contains(RegExp(r'\s'))),
      'Triggers must not contain whitespace',
    );
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ACDTriggerAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-wire when the caller swaps the controller/focus node — otherwise
    // the old one keeps driving this field and the new one is ignored.
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(
        _onTextChanged,
      );
      _controller.addListener(_onTextChanged);
      _lastSearch = null;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

    final String query = text.substring(
      armed.startIndex + armed.trigger.trigger.length,
      cursor,
    );
    if (query.split('').any(_isBoundary)) {
      _closeArmed();
      return;
    }
    if (_lastSearch == (armed.startIndex, query) && _portal.isShowing) {
      return; // caret-only change within the same active query
    }
    _lastSearch = (armed.startIndex, query);

    setState(() => _armed = armed);

    if (query.length < armed.trigger.minCharsForSuggestions) {
      setState(() => _state = const ACDSearchIdle([]));
      _removeOverlay();
      return;
    }

    setState(() {
      _state = const ACDSearchLoading();
      _highlighted = -1;
    });
    _showOverlay();
    _debounce = Timer(widget.searchDebounce, () => _runSearch(armed, query));
  }

  void _closeArmed() {
    _lastSearch = null;
    if (_armed != null) setState(() => _armed = null);
    _removeOverlay();
  }

  _ArmedTrigger? _findArmedTrigger(String text, int cursor) {
    if (cursor > text.length) return null;
    // Scan back from the caret for a trigger *ending* at i, preferring the
    // longest one there (so `::` wins over `:`).
    for (int i = cursor - 1; i >= 0; i--) {
      if (_isBoundary(text[i])) return null;

      ACDAutocompleteTrigger? match;
      int start = -1;
      for (final ACDAutocompleteTrigger t in widget.triggers) {
        final int from = i - t.trigger.length + 1;
        if (from < 0 || !text.startsWith(t.trigger, from)) continue;
        if (match == null || t.trigger.length > match.trigger.length) {
          match = t;
          start = from;
        }
      }
      if (match == null) continue;

      final bool atStart = start == 0;
      final bool afterSpace = start > 0 && _isBoundary(text[start - 1]);
      if (match.triggerOnlyAtStart && !atStart) continue;
      if (!match.triggerOnlyAtStart &&
          match.triggerOnlyAfterSpace &&
          !atStart &&
          !afterSpace) {
        continue;
      }
      return _ArmedTrigger(match, start);
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
  }

  void _showOverlay() {
    if (!_portal.isShowing && Overlay.maybeOf(context) != null) _portal.show();
  }

  void _removeOverlay() {
    if (_portal.isShowing) _portal.hide();
    _highlighted = -1;
  }

  List<Object?> get _visibleOptions => switch (_state) {
    ACDSearchIdle<Object?>(:final items) => items,
    ACDSearchLoaded<Object?>(:final items) => items,
    _ => const <Object?>[],
  };

  // Esc closes; arrows move the highlight; Enter picks it.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_portal.isShowing ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _closeArmed();
      return KeyEventResult.handled;
    }
    final List<Object?> options = _visibleOptions;
    if (options.isEmpty) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlighted = (_highlighted + 1) % options.length);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _highlighted = _highlighted <= 0
            ? options.length - 1
            : _highlighted - 1,
      );
      return KeyEventResult.handled;
    }
    if ((key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter) &&
        _highlighted >= 0 &&
        _highlighted < options.length) {
      _select(options[_highlighted]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The armed trigger's caret rect, in the field's own coordinates — from
  /// the field's `RenderEditable`, so wrapping, scrolling and RTL are all
  /// accounted for. Null when it can't be measured yet.
  Rect? _triggerCaretRect(RenderBox field) {
    final _ArmedTrigger? armed = _armed;
    if (armed == null) return null;
    RenderEditable? editable;
    void visit(RenderObject child) {
      if (editable != null) return;
      if (child is RenderEditable) {
        editable = child;
      } else {
        child.visitChildren(visit);
      }
    }

    field.visitChildren(visit);
    final RenderEditable? e = editable;
    if (e == null || !e.attached || !e.hasSize) return null;
    final Rect local = e.getLocalRectForCaret(
      TextPosition(offset: armed.startIndex),
    );
    final Offset origin = field.globalToLocal(e.localToGlobal(local.topLeft));
    return origin & local.size;
  }

  void _select(Object? option) {
    final _ArmedTrigger? armed = _armed;
    if (armed == null) return;
    final String text =
        armed.trigger.itemAsString?.call(option) ?? option.toString();
    final String current = _controller.text;
    final int cursor = _controller.selection.baseOffset;
    // Selection can be invalid (-1) or stale after an external edit.
    if (cursor < armed.startIndex || cursor > current.length) {
      _closeArmed();
      return;
    }
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
    // Last frame's layout of the field (overlay builds run after it).
    final RenderObject? ro = this.context.findRenderObject();
    final RenderBox? anchorBox = ro is RenderBox && ro.hasSize ? ro : null;
    final double fieldWidth = anchorBox?.size.width ?? 200;
    final double fieldHeight = anchorBox?.size.height ?? 56;
    final double popupHeight = widget.popupHeight ?? 260;
    final double popupWidth = fieldWidth * widget.popupWidthFactor;

    // The rect the popup hangs from, in field coordinates: the whole field,
    // or (caret mode) the trigger's caret.
    Rect anchor = Rect.fromLTWH(0, 0, fieldWidth, fieldHeight);
    if (widget.popupAnchor == ACDPopupAnchor.caret && anchorBox != null) {
      final Rect? caret = _triggerCaretRect(anchorBox);
      if (caret != null) {
        final double maxX = (fieldWidth - popupWidth).clamp(0.0, fieldWidth);
        final double x = caret.left.clamp(0.0, maxX);
        anchor = Rect.fromLTRB(x, caret.top, x + popupWidth, caret.bottom);
      }
    }

    bool flipAbove = false;
    if (anchorBox != null && anchorBox.attached) {
      final Offset anchorBottomGlobal = anchorBox.localToGlobal(
        anchor.bottomLeft,
      );
      // Space below excludes the on-screen keyboard.
      final double visibleBottom =
          MediaQuery.sizeOf(context).height -
          MediaQuery.viewInsetsOf(context).bottom;
      if (visibleBottom - anchorBottomGlobal.dy < popupHeight) {
        flipAbove = true;
      }
    }

    return Positioned(
      width: popupWidth,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        // Edge-to-edge anchoring: a popup shorter than popupHeight still
        // sits flush against the anchor when flipped above it.
        targetAnchor: Alignment.topLeft,
        followerAnchor: flipAbove ? Alignment.bottomLeft : Alignment.topLeft,
        offset: flipAbove ? anchor.topLeft : anchor.bottomLeft,
        // Same tap-region group as the field, so tapping an option doesn't
        // count as tapping outside (desktop/web would unfocus first).
        child: TextFieldTapRegion(
          child: ACDAdaptivePopupSurface(
            design: _design,
            elevation: widget.popupElevation,
            color: widget.popupColor,
            borderRadius: widget.popupBorderRadius,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: popupHeight),
              child: _buildOptionList(context),
            ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ACDAdaptiveProgress(
                  design: _design,
                  semanticsLabel: ACDDesignScope.stringsOf(context).loading,
                ),
              ),
            );
      case ACDSearchError<Object?>(:final error):
        return widget.errorBuilder?.call(context, error) ??
            Padding(padding: const EdgeInsets.all(16), child: Text('$error'));
      case ACDSearchEmpty<Object?>(:final query):
        return widget.emptyBuilder?.call(context, query) ??
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(ACDDesignScope.stringsOf(context).noMatches),
            );
      case ACDSearchIdle<Object?>(:final items):
      case ACDSearchLoaded<Object?>(:final items):
        if (items.isEmpty || trigger == null) return const SizedBox.shrink();
        final ACDResolvedDesign design = _design;
        final TextStyle itemStyle = (widget.itemStyle ?? const TextStyle())
            .merge(
              TextStyle(
                color: widget.itemTextColor,
                fontSize: widget.itemFontSize,
                fontWeight: widget.itemFontWeight,
                fontFamily: widget.itemFontFamily,
              ),
            );
        final Color? tileColor =
            widget.tileColor ?? (design.isCupertino ? null : Colors.white);
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final Object? option = items[index];
            if (trigger.itemBuilder != null) {
              return ACDAdaptiveTappable(
                design: design,
                onTap: () => _select(option),
                child: trigger.itemBuilder!(context, option),
              );
            }
            return ACDAdaptiveListTile(
              design: design,
              backgroundColor: tileColor,
              selected: index == _highlighted,
              title: Text(
                trigger.itemAsString?.call(option) ?? option.toString(),
                style: itemStyle,
              ),
              onTap: () => _select(option),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign design = ACDDesign.resolve(context, widget.design);
    _design = design;
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _onKey,
          child: ACDAdaptiveTextField(
            design: design,
            controller: _controller,
            focusNode: _focusNode,
            decoration: widget.decoration,
            cupertinoStyle: widget.cupertinoStyle,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
          ),
        ),
      ),
    );
  }
}
