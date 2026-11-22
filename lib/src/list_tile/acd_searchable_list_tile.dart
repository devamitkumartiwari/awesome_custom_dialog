import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/acd_design_tokens.dart';
import '../design/acd_strings.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import 'acd_search_state.dart';

/// The widget behind `ACDDialog.searchableList()` /
/// `ACDDialog.multiSearchableList()`. Not normally constructed directly.
///
/// Selection is tracked with `==`/`hashCode` by default, so for multi-select
/// ([multiple] `true`) a custom [T] must implement both consistently with
/// value identity — or pass [compareFn] to use custom equality instead.
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
    this.tileColor,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.style,
    this.searchFillColor,
    this.searchBorderColor,
    this.searchBorderRadius = 4.0,
    this.searchIcon = Icons.search,
    this.borderRadius,
    this.physics,
    this.controller,
    this.searchController,
    this.dialogDismiss,
    this.showConfirmCancelButtons = true,
    this.confirmText,
    this.cancelText,
    this.confirmColor,
    this.cancelColor,
    this.confirmFontWeight,
    this.checkboxActiveColor,
    this.maxSelection,
    this.showSelectAll = false,
    this.groupBy,
    this.cacheResults = false,
    this.onCreate,
    this.compareFn,
    this.isDisabledItem,
    this.favoriteItems,
    this.onFindPaged,
    this.loadMoreBuilder,
    this.design,
  });

  /// The base dataset shown before any search, and searched locally when
  /// [onFind] isn't set.
  final List<T> items;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign].
  final ACDDesign? design;

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

  /// Background color of each row. Defaults to white (Material) or the
  /// grouped-list cell color (Cupertino).
  final Color? tileColor;

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

  /// Icon shown at the start of the search field.
  final IconData searchIcon;

  /// Corner rounding for each row (ignored when [itemBuilder] is set — it
  /// fully replaces row rendering).
  final BorderRadius? borderRadius;

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
  final String? confirmText;

  /// Cancel button label (multi-select only).
  final String? cancelText;

  /// Confirm button color (multi-select only).
  final Color? confirmColor;

  /// Cancel button color (multi-select only).
  final Color? cancelColor;

  /// Confirm button font weight (multi-select only).
  final FontWeight? confirmFontWeight;

  /// Color of a checked row's checkbox (multi-select only).
  final Color? checkboxActiveColor;

  /// Custom equality for selection tracking, used in place of `==` when
  /// set. Lets a `T` without a value-based `==`/`hashCode` override still
  /// work correctly for both single- and multi-select highlighting.
  final bool Function(T a, T b)? compareFn;

  /// Marks individual rows as non-interactive (dimmed, ignores taps).
  final bool Function(T item)? isDisabledItem;

  /// Multi-select: the most items that can be selected. Once reached, the
  /// remaining rows are disabled until something is deselected.
  final int? maxSelection;

  /// Multi-select: a "Select all" row above the list that toggles every
  /// visible, enabled row (up to [maxSelection]).
  final bool showSelectAll;

  /// Groups rows under section headers, in the order groups first appear.
  /// Rows of one group should be contiguous in [items] for a tidy list.
  final String Function(T item)? groupBy;

  /// Caches [onFind] results per query, so retyping or going back to an
  /// earlier query doesn't hit the network again. The cache lives as long
  /// as this list (one popup).
  final bool cacheResults;

  /// Offers a "Create "query"" row when a search finds nothing. Return the
  /// new item (e.g. after saving it) to select it, or `null` to cancel.
  final Future<T?> Function(String query)? onCreate;

  /// Shown pinned at the top of the idle (pre-search) list, ahead of
  /// [items] — cleared once a search query narrows the list.
  final List<T>? favoriteItems;

  /// Paginated async search/load: called with the current query and a
  /// zero-based page number, first for the idle (empty-query) page and
  /// again for each page after as the list is scrolled to its end (or right
  /// away, while the loaded rows don't fill the viewport yet). Returning an
  /// empty list marks the end of the data. A failed page shows a retry row. When set, this supersedes both [items] and [onFind]
  /// entirely (idle state is just page 0 of an empty query).
  final Future<List<T>> Function(String keyword, int page)? onFindPaged;

  /// Trailing row shown at the end of the list while more of
  /// [onFindPaged]'s pages remain to load. Defaults to a centered, small
  /// spinner.
  final Widget Function(BuildContext context)? loadMoreBuilder;

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
  final Map<String, List<T>> _cache = <String, List<T>>{};
  bool _creating = false;

  bool get _atMaxSelection =>
      widget.multiple &&
      widget.maxSelection != null &&
      _selected.length >= widget.maxSelection!;
  bool _ownsSearchController = false;

  String _labelOf(T item) => widget.itemAsString?.call(item) ?? item.toString();

  // Pinned items first (in the order given), followed by the rest of
  // [items] — only meaningful for the idle (pre-search) list.
  List<T> get _idleItems {
    final favorites = widget.favoriteItems;
    if (favorites == null || favorites.isEmpty) return widget.items;
    bool isFavorite(T item) => favorites.any((f) => _equals(f, item));
    return [...favorites, ...widget.items.where((item) => !isFavorite(item))];
  }

  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  /// The last load-more failed: stop auto-loading on scroll (which would
  /// re-fire the failing request on every scroll update) until the user
  /// taps retry.
  bool _loadMoreFailed = false;

  /// The query the current results belong to, so caret/selection-only
  /// controller notifications don't re-run the search.
  late String _lastQuery;
  ScrollController? _paginationController;
  bool _ownsPaginationController = false;

  bool get _paginating => widget.onFindPaged != null;

  @override
  void initState() {
    super.initState();
    _state = ACDSearchIdle<T>(_idleItems);
    _selected = Set<T>.from(widget.initialValues ?? <T>[]);
    _selectedValue = widget.initialValue;
    if (widget.searchController != null) {
      _searchController = widget.searchController!;
    } else {
      _searchController = TextEditingController();
      _ownsSearchController = true;
    }
    _lastQuery = _searchController.text;
    _searchController.addListener(_onQueryChanged);
    if (_paginating) {
      if (widget.controller != null) {
        _paginationController = widget.controller;
      } else {
        _paginationController = ScrollController();
        _ownsPaginationController = true;
      }
      _paginationController!.addListener(_maybeLoadMore);
      _loadPage(query: '', reset: true);
    }
  }

  @override
  void didUpdateWidget(covariant ACDSearchableListTile<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // New local data while the popup is open: refresh what's on screen.
    if (_paginating) return;
    if (!identical(widget.items, oldWidget.items) ||
        !identical(widget.favoriteItems, oldWidget.favoriteItems)) {
      final String query = _searchController.text;
      if (query.isEmpty) {
        _state = ACDSearchIdle<T>(_idleItems);
      } else if (widget.onFind == null) {
        _state = _filterLocal(query);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onQueryChanged);
    if (_ownsSearchController) _searchController.dispose();
    _paginationController?.removeListener(_maybeLoadMore);
    if (_ownsPaginationController) _paginationController?.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _searchController.text;
    if (query == _lastQuery) return; // caret/selection-only change
    _lastQuery = query;
    _debounce?.cancel();
    if (_paginating) {
      _debounce = Timer(
        widget.searchDebounce,
        () => _loadPage(query: query, reset: true),
      );
      return;
    }
    if (query.isEmpty) {
      // Supersede any in-flight onFind for the old query.
      _searchGeneration++;
      setState(() => _state = ACDSearchIdle<T>(_idleItems));
      return;
    }
    _debounce = Timer(widget.searchDebounce, () => _runSearch(query));
  }

  void _maybeLoadMore() {
    if (_loadingMore || !_hasMore || _loadMoreFailed) return;
    final ScrollController? controller = _paginationController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadPage(query: _searchController.text, reset: false);
    }
  }

  Future<void> _loadPage({required String query, required bool reset}) async {
    if (reset) {
      _page = 0;
      _hasMore = true;
      // A superseded load-more never reports back; don't leave it latched.
      _loadingMore = false;
      _loadMoreFailed = false;
    }
    if (!_hasMore) return;
    final int generation = reset ? ++_searchGeneration : _searchGeneration;
    setState(
      () => reset ? _state = const ACDSearchLoading() : _loadingMore = true,
    );
    try {
      final results = await widget.onFindPaged!(query, _page);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _loadingMore = false;
        _hasMore = results.isNotEmpty;
        if (_hasMore) _page++;
        final ACDSearchState<T> current = _state;
        final List<T> merged = reset
            ? results
            : [if (current is ACDSearchLoaded<T>) ...current.items, ...results];
        _state = merged.isEmpty
            ? ACDSearchEmpty<T>(query)
            : ACDSearchLoaded<T>(merged);
      });
      // A short page may not fill the viewport, so no scroll event would
      // ever ask for the next one: check once it has laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeLoadMore();
      });
    } catch (error, stackTrace) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _loadingMore = false;
        if (reset) {
          _state = ACDSearchError<T>(error, query, stackTrace);
        } else {
          _loadMoreFailed = true;
        }
      });
    }
  }

  Future<void> _runSearch(String query) async {
    // Guards a slow, superseded search from overwriting a newer one's
    // result once it (eventually) resolves.
    final int generation = ++_searchGeneration;

    if (widget.onFind != null) {
      setState(() => _state = const ACDSearchLoading());
      try {
        final List<T>? cached = widget.cacheResults ? _cache[query] : null;
        final List<T> results = cached ?? await widget.onFind!(query);
        if (widget.cacheResults) _cache[query] = results;
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

    setState(() => _state = _filterLocal(query));
  }

  ACDSearchState<T> _filterLocal(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = widget.items
        .where((item) => _labelOf(item).toLowerCase().contains(lowerQuery))
        .toList();
    return filtered.isEmpty
        ? ACDSearchEmpty<T>(query)
        : ACDSearchLoaded<T>(filtered);
  }

  bool _equals(T a, T b) => widget.compareFn?.call(a, b) ?? a == b;

  // Set.contains()/remove() rely on ==/hashCode, so a compareFn-driven
  // lookup has to fall back to a linear scan for the actual stored instance
  // (which may not be == to `item` even though compareFn considers them a
  // match).
  T? _findInSelected(T item) {
    if (widget.compareFn == null) {
      return _selected.contains(item) ? item : null;
    }
    for (final candidate in _selected) {
      if (widget.compareFn!(candidate, item)) return candidate;
    }
    return null;
  }

  void _handleTap(T item) {
    if (widget.isDisabledItem?.call(item) ?? false) return;
    if (widget.multiple) {
      setState(() {
        final existing = _findInSelected(item);
        if (existing != null) {
          _selected.remove(existing);
        } else if (!_atMaxSelection) {
          _selected.add(item);
        }
      });
      // Without a Confirm button nothing else would ever commit the
      // selection, so each toggle commits.
      if (!widget.showConfirmCancelButtons) {
        widget.onMultipleItemsChange?.call(_selected.toList());
      }
      return;
    }
    setState(() => _selectedValue = item);
    widget.onChange?.call(item);
    if (widget.isClickAutoDismiss) widget.dialogDismiss?.call();
  }

  bool _isSelected(T item) {
    if (widget.multiple) return _findInSelected(item) != null;
    final selectedValue = _selectedValue;
    return selectedValue != null && _equals(selectedValue, item);
  }

  @override
  Widget build(BuildContext context) {
    // Resolved once and passed down — never per row.
    final ACDResolvedDesign design = ACDDesign.resolve(context, widget.design);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.showSearchBox) _buildSearchField(context, design),
        Expanded(child: _buildBody(context, _state, design)),
        if (widget.multiple && widget.showConfirmCancelButtons)
          _buildConfirmCancelRow(context, design),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, ACDResolvedDesign design) {
    if (design.isCupertino) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: ACDAdaptiveTextField(
          design: design,
          search: true,
          controller: _searchController,
          decoration: InputDecoration(
            hintText:
                widget.searchHint ?? ACDDesignScope.stringsOf(context).search,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: acdEnsureMaterial(
        context,
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText:
                widget.searchHint ??
                ACDDesignScope.stringsOf(context).searchHint,
            prefixIcon: Icon(widget.searchIcon),
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
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ACDSearchState<T> state,
    ACDResolvedDesign design,
  ) {
    return switch (state) {
      ACDSearchIdle<T> s => _buildList(context, s.items, design),
      ACDSearchLoading<T>() =>
        widget.loadingBuilder?.call(context) ??
            Center(
              child: ACDAdaptiveProgress(
                design: design,
                semanticsLabel: ACDDesignScope.stringsOf(context).loading,
              ),
            ),
      ACDSearchLoaded<T> s => _buildList(context, s.items, design),
      ACDSearchEmpty<T> s =>
        widget.emptyBuilder?.call(context, s.query) ??
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ACDDesignScope.stringsOf(context).noResultsFor(s.query)),
                  if (widget.onCreate != null && s.query.isNotEmpty)
                    _buildCreateRow(context, s.query, design),
                ],
              ),
            ),
      ACDSearchError<T> s =>
        widget.errorBuilder?.call(context, s.error) ??
            Center(child: Text(ACDDesignScope.stringsOf(context).errorMessage)),
    };
  }

  Widget _buildList(
    BuildContext context,
    List<T> items,
    ACDResolvedDesign design,
  ) {
    final bool showLoadMoreRow = _paginating && _hasMore;
    final TextStyle labelStyle = TextStyle(
      color: widget.color,
      fontSize: widget.fontSize,
      fontWeight: widget.fontWeight,
      fontFamily: widget.fontFamily,
    ).merge(widget.style);
    // Rows: an optional select-all row, then items (under group headers
    // when groupBy is set).
    final List<Object> entries = <Object>[
      if (widget.multiple && widget.showSelectAll && items.isNotEmpty)
        const _SelectAllEntry(),
      ..._groupedEntries(items),
    ];
    // The list always fills an Expanded slot, so it doesn't need to
    // shrink-wrap (which forces laying out every row up front).
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: widget.physics,
      controller: _paginating ? _paginationController : widget.controller,
      itemCount: entries.length + (showLoadMoreRow ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          if (_loadMoreFailed) {
            final ACDStrings strings = ACDDesignScope.stringsOf(context);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: ACDAdaptiveTappable(
                  design: design,
                  onTap: () {
                    setState(() => _loadMoreFailed = false);
                    _loadPage(query: _searchController.text, reset: false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      '${strings.errorMessage} ${strings.retry}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return widget.loadMoreBuilder?.call(context) ??
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ACDAdaptiveProgress(
                    design: design,
                    size: 20,
                    strokeWidth: 2,
                  ),
                ),
              );
        }
        final Object entry = entries[index];
        if (entry is _SelectAllEntry) {
          return _buildSelectAllRow(context, items, design);
        }
        if (entry is _GroupHeaderEntry) {
          return _buildGroupHeader(context, entry.title, design);
        }
        final T item = (entry as _ItemEntry<T>).item;
        final selected = _isSelected(item);
        final disabled =
            (widget.isDisabledItem?.call(item) ?? false) ||
            (!selected && _atMaxSelection);
        final onTap = disabled ? null : () => _handleTap(item);
        if (widget.itemBuilder != null) {
          return Semantics(
            selected: selected,
            child: Opacity(
              opacity: disabled ? 0.4 : 1.0,
              child: ACDAdaptiveTappable(
                design: design,
                onTap: onTap,
                child: widget.itemBuilder!(context, item, selected),
              ),
            ),
          );
        }
        final Widget title = Text(_labelOf(item), style: labelStyle);
        if (design.isCupertino) {
          // iOS lists mark selection with a trailing checkmark (single) or
          // a leading checkbox (multi) — not radio buttons.
          return ACDAdaptiveListTile(
            design: design,
            enabled: !disabled,
            selected: selected,
            backgroundColor: widget.tileColor,
            onTap: onTap,
            leading: widget.multiple
                ? ACDAdaptiveCheckbox(
                    design: design,
                    value: selected,
                    activeColor: widget.checkboxActiveColor,
                    onChanged: disabled ? null : (_) => _handleTap(item),
                  )
                : null,
            trailing: !widget.multiple && selected
                ? Icon(ACDIcon.check.of(design), size: 20)
                : null,
            title: title,
          );
        }
        return Semantics(
          selected: selected,
          child: Opacity(
            opacity: disabled ? 0.4 : 1.0,
            child: acdEnsureMaterial(
              context,
              Material(
                color: widget.tileColor ?? acdMaterialSurface(context),
                child: ListTile(
                  onTap: onTap,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  shape: widget.borderRadius == null
                      ? null
                      : RoundedRectangleBorder(
                          borderRadius: widget.borderRadius!,
                        ),
                  leading: widget.multiple
                      ? Checkbox(
                          value: selected,
                          activeColor: widget.checkboxActiveColor,
                          onChanged: disabled ? null : (_) => _handleTap(item),
                        )
                      : null,
                  trailing: !widget.multiple && selected
                      ? const Icon(Icons.check)
                      : null,
                  title: title,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Object> _groupedEntries(List<T> items) {
    final String Function(T item)? groupBy = widget.groupBy;
    if (groupBy == null) {
      return [for (final T item in items) _ItemEntry<T>(item)];
    }
    // Group in first-appearance order (a LinkedHashMap keeps insertion).
    final Map<String, List<T>> groups = <String, List<T>>{};
    for (final T item in items) {
      groups.putIfAbsent(groupBy(item), () => <T>[]).add(item);
    }
    return [
      for (final MapEntry<String, List<T>> g in groups.entries) ...[
        _GroupHeaderEntry(g.key),
        for (final T item in g.value) _ItemEntry<T>(item),
      ],
    ];
  }

  void _commitIfNoConfirm() {
    if (!widget.showConfirmCancelButtons) {
      widget.onMultipleItemsChange?.call(_selected.toList());
    }
  }

  Widget _buildSelectAllRow(
    BuildContext context,
    List<T> items,
    ACDResolvedDesign design,
  ) {
    final List<T> selectable = items
        .where((T i) => !(widget.isDisabledItem?.call(i) ?? false))
        .toList();
    final bool all =
        selectable.isNotEmpty && selectable.every((T i) => _isSelected(i));
    void toggle() {
      setState(() {
        if (all) {
          for (final T i in selectable) {
            final T? existing = _findInSelected(i);
            if (existing != null) _selected.remove(existing);
          }
        } else {
          for (final T i in selectable) {
            if (_atMaxSelection) break;
            if (_findInSelected(i) == null) _selected.add(i);
          }
        }
      });
      _commitIfNoConfirm();
    }

    final String label = ACDDesignScope.stringsOf(context).selectAll;
    if (design.isCupertino) {
      return ACDAdaptiveListTile(
        design: design,
        enabled: true,
        selected: all,
        backgroundColor: widget.tileColor,
        onTap: toggle,
        leading: ACDAdaptiveCheckbox(
          design: design,
          value: all,
          activeColor: widget.checkboxActiveColor,
          onChanged: (_) => toggle(),
        ),
        title: Text(label),
      );
    }
    return acdEnsureMaterial(
      context,
      Material(
        color: widget.tileColor ?? acdMaterialSurface(context),
        child: ListTile(
          onTap: toggle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          leading: Checkbox(
            value: all,
            activeColor: widget.checkboxActiveColor,
            onChanged: (_) => toggle(),
          ),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    String title,
    ACDResolvedDesign design,
  ) {
    final TextStyle style = design.isCupertino
        ? TextStyle(
            fontSize: 13,
            color: ACDDesignTokens.of(context, design).onSurfaceVariant,
          )
        : (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
              .copyWith(color: Theme.of(context).colorScheme.primary);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          design.isCupertino ? title.toUpperCase() : title,
          style: style,
        ),
      ),
    );
  }

  Widget _buildCreateRow(
    BuildContext context,
    String query,
    ACDResolvedDesign design,
  ) {
    final String label = '${ACDDesignScope.stringsOf(context).create} "$query"';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ACDAdaptiveTappable(
        design: design,
        onTap: _creating ? null : () => _create(query),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_creating)
                ACDAdaptiveProgress(design: design, size: 16, strokeWidth: 2)
              else
                Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _create(String query) async {
    setState(() => _creating = true);
    final T? created;
    try {
      created = await widget.onCreate!(query);
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _creating = false;
          _state = ACDSearchError<T>(error, query, stackTrace);
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _creating = false);
    if (created == null) return;
    _cache.clear(); // the new item may belong in earlier results
    if (widget.multiple) {
      setState(() {
        if (!_atMaxSelection) _selected.add(created as T);
        _state = ACDSearchLoaded<T>(<T>[created as T]);
      });
      _commitIfNoConfirm();
    } else {
      _handleTap(created);
    }
  }

  Widget _buildConfirmCancelRow(
    BuildContext context,
    ACDResolvedDesign design,
  ) {
    void confirm() {
      widget.onMultipleItemsChange?.call(_selected.toList());
      widget.dialogDismiss?.call();
    }

    final ACDStrings strings = ACDDesignScope.stringsOf(context);

    if (design.isCupertino) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            onPressed: widget.dialogDismiss,
            child: Text(
              widget.cancelText ?? strings.cancel,
              style: widget.cancelColor == null
                  ? null
                  : TextStyle(color: widget.cancelColor),
            ),
          ),
          CupertinoButton(
            onPressed: confirm,
            child: Text(
              widget.confirmText ?? strings.ok,
              style: TextStyle(
                color: widget.confirmColor,
                fontWeight: widget.confirmFontWeight ?? FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
    return acdEnsureMaterial(
      context,
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: widget.dialogDismiss,
            style: TextButton.styleFrom(
              foregroundColor: widget.cancelColor ?? Colors.grey,
            ),
            child: Text(widget.cancelText ?? strings.cancel),
          ),
          TextButton(
            onPressed: confirm,
            style: TextButton.styleFrom(
              foregroundColor: widget.confirmColor ?? Colors.teal,
              textStyle: TextStyle(fontWeight: widget.confirmFontWeight),
            ),
            child: Text(widget.confirmText ?? strings.ok),
          ),
        ],
      ),
    );
  }
}

/// The select-all row in [ACDSearchableListTile]'s list.
class _SelectAllEntry {
  const _SelectAllEntry();
}

/// A section header row (from `groupBy`).
class _GroupHeaderEntry {
  const _GroupHeaderEntry(this.title);
  final String title;
}

/// A data row. Wrapped so a `T` of `String` can't be mistaken for a header.
class _ItemEntry<T> {
  const _ItemEntry(this.item);
  final T item;
}
