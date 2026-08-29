import 'dart:async';

import 'package:flutter/material.dart';

import '../list_tile/acd_search_state.dart';

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
    this.tileColor = Colors.white,
    this.itemTextColor,
    this.itemFontSize,
    this.itemFontWeight,
    this.itemFontFamily,
    this.itemStyle,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
  });

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

  /// Background color of each suggestion tile.
  final Color tileColor;

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
  OverlayEntry? _overlayEntry;
  ACDSearchState<T> _state = const ACDSearchIdle([]);
  int _requestId = 0;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());
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
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  String _asString(T item) =>
      widget.itemAsString?.call(item) ?? item.toString();

  void _onTextChanged() {
    final String query = _controller.text;
    _debounce?.cancel();

    if (query.length < widget.minCharsForSuggestions) {
      setState(() => _state = ACDSearchIdle<T>(widget.suggestions));
      _removeOverlay();
      return;
    }

    _debounce = Timer(widget.searchDebounce, () => _runSearch(query));
    setState(() => _state = const ACDSearchLoading());
    _showOverlay();
  }

  Future<void> _runSearch(String query) async {
    final int requestId = ++_requestId;
    if (widget.onFind != null) {
      try {
        final List<T> results = await widget.onFind!(query);
        if (!mounted || requestId != _requestId) return;
        setState(
          () => _state = results.isEmpty
              ? ACDSearchEmpty<T>(query)
              : ACDSearchLoaded<T>(results),
        );
      } catch (error, stackTrace) {
        if (!mounted || requestId != _requestId) return;
        setState(() => _state = ACDSearchError<T>(error, query, stackTrace));
      }
    } else {
      final bool Function(T, String) predicate =
          widget.filterFn ??
          (item, q) => _asString(item).toLowerCase().contains(q.toLowerCase());
      final List<T> results = widget.suggestions
          .where((item) => predicate(item, query))
          .toList();
      setState(
        () => _state = results.isEmpty
            ? ACDSearchEmpty<T>(query)
            : ACDSearchLoaded<T>(results),
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

  void _select(T item) {
    if (widget.submitOnSuggestionTap) {
      _controller.text = _asString(item);
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
    final RenderBox? anchorBox = this.context.findRenderObject() as RenderBox?;
    final double fieldHeight =
        anchorBox?.size.height ?? (widget.decoration.isDense == true ? 40 : 56);
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
            child: _buildSuggestionList(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionList(BuildContext context) {
    switch (_state) {
      case ACDSearchLoading<T>():
        return widget.loadingBuilder?.call(context) ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
      case ACDSearchError<T>(:final error):
        return widget.errorBuilder?.call(context, error) ??
            Padding(padding: const EdgeInsets.all(16), child: Text('$error'));
      case ACDSearchEmpty<T>(:final query):
        return widget.emptyBuilder?.call(context, query) ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No matches'),
            );
      case ACDSearchIdle<T>(:final items):
      case ACDSearchLoaded<T>(:final items):
        if (items.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final T item = items[index];
            if (widget.itemBuilder != null) {
              return InkWell(
                onTap: () => _select(item),
                child: widget.itemBuilder!(context, item, false),
              );
            }
            return Material(
              color: widget.tileColor,
              child: ListTile(
                title: Text(
                  _asString(item),
                  style: (widget.itemStyle ?? const TextStyle()).merge(
                    TextStyle(
                      color: widget.itemTextColor,
                      fontSize: widget.itemFontSize,
                      fontWeight: widget.itemFontWeight,
                      fontFamily: widget.itemFontFamily,
                    ),
                  ),
                ),
                onTap: () => _select(item),
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
        onSubmitted: (text) {
          widget.onSubmitted?.call(text);
          if (widget.clearOnSubmit) _controller.clear();
          _removeOverlay();
        },
      ),
    );
  }
}
