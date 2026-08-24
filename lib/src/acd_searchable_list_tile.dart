import 'dart:async';

import 'package:flutter/material.dart';

import 'acd_search_state.dart';

/// The widget behind `ACDDialog.searchableList()` /
/// `ACDDialog.multiSearchableList()`. Not normally constructed directly.
///
/// Selection is tracked with `==`/`hashCode`, so for multi-select ([multiple]
/// `true`) a custom [T] must implement both consistently with value
/// identity.
class ACDSearchableListTile<T> extends StatefulWidget {
  /// Creates an [ACDSearchableListTile].
  const ACDSearchableListTile({
    super.key,
    required this.items,
    required this.multiple,
    this.itemAsString,
    this.itemBuilder,
    this.onFind,
    this.searchDebounce = const Duration(milliseconds: 350),
    this.initialValue,
    this.initialValues,
    this.onChange,
    this.onMultipleItemsChange,
    this.isClickAutoDismiss = true,
    this.showSearchBox = true,
    this.searchHint,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.tileColor = Colors.white,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.style,
    this.searchFillColor,
    this.searchBorderColor,
    this.searchBorderRadius = 4.0,
    this.physics,
    this.controller,
    this.searchController,
    this.dialogDismiss,
    this.showConfirmCancelButtons = true,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.cancelColor,
    this.confirmFontWeight,
    this.checkboxActiveColor,
  });

  /// The base dataset shown before any search, and searched locally when
  /// [onFind] isn't set.
  final List<T> items;

  /// `true` for multi-select (`ACDDialog.multiSearchableList()`), `false`
  /// for single-select (`ACDDialog.searchableList()`).
  final bool multiple;

  /// Extracts the display label for an item. Defaults to `item.toString()`.
  final String Function(T item)? itemAsString;

  /// Custom row builder. Falls back to a plain `ListTile` using
  /// [itemAsString] when omitted.
  final Widget Function(BuildContext context, T item, bool selected)?
  itemBuilder;

  /// Async remote search. When set, a non-empty query is delegated to this
  /// exclusively — [items] is only used for the idle (pre-search) state.
  final Future<List<T>> Function(String keyword)? onFind;

  /// How long to wait after the user stops typing before searching.
  final Duration searchDebounce;

  /// Pre-selected item (single-select only).
  final T? initialValue;

  /// Pre-selected items (multi-select only).
  final List<T>? initialValues;

  /// Called with the selected item (single-select only).
  final void Function(T item)? onChange;

  /// Called with the confirmed selection (multi-select only) — fires when
  /// the user taps the confirm button, not on every toggle.
  final void Function(List<T> items)? onMultipleItemsChange;

  /// Whether tapping a row dismisses the dialog (single-select only).
  final bool isClickAutoDismiss;

  /// Whether to show the search field at all.
  final bool showSearchBox;

  /// Search field hint text.
  final String? searchHint;

  /// Shown while a search is in flight. Defaults to a centered spinner.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Shown when a search returns no results. Defaults to a centered
  /// "No results" message.
  final Widget Function(BuildContext context, String query)? emptyBuilder;

  /// Shown when [onFind] throws. Defaults to a centered error message.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Background color of each row.
  final Color tileColor;

  /// Row text color.
  final Color? color;

  /// Row text size.
  final double? fontSize;

  /// Row text weight.
  final FontWeight? fontWeight;

  /// Row text font family.
  final String? fontFamily;

  /// Full row text style control, merged over [color]/[fontSize]/
  /// [fontWeight]/[fontFamily] above.
  final TextStyle? style;

  /// Fill color of the search field.
  final Color? searchFillColor;

  /// Border color of the search field.
  final Color? searchBorderColor;

  /// Corner radius of the search field.
  final double searchBorderRadius;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Scroll controller for the list.
  final ScrollController? controller;

  /// Controller for the search field. Provide your own to read/clear the
  /// query programmatically.
  final TextEditingController? searchController;

  /// Closes the enclosing dialog. Passed down from
  /// `ACDDialog.searchableList()`/`multiSearchableList()` — this widget
  /// never depends on `ACDDialog` directly.
  final VoidCallback? dialogDismiss;

  /// Whether to show the built-in Confirm/Cancel row (multi-select only).
  final bool showConfirmCancelButtons;

  /// Confirm button label (multi-select only).
  final String confirmText;

  /// Cancel button label (multi-select only).
  final String cancelText;

  /// Confirm button color (multi-select only).
  final Color? confirmColor;

  /// Cancel button color (multi-select only).
  final Color? cancelColor;

  /// Confirm button font weight (multi-select only).
  final FontWeight? confirmFontWeight;

  /// Color of a checked row's checkbox (multi-select only).
  final Color? checkboxActiveColor;

  @override
  State<ACDSearchableListTile<T>> createState() =>
      _ACDSearchableListTileState<T>();
}

