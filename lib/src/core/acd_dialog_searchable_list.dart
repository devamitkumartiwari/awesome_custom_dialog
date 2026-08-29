import 'package:flutter/material.dart';

import 'acd_dialog.dart';
import '../list_tile/acd_searchable_list_tile.dart';

/// Adds `searchableList()` and `multiSearchableList()` to [ACDDialog] for a
/// filterable, generic list — a single or multi-select picker with local
/// filtering or an optional async remote search.
extension ACDDialogSearchableList on ACDDialog {
  /// Adds a filterable single-select list built from [items]. Returns this
  /// dialog for chaining.
  ///
  /// Filters locally as the user types, unless [onFind] is provided, in
  /// which case a non-empty query is delegated to it exclusively (for
  /// remote/API-backed search) and [items] is only shown before typing.
  ACDDialog searchableList<T>({
    required List<T> items,
    String Function(T item)? itemAsString,
    Widget Function(BuildContext context, T item, bool selected)? itemBuilder,
    Future<List<T>> Function(String keyword)? onFind,
    Duration searchDebounce = const Duration(milliseconds: 350),
    T? initialValue,
    void Function(T item)? onChange,
    bool isClickAutoDismiss = true,
    String? searchHint,
    bool showSearchBox = true,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context, String query)? emptyBuilder,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    double? height,
    EdgeInsets? padding,
    Color tileColor = Colors.white,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    TextStyle? style,
    Color? searchFillColor,
    Color? searchBorderColor,
    double searchBorderRadius = 4.0,
    IconData searchIcon = Icons.search,
    BorderRadius? borderRadius,
    ScrollPhysics? physics,
    ScrollController? controller,
    TextEditingController? searchController,
    bool Function(T a, T b)? compareFn,
    bool Function(T item)? isDisabledItem,
    List<T>? favoriteItems,
    Future<List<T>> Function(String keyword, int page)? onFindPaged,
    Widget Function(BuildContext context)? loadMoreBuilder,
  }) {
    if (context == null) return this;
    final size = MediaQuery.of(context!).size;
    return widget(
      Container(
        height: height,
        padding: padding,
        constraints: BoxConstraints(
          minHeight: size.height * .1,
          minWidth: size.width * .1,
          maxHeight: size.height * .5,
        ),
        child: ACDSearchableListTile<T>(
          items: items,
          multiple: false,
          itemAsString: itemAsString,
          itemBuilder: itemBuilder,
          onFind: onFind,
          searchDebounce: searchDebounce,
          initialValue: initialValue,
          onChange: onChange,
          isClickAutoDismiss: isClickAutoDismiss,
          showSearchBox: showSearchBox,
          searchHint: searchHint,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          errorBuilder: errorBuilder,
          tileColor: tileColor,
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          style: style,
          searchFillColor: searchFillColor,
          searchBorderColor: searchBorderColor,
          searchBorderRadius: searchBorderRadius,
          searchIcon: searchIcon,
          borderRadius: borderRadius,
          physics: physics,
          controller: controller,
          searchController: searchController,
          dialogDismiss: dismiss,
          compareFn: compareFn,
          isDisabledItem: isDisabledItem,
          favoriteItems: favoriteItems,
          onFindPaged: onFindPaged,
          loadMoreBuilder: loadMoreBuilder,
        ),
      ),
    );
  }

  /// Adds a filterable multi-select list built from [items]. Returns this
  /// dialog for chaining.
  ///
  /// Unlike [searchableList], selection is cumulative — [onMultipleItemsChange]
  /// fires only when the user taps the confirm button (set
  /// [showConfirmCancelButtons] to `false` to hide the built-in row and
  /// compose your own confirm action instead).
  ///
  /// A custom [T] must implement `==`/`hashCode` consistent with value
  /// identity, since the current selection is tracked in a `Set<T>` — or
  /// pass [compareFn] to use custom equality instead.
  ACDDialog multiSearchableList<T>({
    required List<T> items,
    String Function(T item)? itemAsString,
    Widget Function(BuildContext context, T item, bool selected)? itemBuilder,
    Future<List<T>> Function(String keyword)? onFind,
    Duration searchDebounce = const Duration(milliseconds: 350),
    List<T>? initialValues,
    void Function(List<T> items)? onMultipleItemsChange,
    bool showConfirmCancelButtons = true,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    FontWeight? confirmFontWeight,
    Color? checkboxActiveColor,
    String? searchHint,
    bool showSearchBox = true,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context, String query)? emptyBuilder,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    double? height,
    EdgeInsets? padding,
    Color tileColor = Colors.white,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    TextStyle? style,
    Color? searchFillColor,
    Color? searchBorderColor,
    double searchBorderRadius = 4.0,
    IconData searchIcon = Icons.search,
    BorderRadius? borderRadius,
    ScrollPhysics? physics,
    ScrollController? controller,
    TextEditingController? searchController,
    bool Function(T a, T b)? compareFn,
    bool Function(T item)? isDisabledItem,
    List<T>? favoriteItems,
    Future<List<T>> Function(String keyword, int page)? onFindPaged,
    Widget Function(BuildContext context)? loadMoreBuilder,
  }) {
    if (context == null) return this;
    final size = MediaQuery.of(context!).size;
    return widget(
      Container(
        height: height,
        padding: padding,
        constraints: BoxConstraints(
          minHeight: size.height * .1,
          minWidth: size.width * .1,
          maxHeight: size.height * .5,
        ),
        child: ACDSearchableListTile<T>(
          items: items,
          multiple: true,
          itemAsString: itemAsString,
          itemBuilder: itemBuilder,
          onFind: onFind,
          searchDebounce: searchDebounce,
          initialValues: initialValues,
          onMultipleItemsChange: onMultipleItemsChange,
          showConfirmCancelButtons: showConfirmCancelButtons,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmColor: confirmColor,
          cancelColor: cancelColor,
          confirmFontWeight: confirmFontWeight,
          checkboxActiveColor: checkboxActiveColor,
          showSearchBox: showSearchBox,
          searchHint: searchHint,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          errorBuilder: errorBuilder,
          tileColor: tileColor,
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          style: style,
          searchFillColor: searchFillColor,
          searchBorderColor: searchBorderColor,
          searchBorderRadius: searchBorderRadius,
          searchIcon: searchIcon,
          borderRadius: borderRadius,
          physics: physics,
          controller: controller,
          searchController: searchController,
          dialogDismiss: dismiss,
          compareFn: compareFn,
          isDisabledItem: isDisabledItem,
          favoriteItems: favoriteItems,
          onFindPaged: onFindPaged,
          loadMoreBuilder: loadMoreBuilder,
        ),
      ),
    );
  }
}
