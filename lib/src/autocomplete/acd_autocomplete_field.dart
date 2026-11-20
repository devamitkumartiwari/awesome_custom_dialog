import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_cupertino_field_style.dart';
import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import '../list_tile/acd_search_state.dart';
import 'acd_highlighted_text.dart';

/// A generic, dependency-free typeahead text field.
///
/// ```dart
/// ACDAutocompleteField<String>(
///   suggestions: countries,
///   decoration: const InputDecoration(labelText: 'Country'),
///   onSuggestionSelected: (country) => debugPrint('Picked $country'),
/// )
/// ```
///
/// Supply [onFind] instead of relying on local [filterFn] filtering to
/// search a remote source (debounced by [searchDebounce]), matching
/// [ACDDropdownField]'s `onFind` shape.
class ACDAutocompleteField<T> extends StatefulWidget {
  /// Creates an [ACDAutocompleteField].
  const ACDAutocompleteField({
    super.key,
    required this.suggestions,
    this.itemAsString,
    this.itemBuilder,
    this.onFind,
    this.filterFn,
    this.searchDebounce = const Duration(milliseconds: 350),
    this.minCharsForSuggestions = 1,
    this.submitOnSuggestionTap = true,
    this.clearOnSubmit = false,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.onSuggestionSelected,
    this.onSubmitted,
    this.popupWidthFactor = 1.0,
    this.popupHeight,
    this.popupElevation = 4,
    this.popupBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.popupColor,
    this.tileColor,
    this.itemTextColor,
    this.itemFontSize,
    this.itemFontWeight,
    this.itemFontFamily,
    this.itemStyle,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.design,
    this.cupertinoStyle,
    this.highlightMatches = false,
  });

  /// Material (default) / Cupertino / adaptive — see [ACDDesign].
  final ACDDesign? design;

  /// Cupertino-only field styling (used when the design resolves to
  /// Cupertino). [decoration]'s hint/prefix/suffix/error still map over.
  final ACDCupertinoFieldStyle? cupertinoStyle;

  /// Bold the part of each default suggestion row that matches the query.
  final bool highlightMatches;

  /// The local dataset suggestions are filtered from, when [onFind] is not
  /// supplied.
  final List<T> suggestions;

  /// Renders an item as text; defaults to `item.toString()`.
  final String Function(T item)? itemAsString;

  /// Custom suggestion-row builder. Defaults to a [ListTile] showing
  /// [itemAsString].
  final Widget Function(BuildContext context, T item, bool highlighted)?
  itemBuilder;

  /// Searches a remote source; supersedes local [filterFn] when supplied.
  final Future<List<T>> Function(String query)? onFind;

  /// Local match predicate. Defaults to a case-insensitive substring match
  /// against [itemAsString].
  final bool Function(T item, String query)? filterFn;

  /// Delay before [onFind]/[filterFn] runs after each keystroke.
  final Duration searchDebounce;

  /// Minimum characters typed before suggestions are shown.
  final int minCharsForSuggestions;

  /// Whether tapping a suggestion also submits the field (closing the
  /// popup and calling [onSubmitted]).
  final bool submitOnSuggestionTap;

  /// Whether the field clears after a suggestion is submitted.
  final bool clearOnSubmit;

  /// Externally-owned controller. Owned and disposed internally when null —
  /// pass one to call `.clear()` programmatically.
  final TextEditingController? controller;

  /// Externally-owned focus node. Owned and disposed internally when null.
  final FocusNode? focusNode;

  /// Decoration for the underlying [TextField].
  final InputDecoration decoration;

  /// Fired when a suggestion is tapped.
  final ValueChanged<T>? onSuggestionSelected;

  /// Fired when the field is submitted (via keyboard action, or a tapped
  /// suggestion when [submitOnSuggestionTap] is true).
  final ValueChanged<String>? onSubmitted;

  /// Popup width as a factor of the field's width.
  final double popupWidthFactor;

  /// Max popup height. Defaults to a sensible fixed height.
  final double? popupHeight;

  /// Popup card elevation.
  final double popupElevation;

  /// Popup card corner rounding.
  final BorderRadius popupBorderRadius;

  /// Popup card background color.
  final Color? popupColor;

  /// Background color of each suggestion tile. Defaults to white (Material)
  /// or the popup surface (Cupertino).
  final Color? tileColor;

  /// Suggestion text color.
  final Color? itemTextColor;

  /// Suggestion text size.
  final double? itemFontSize;

  /// Suggestion text weight.
  final FontWeight? itemFontWeight;

  /// Suggestion text font family.
  final String? itemFontFamily;

  /// Suggestion text style, merged over the color/size/weight/family fields.
  final TextStyle? itemStyle;