class _ACDSearchableListTileState<T> extends State<ACDSearchableListTile<T>> {
  late final TextEditingController _searchController;
  late ACDSearchState<T> _state;
  late Set<T> _selected;
  T? _selectedValue;
  Timer? _debounce;
  int _searchGeneration = 0;
  bool _ownsSearchController = false;

  String _labelOf(T item) => widget.itemAsString?.call(item) ?? item.toString();

  @override
  void initState() {
    super.initState();
    _state = ACDSearchIdle<T>(widget.items);
    _selected = Set<T>.from(widget.initialValues ?? <T>[]);
    _selectedValue = widget.initialValue;
    if (widget.searchController != null) {
      _searchController = widget.searchController!;
    } else {
      _searchController = TextEditingController();
      _ownsSearchController = true;
    }
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onQueryChanged);
    if (_ownsSearchController) _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _searchController.text;
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _state = ACDSearchIdle<T>(widget.items));
      return;
    }
    _debounce = Timer(widget.searchDebounce, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    // Guards a slow, superseded search from overwriting a newer one's
    // result once it (eventually) resolves.
    final int generation = ++_searchGeneration;

    if (widget.onFind != null) {
      setState(() => _state = const ACDSearchLoading());
      try {
        final results = await widget.onFind!(query);
        if (!mounted || generation != _searchGeneration) return;
        setState(
          () => _state = results.isEmpty
              ? ACDSearchEmpty<T>(query)
              : ACDSearchLoaded<T>(results),
        );
      } catch (error, stackTrace) {
        if (!mounted || generation != _searchGeneration) return;
        setState(() => _state = ACDSearchError<T>(error, query, stackTrace));
      }
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = widget.items
        .where((item) => _labelOf(item).toLowerCase().contains(lowerQuery))
        .toList();
    setState(
      () => _state = filtered.isEmpty
          ? ACDSearchEmpty<T>(query)
          : ACDSearchLoaded<T>(filtered),
    );
  }

  void _handleTap(T item) {
    if (widget.multiple) {
      setState(() {
        if (_selected.contains(item)) {
          _selected.remove(item);
        } else {
          _selected.add(item);
        }
      });
      return;
    }
    setState(() => _selectedValue = item);
    widget.onChange?.call(item);
    if (widget.isClickAutoDismiss) widget.dialogDismiss?.call();
  }

  bool _isSelected(T item) =>
      widget.multiple ? _selected.contains(item) : _selectedValue == item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.showSearchBox) _buildSearchField(context),
        Expanded(child: _buildBody(context, _state)),
        if (widget.multiple && widget.showConfirmCancelButtons)
          _buildConfirmCancelRow(context),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.searchHint ?? 'Search...',
          prefixIcon: const Icon(Icons.search),
          fillColor: widget.searchFillColor,
          filled: widget.searchFillColor != null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.searchBorderRadius),
            borderSide: BorderSide(
              color: widget.searchBorderColor ?? Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ACDSearchState<T> state) {
    return switch (state) {
      ACDSearchIdle<T> s => _buildList(context, s.items),
      ACDSearchLoading<T>() =>
        widget.loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator()),
      ACDSearchLoaded<T> s => _buildList(context, s.items),
      ACDSearchEmpty<T> s =>
        widget.emptyBuilder?.call(context, s.query) ??
            Center(child: Text('No results for "${s.query}"')),
      ACDSearchError<T> s =>
        widget.errorBuilder?.call(context, s.error) ??
            const Center(child: Text('Something went wrong.')),
    };
  }

  Widget _buildList(BuildContext context, List<T> items) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.physics,
      controller: widget.controller,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = _isSelected(item);
        if (widget.itemBuilder != null) {
          return InkWell(
            onTap: () => _handleTap(item),
            child: widget.itemBuilder!(context, item, selected),
          );
        }
        return Material(
          color: widget.tileColor,
          child: ListTile(
            onTap: () => _handleTap(item),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            leading: widget.multiple
                ? Checkbox(
                    value: selected,
                    activeColor: widget.checkboxActiveColor,
                    onChanged: (_) => _handleTap(item),
                  )
                : null,
            trailing: !widget.multiple && selected
                ? const Icon(Icons.check)
                : null,
            title: Text(
              _labelOf(item),
              style: TextStyle(
                color: widget.color,
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                fontFamily: widget.fontFamily,
              ).merge(widget.style),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmCancelRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: widget.dialogDismiss,
          style: TextButton.styleFrom(
            foregroundColor: widget.cancelColor ?? Colors.grey,
          ),
          child: Text(widget.cancelText),
        ),
        TextButton(
          onPressed: () {
            widget.onMultipleItemsChange?.call(_selected.toList());
            widget.dialogDismiss?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: widget.confirmColor ?? Colors.teal,
            textStyle: TextStyle(fontWeight: widget.confirmFontWeight),
          ),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