  /// Shown while [onFind] is in flight.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Shown when a search yields no matches.
  final Widget Function(BuildContext context, String query)? emptyBuilder;

  /// Shown when [onFind] throws.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<ACDAutocompleteField<T>> createState() =>
      _ACDAutocompleteFieldState<T>();
}

class _ACDAutocompleteFieldState<T> extends State<ACDAutocompleteField<T>> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  Timer? _debounce;
  final LayerLink _layerLink = LayerLink();
  // The popup lives in this widget's own subtree via OverlayPortal: it
  // rebuilds with the field (no manual markNeedsBuild), inherits the field's
  // theme/scope, and is torn down with it.
  final OverlayPortalController _portal = OverlayPortalController();
  ACDSearchState<T> _state = const ACDSearchIdle([]);
  int _requestId = 0;

  // Last query handled — the controller also notifies on caret/selection
  // moves, which must not reopen the popup or re-run the search.
  String? _lastQuery;

  // Keyboard-highlighted suggestion (arrow keys), or -1 for none.
  int _highlighted = -1;

  // Design resolved in build() with the field's own context, reused by the
  // overlay (whose builder context sits under the Overlay, not this field).
  ACDResolvedDesign _design = ACDResolvedDesign.material;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _lastQuery = _controller.text;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ACDAutocompleteField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-wire listeners when the caller swaps controller/focus node —
    // otherwise the old one keeps driving this field and the new one is
    // never listened to.
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(
        _onTextChanged,
      );
      _lastQuery = _controller.text;
      _controller.addListener(_onTextChanged);
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
    if (!_focusNode.hasFocus) {
      _removeOverlay();
      return;
    }
    // minCharsForSuggestions: 0 means "suggest on focus".
    if (widget.minCharsForSuggestions == 0 &&
        _controller.text.isEmpty &&
        !_portal.isShowing) {
      _startSearch('');
    }
  }

  List<T> get _visibleItems => switch (_state) {
    ACDSearchIdle<T>(:final items) => items,
    ACDSearchLoaded<T>(:final items) => items,
    _ => <T>[],
  };

  // Arrow/Enter/Escape navigation while the popup is open. Runs before the
  // text field's own editing shortcuts (this Focus is its ancestor).
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_portal.isShowing ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final List<T> items = _visibleItems;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _removeOverlay();
      return KeyEventResult.handled;
    }
    if (items.isEmpty) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.arrowDown) {
      _setHighlighted((_highlighted + 1) % items.length);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _setHighlighted(_highlighted <= 0 ? items.length - 1 : _highlighted - 1);
      return KeyEventResult.handled;
    }
    if ((key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter) &&
        _highlighted >= 0 &&
        _highlighted < items.length) {
      _select(items[_highlighted]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _setHighlighted(int index) {
    setState(() => _highlighted = index);
  }

  String _asString(T item) =>
      widget.itemAsString?.call(item) ?? item.toString();

  void _onTextChanged() {
    final String query = _controller.text;
    if (query == _lastQuery) return; // caret/selection-only change
    _lastQuery = query;
    _debounce?.cancel();

    if (query.length < widget.minCharsForSuggestions) {
      setState(() => _state = ACDSearchIdle<T>(widget.suggestions));
      _removeOverlay();
      return;
    }
    _startSearch(query);
  }

  void _startSearch(String query) {
    _highlighted = -1;
    if (widget.onFind == null) {
      // Local filtering is synchronous and cheap: no debounce, no spinner
      // flash — results update on the same frame as the keystroke.
      _requestId++;
      _applyResults(query, _filterLocal(query));
      _showOverlay();
      return;
    }
    _debounce = Timer(widget.searchDebounce, () => _runSearch(query));
    setState(() => _state = const ACDSearchLoading());
    _showOverlay();
  }

  List<T> _filterLocal(String query) {
    final bool Function(T, String) predicate =
        widget.filterFn ??
        (item, q) => _asString(item).toLowerCase().contains(q.toLowerCase());
    return widget.suggestions.where((item) => predicate(item, query)).toList();
  }

  void _applyResults(String query, List<T> results) {
    setState(
      () => _state = results.isEmpty
          ? ACDSearchEmpty<T>(query)
          : ACDSearchLoaded<T>(results),
    );
    if (query.isNotEmpty) {
      acdAnnounce(
        context,
        ACDDesignScope.stringsOf(context).resultsAnnouncement(results.length),
      );
    }
  }

  Future<void> _runSearch(String query) async {
    final int requestId = ++_requestId;
    try {
      final List<T> results = await widget.onFind!(query);
      if (!mounted || requestId != _requestId) return;
      _applyResults(query, results);
    } catch (error, stackTrace) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _state = ACDSearchError<T>(error, query, stackTrace));
    }
  }

  void _showOverlay() {
    if (!_portal.isShowing && Overlay.maybeOf(context) != null) _portal.show();
  }

  void _removeOverlay() {
    if (_portal.isShowing) _portal.hide();
    _highlighted = -1;
  }

  void _select(T item) {
    if (widget.submitOnSuggestionTap) {
      // Writing the picked label into the field is not a new query: mark it
      // handled so the listener doesn't debounce a fresh search (which used
      // to call onFind again with the selected value).
      final String picked = _asString(item);
      _lastQuery = picked;
      _debounce?.cancel();
      _requestId++; // drop any in-flight result for the old query
      _controller.text = picked;
      widget.onSuggestionSelected?.call(item);
      widget.onSubmitted?.call(_controller.text);
      if (widget.clearOnSubmit) _controller.clear();
      _removeOverlay();
      _focusNode.unfocus();
    } else {
      widget.onSuggestionSelected?.call(item);
    }
  }

  Widget _buildOverlay(BuildContext context) {
    // Last frame's layout of the field (overlay builds run after it).
    final RenderObject? ro = this.context.findRenderObject();
    final RenderBox? anchorBox = ro is RenderBox && ro.hasSize ? ro : null;
    final double fieldWidth = anchorBox?.size.width ?? 200;
    final double popupHeight = widget.popupHeight ?? 260;

    bool flipAbove = false;
    if (anchorBox != null && anchorBox.attached) {
      final Offset fieldBottomGlobal = anchorBox.localToGlobal(
        Offset(0, anchorBox.size.height),
      );
      // Space below excludes the on-screen keyboard.
      final double visibleBottom =
          MediaQuery.sizeOf(context).height -
          MediaQuery.viewInsetsOf(context).bottom;
      if (visibleBottom - fieldBottomGlobal.dy < popupHeight) {
        flipAbove = true;
      }
    }

    return Positioned(
      width: fieldWidth * widget.popupWidthFactor,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        // Anchor edge-to-edge, so a popup shorter than popupHeight still
        // sits flush against the field when flipped above it.
        targetAnchor: flipAbove ? Alignment.topLeft : Alignment.bottomLeft,
        followerAnchor: flipAbove ? Alignment.bottomLeft : Alignment.topLeft,
        // Same tap-region group as the text field: tapping a suggestion is
        // not a "tap outside", so desktop/web don't unfocus the field (and
        // tear the popup down) before the tap lands.
        child: TextFieldTapRegion(
          child: ACDAdaptivePopupSurface(
            design: _design,
            elevation: widget.popupElevation,
            color: widget.popupColor,
            borderRadius: widget.popupBorderRadius,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: popupHeight),
              child: _buildSuggestionList(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionList(BuildContext context) {
    switch (_state) {
      case ACDSearchLoading<T>():
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
      case ACDSearchError<T>(:final error):
        return widget.errorBuilder?.call(context, error) ??
            Padding(padding: const EdgeInsets.all(16), child: Text('$error'));
      case ACDSearchEmpty<T>(:final query):
        return widget.emptyBuilder?.call(context, query) ??
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(ACDDesignScope.stringsOf(context).noMatches),
            );
      case ACDSearchIdle<T>(:final items):
      case ACDSearchLoaded<T>(:final items):
        if (items.isEmpty) return const SizedBox.shrink();
        // Resolved once for the whole list, not per row.
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
        final String query = _controller.text;
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final T item = items[index];
            final bool highlighted = index == _highlighted;
            if (widget.itemBuilder != null) {
              return ACDAdaptiveTappable(
                design: design,
                onTap: () => _select(item),
                child: widget.itemBuilder!(context, item, highlighted),
              );
            }
            final String label = _asString(item);
            return ACDAdaptiveListTile(
              design: design,
              backgroundColor: tileColor,
              selected: highlighted,
              title: widget.highlightMatches
                  ? ACDHighlightedText(
                      text: label,
                      query: query,
                      style: itemStyle,
                    )
                  : Text(label, style: itemStyle),
              onTap: () => _select(item),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    _design = ACDDesign.resolve(context, widget.design);
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
            design: _design,
            controller: _controller,
            focusNode: _focusNode,
            decoration: widget.decoration,
            cupertinoStyle: widget.cupertinoStyle,
            onSubmitted: (text) {
              widget.onSubmitted?.call(text);
              if (widget.clearOnSubmit) _controller.clear();
              _removeOverlay();
            },
          ),
        ),
      ),
    );
  }
}
