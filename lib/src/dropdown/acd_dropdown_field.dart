import 'package:flutter/material.dart';

import '../core/acd_dialog.dart';
import '../core/acd_dialog_searchable_list.dart';
import 'acd_dropdown_mode.dart';
import '../core/acd_gravity.dart';
import '../list_tile/acd_searchable_list_tile.dart';

/// A searchable dropdown [FormField] — the inline, `Form`-compatible field
/// missing from `ACDDialog.searchableList()`. Tapping it opens the same
/// filterable list (single-select) as a dialog, bottom sheet, or anchored
/// menu depending on [mode].
///
/// ```dart
/// ACDDropdownField<String>(
///   items: countries,
///   decoration: const InputDecoration(labelText: 'Country'),
///   validator: (v) => v == null ? 'Required' : null,
///   onChanged: (v) => debugPrint('Picked $v'),
/// )
/// ```
///
/// For multi-select, use [ACDMultiDropdownField].
class ACDDropdownField<T> extends FormField<T> {
  /// Creates an [ACDDropdownField].
  ACDDropdownField({
    super.key,
    required this.items,
    this.itemAsString,
    this.itemBuilder,
    this.dropdownBuilder,
    this.onFind,
    this.searchDebounce = const Duration(milliseconds: 350),
    super.initialValue,
    this.onChanged,
    this.mode = ACDDropdownMode.dialog,
    this.decoration = const InputDecoration(),
    this.showClearButton = false,
    this.clearIcon = Icons.clear,
    this.searchHint,
    this.showSearchBox = true,
    this.searchLoadingBuilder,
    this.searchEmptyBuilder,
    this.searchErrorBuilder,
    this.popupHeight,
    this.popupWidth,
    this.tileColor = Colors.white,
    this.itemTextColor,
    this.itemFontSize,
    this.itemFontWeight,
    this.itemFontFamily,
    this.itemStyle,
    this.searchFillColor,
    this.searchBorderColor,
    this.searchBorderRadius = 4.0,
    this.compareFn,
    this.isDisabledItem,
    this.favoriteItems,
    this.onFindPaged,
    this.loadMoreBuilder,
    super.validator,
    super.onSaved,
    super.enabled,
    super.autovalidateMode,
  }) : super(
         builder: (FormFieldState<T> field) {
           return Builder(
             builder: (innerContext) {
               final T? value = field.value;
               final bool hasValue = value != null;
               return InputDecorator(
                 decoration: decoration.copyWith(
                   enabled: enabled,
                   errorText: field.errorText,
                 ),
                 isEmpty: !hasValue,
                 child: GestureDetector(
                   behavior: HitTestBehavior.opaque,
                   onTap: enabled
                       ? () => _openPopup<T>(
                           context: innerContext,
                           mode: mode,
                           field: field,
                           multiple: false,
                           items: items,
                           itemAsString: itemAsString,
                           itemBuilder: itemBuilder,
                           onFind: onFind,
                           searchDebounce: searchDebounce,
                           searchHint: searchHint,
                           showSearchBox: showSearchBox,
                           searchLoadingBuilder: searchLoadingBuilder,
                           searchEmptyBuilder: searchEmptyBuilder,
                           searchErrorBuilder: searchErrorBuilder,
                           popupHeight: popupHeight,
                           popupWidth: popupWidth,
                           tileColor: tileColor,
                           itemTextColor: itemTextColor,
                           itemFontSize: itemFontSize,
                           itemFontWeight: itemFontWeight,
                           itemFontFamily: itemFontFamily,
                           itemStyle: itemStyle,
                           searchFillColor: searchFillColor,
                           searchBorderColor: searchBorderColor,
                           searchBorderRadius: searchBorderRadius,
                           compareFn: compareFn,
                           isDisabledItem: isDisabledItem,
                           favoriteItems: favoriteItems,
                           onFindPaged: onFindPaged,
                           loadMoreBuilder: loadMoreBuilder,
                           onSingleChange: (item) {
                             field.didChange(item);
                             onChanged?.call(item);
                           },
                         )
                       : null,
                   child: Row(
                     children: [
                       Expanded(
                         child:
                             dropdownBuilder?.call(innerContext, value) ??
                             Text(
                               hasValue
                                   ? (itemAsString?.call(value) ??
                                         value.toString())
                                   : '',
                               overflow: TextOverflow.ellipsis,
                             ),
                       ),
                       if (showClearButton && hasValue && enabled)
                         InkWell(
                           borderRadius: BorderRadius.circular(12),
                           onTap: () {
                             field.didChange(null);
                             onChanged?.call(null);
                           },
                           child: Padding(
                             padding: const EdgeInsets.all(2),
                             child: Icon(clearIcon, size: 18),
                           ),
                         ),
                       const SizedBox(width: 4),
                       Icon(
                         Icons.arrow_drop_down,
                         color: enabled
                             ? null
                             : Theme.of(innerContext).disabledColor,
                       ),
                     ],
                   ),
                 ),
               );
             },
           );
         },
       );

  /// The base dataset shown before any search, and searched locally when
  /// [onFind] isn't set.
  final List<T> items;

  /// Extracts the display label for an item. Defaults to `item.toString()`.
  final String Function(T item)? itemAsString;

  /// Custom row builder for the popup list. Falls back to a plain
  /// `ListTile` using [itemAsString] when omitted.
  final Widget Function(BuildContext context, T item, bool selected)?
  itemBuilder;

  /// Custom builder for the closed-state (selected value) display. Falls
  /// back to `Text(itemAsString(value))` when omitted.
  final Widget Function(BuildContext context, T? value)? dropdownBuilder;

  /// Async remote search. When set, a non-empty query is delegated to this
  /// exclusively — [items] is only used for the idle (pre-search) state.
  final Future<List<T>> Function(String keyword)? onFind;

  /// How long to wait after the user stops typing before searching.
  final Duration searchDebounce;

  /// Called whenever the selection changes (including clearing to `null`).
  final void Function(T? item)? onChanged;

  /// How the popup is presented when the field is tapped.
  final ACDDropdownMode mode;

  /// Decoration for the closed-state field — same as `TextFormField`'s,
  /// so label/hint/border/icons all work as expected.
  final InputDecoration decoration;

  /// Shows a trailing button to clear the current selection.
  final bool showClearButton;

  /// Icon for the clear button.
  final IconData clearIcon;

  /// Popup search field hint text.
  final String? searchHint;

  /// Whether the popup shows a search field at all.
  final bool showSearchBox;

  /// Shown while a search is in flight. Defaults to a centered spinner.
  final Widget Function(BuildContext context)? searchLoadingBuilder;

  /// Shown when a search returns no results. Defaults to a centered
  /// "No results" message.
  final Widget Function(BuildContext context, String query)? searchEmptyBuilder;

  /// Shown when [onFind] throws. Defaults to a centered error message.
  final Widget Function(BuildContext context, Object error)? searchErrorBuilder;

  /// Fixed height for the popup. Defaults to 420 for dialog/bottomSheet
  /// modes, 320 for menu mode.
  final double? popupHeight;

  /// Fixed width for the popup in [ACDDropdownMode.menu]. Defaults to the
  /// field's own width.
  final double? popupWidth;

  /// Background color of each row in the popup.
  final Color tileColor;

  /// Row text color in the popup.
  final Color? itemTextColor;

  /// Row text size in the popup.
  final double? itemFontSize;

  /// Row text weight in the popup.
  final FontWeight? itemFontWeight;

  /// Row text font family in the popup.
  final String? itemFontFamily;

  /// Full row text style control in the popup.
  final TextStyle? itemStyle;

  /// Fill color of the popup's search field.
  final Color? searchFillColor;

  /// Border color of the popup's search field.
  final Color? searchBorderColor;

  /// Corner radius of the popup's search field.
  final double searchBorderRadius;

  /// Custom equality for selection tracking, used in place of `==`. Lets a
  /// [T] without a value-based `==`/`hashCode` override still highlight
  /// correctly.
  final bool Function(T a, T b)? compareFn;

  /// Marks individual rows as non-interactive.
  final bool Function(T item)? isDisabledItem;

  /// Shown pinned at the top of the idle (pre-search) popup list.
  final List<T>? favoriteItems;

  /// Paginated async search/load — see `ACDSearchableListTile.onFindPaged`.
  /// When set, supersedes both [items] and [onFind].
  final Future<List<T>> Function(String keyword, int page)? onFindPaged;

  /// Trailing row shown while more of [onFindPaged]'s pages remain to load.
  final Widget Function(BuildContext context)? loadMoreBuilder;
}

/// The multi-select counterpart to [ACDDropdownField] — a `FormField` whose
/// value is the set of selected items, confirmed via the popup's OK button.
class ACDMultiDropdownField<T> extends FormField<List<T>> {
  /// Creates an [ACDMultiDropdownField].
  ACDMultiDropdownField({
    super.key,
    required this.items,
    this.itemAsString,
    this.itemBuilder,
    this.dropdownBuilder,
    this.onFind,
    this.searchDebounce = const Duration(milliseconds: 350),
    List<T> initialValue = const [],
    this.onChanged,
    this.mode = ACDDropdownMode.dialog,
    this.decoration = const InputDecoration(),
    this.showClearButton = false,
    this.clearIcon = Icons.clear,
    this.showConfirmCancelButtons = true,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.cancelColor,
    this.confirmFontWeight,
    this.checkboxActiveColor,
    this.searchHint,
    this.showSearchBox = true,
    this.searchLoadingBuilder,
    this.searchEmptyBuilder,
    this.searchErrorBuilder,
    this.popupHeight,
    this.popupWidth,
    this.tileColor = Colors.white,
    this.itemTextColor,
    this.itemFontSize,
    this.itemFontWeight,
    this.itemFontFamily,
    this.itemStyle,
    this.searchFillColor,
    this.searchBorderColor,
    this.searchBorderRadius = 4.0,
    this.compareFn,
    this.isDisabledItem,
    this.favoriteItems,
    this.onFindPaged,
    this.loadMoreBuilder,
    super.validator,
    super.onSaved,
    super.enabled,
    super.autovalidateMode,
  }) : super(
         initialValue: initialValue,
         builder: (FormFieldState<List<T>> field) {
           return Builder(
             builder: (innerContext) {
               final List<T> value = field.value ?? const [];
               final bool hasValue = value.isNotEmpty;
               return InputDecorator(
                 decoration: decoration.copyWith(
                   enabled: enabled,
                   errorText: field.errorText,
                 ),
                 isEmpty: !hasValue,
                 child: GestureDetector(
                   behavior: HitTestBehavior.opaque,
                   onTap: enabled
                       ? () => _openPopup<T>(
                           context: innerContext,
                           mode: mode,
                           field: field,
                           multiple: true,
                           items: items,
                           itemAsString: itemAsString,
                           itemBuilder: itemBuilder,
                           onFind: onFind,
                           searchDebounce: searchDebounce,
                           searchHint: searchHint,
                           showSearchBox: showSearchBox,
                           searchLoadingBuilder: searchLoadingBuilder,
                           searchEmptyBuilder: searchEmptyBuilder,
                           searchErrorBuilder: searchErrorBuilder,
                           popupHeight: popupHeight,
                           popupWidth: popupWidth,
                           tileColor: tileColor,
                           itemTextColor: itemTextColor,
                           itemFontSize: itemFontSize,
                           itemFontWeight: itemFontWeight,
                           itemFontFamily: itemFontFamily,
                           itemStyle: itemStyle,
                           searchFillColor: searchFillColor,
                           searchBorderColor: searchBorderColor,
                           searchBorderRadius: searchBorderRadius,
                           compareFn: compareFn,
                           isDisabledItem: isDisabledItem,
                           favoriteItems: favoriteItems,
                           onFindPaged: onFindPaged,
                           loadMoreBuilder: loadMoreBuilder,
                           initialValues: value,
                           showConfirmCancelButtons: showConfirmCancelButtons,
                           confirmText: confirmText,
                           cancelText: cancelText,
                           confirmColor: confirmColor,
                           cancelColor: cancelColor,
                           confirmFontWeight: confirmFontWeight,
                           checkboxActiveColor: checkboxActiveColor,
                           onMultiChange: (items) {
                             field.didChange(items);
                             onChanged?.call(items);
                           },
                         )
                       : null,
                   child: Row(
                     children: [
                       Expanded(
                         child:
                             dropdownBuilder?.call(innerContext, value) ??
                             Text(
                               hasValue
                                   ? value
                                         .map(
                                           (item) =>
                                               itemAsString?.call(item) ??
                                               item.toString(),
                                         )
                                         .join(', ')
                                   : '',
                               overflow: TextOverflow.ellipsis,
                             ),
                       ),
                       if (showClearButton && hasValue && enabled)
                         InkWell(
                           borderRadius: BorderRadius.circular(12),
                           onTap: () {
                             field.didChange(const []);
                             onChanged?.call(const []);
                           },
                           child: Padding(
                             padding: const EdgeInsets.all(2),
                             child: Icon(clearIcon, size: 18),
                           ),
                         ),
                       const SizedBox(width: 4),
                       Icon(
                         Icons.arrow_drop_down,
                         color: enabled
                             ? null
                             : Theme.of(innerContext).disabledColor,
                       ),
                     ],
                   ),
                 ),
               );
             },
           );
         },
       );

  /// The base dataset shown before any search, and searched locally when
  /// [onFind] isn't set.
  final List<T> items;

  /// Extracts the display label for an item. Defaults to `item.toString()`.
  final String Function(T item)? itemAsString;

  /// Custom row builder for the popup list. Falls back to a plain
  /// `ListTile` using [itemAsString] when omitted.
  final Widget Function(BuildContext context, T item, bool selected)?
  itemBuilder;

  /// Custom builder for the closed-state (selected values) display. Falls
  /// back to a comma-joined `itemAsString` list when omitted.
  final Widget Function(BuildContext context, List<T> values)? dropdownBuilder;

  /// Async remote search. When set, a non-empty query is delegated to this
  /// exclusively — [items] is only used for the idle (pre-search) state.
  final Future<List<T>> Function(String keyword)? onFind;

  /// How long to wait after the user stops typing before searching.
  final Duration searchDebounce;

  /// Called with the confirmed selection.
  final void Function(List<T> items)? onChanged;

  /// How the popup is presented when the field is tapped.
  final ACDDropdownMode mode;

  /// Decoration for the closed-state field.
  final InputDecoration decoration;

  /// Shows a trailing button to clear the current selection.
  final bool showClearButton;

  /// Icon for the clear button.
  final IconData clearIcon;

  /// Whether to show the built-in Confirm/Cancel row in the popup.
  final bool showConfirmCancelButtons;

  /// Confirm button label.
  final String confirmText;

  /// Cancel button label.
  final String cancelText;

  /// Confirm button color.
  final Color? confirmColor;

  /// Cancel button color.
  final Color? cancelColor;

  /// Confirm button font weight.
  final FontWeight? confirmFontWeight;

  /// Color of a checked row's checkbox.
  final Color? checkboxActiveColor;

  /// Popup search field hint text.
  final String? searchHint;

  /// Whether the popup shows a search field at all.
  final bool showSearchBox;

  /// Shown while a search is in flight. Defaults to a centered spinner.
  final Widget Function(BuildContext context)? searchLoadingBuilder;

  /// Shown when a search returns no results. Defaults to a centered
  /// "No results" message.
  final Widget Function(BuildContext context, String query)? searchEmptyBuilder;

  /// Shown when [onFind] throws. Defaults to a centered error message.
  final Widget Function(BuildContext context, Object error)? searchErrorBuilder;

  /// Fixed height for the popup. Defaults to 420 for dialog/bottomSheet
  /// modes, 320 for menu mode.
  final double? popupHeight;

  /// Fixed width for the popup in [ACDDropdownMode.menu]. Defaults to the
  /// field's own width.
  final double? popupWidth;

  /// Background color of each row in the popup.
  final Color tileColor;

  /// Row text color in the popup.
  final Color? itemTextColor;

  /// Row text size in the popup.
  final double? itemFontSize;

  /// Row text weight in the popup.
  final FontWeight? itemFontWeight;

  /// Row text font family in the popup.
  final String? itemFontFamily;

  /// Full row text style control in the popup.
  final TextStyle? itemStyle;

  /// Fill color of the popup's search field.
  final Color? searchFillColor;

  /// Border color of the popup's search field.
  final Color? searchBorderColor;

  /// Corner radius of the popup's search field.
  final double searchBorderRadius;

  /// Custom equality for selection tracking, used in place of `==`. Lets a
  /// [T] without a value-based `==`/`hashCode` override still track
  /// selection correctly.
  final bool Function(T a, T b)? compareFn;

  /// Marks individual rows as non-interactive.
  final bool Function(T item)? isDisabledItem;

  /// Shown pinned at the top of the idle (pre-search) popup list.
  final List<T>? favoriteItems;

  /// Paginated async search/load — see `ACDSearchableListTile.onFindPaged`.
  /// When set, supersedes both [items] and [onFind].
  final Future<List<T>> Function(String keyword, int page)? onFindPaged;

  /// Trailing row shown while more of [onFindPaged]'s pages remain to load.
  final Widget Function(BuildContext context)? loadMoreBuilder;
}

// ── Shared popup presentation ─────────────────────────────────────────────
//
// Both ACDDropdownField and ACDMultiDropdownField delegate here: dialog and
// bottomSheet modes reuse the existing ACDDialog.searchableList()/
// multiSearchableList() extensions untouched (just different ACDGravity);
// menu mode anchors the same ACDSearchableListTile content under the field
// via showMenu(), which already handles flipping above the field and
// clamping to the screen — no bespoke overlay/positioning code needed.
void _openPopup<T>({
  required BuildContext context,
  required ACDDropdownMode mode,
  required FormFieldState<Object?> field,
  required bool multiple,
  required List<T> items,
  required String Function(T item)? itemAsString,
  required Widget Function(BuildContext context, T item, bool selected)?
  itemBuilder,
  required Future<List<T>> Function(String keyword)? onFind,
  required Duration searchDebounce,
  required String? searchHint,
  required bool showSearchBox,
  required Widget Function(BuildContext context)? searchLoadingBuilder,
  required Widget Function(BuildContext context, String query)?
  searchEmptyBuilder,
  required Widget Function(BuildContext context, Object error)?
  searchErrorBuilder,
  required double? popupHeight,
  required double? popupWidth,
  required Color tileColor,
  required Color? itemTextColor,
  required double? itemFontSize,
  required FontWeight? itemFontWeight,
  required String? itemFontFamily,
  required TextStyle? itemStyle,
  required Color? searchFillColor,
  required Color? searchBorderColor,
  required double searchBorderRadius,
  required bool Function(T a, T b)? compareFn,
  required bool Function(T item)? isDisabledItem,
  required List<T>? favoriteItems,
  required Future<List<T>> Function(String keyword, int page)? onFindPaged,
  required Widget Function(BuildContext context)? loadMoreBuilder,
  void Function(T? item)? onSingleChange,
  void Function(List<T> items)? onMultiChange,
  List<T>? initialValues,
  bool showConfirmCancelButtons = true,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
  Color? confirmColor,
  Color? cancelColor,
  FontWeight? confirmFontWeight,
  Color? checkboxActiveColor,
}) {
  switch (mode) {
    case ACDDropdownMode.dialog:
    case ACDDropdownMode.bottomSheet:
      final dialog = ACDDialog().build(context)
        ..borderRadius = 16
        ..height = popupHeight ?? 420;
      if (mode == ACDDropdownMode.bottomSheet) {
        dialog
          ..gravity = ACDGravity.bottom
          ..width = double.infinity
          ..cornerRadius = const BorderRadius.vertical(
            top: Radius.circular(16),
          );
      }
      if (multiple) {
        dialog.multiSearchableList<T>(
          items: items,
          itemAsString: itemAsString,
          itemBuilder: itemBuilder,
          onFind: onFind,
          searchDebounce: searchDebounce,
          initialValues: initialValues,
          onMultipleItemsChange: onMultiChange,
          showConfirmCancelButtons: showConfirmCancelButtons,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmColor: confirmColor,
          cancelColor: cancelColor,
          confirmFontWeight: confirmFontWeight,
          checkboxActiveColor: checkboxActiveColor,
          searchHint: searchHint,
          showSearchBox: showSearchBox,
          loadingBuilder: searchLoadingBuilder,
          emptyBuilder: searchEmptyBuilder,
          errorBuilder: searchErrorBuilder,
          tileColor: tileColor,
          color: itemTextColor,
          fontSize: itemFontSize,
          fontWeight: itemFontWeight,
          fontFamily: itemFontFamily,
          style: itemStyle,
          searchFillColor: searchFillColor,
          searchBorderColor: searchBorderColor,
          searchBorderRadius: searchBorderRadius,
          compareFn: compareFn,
          isDisabledItem: isDisabledItem,
          favoriteItems: favoriteItems,
          onFindPaged: onFindPaged,
          loadMoreBuilder: loadMoreBuilder,
        );
      } else {
        dialog.searchableList<T>(
          items: items,
          itemAsString: itemAsString,
          itemBuilder: itemBuilder,
          onFind: onFind,
          searchDebounce: searchDebounce,
          initialValue: field.value as T?,
          onChange: onSingleChange,
          searchHint: searchHint,
          showSearchBox: showSearchBox,
          loadingBuilder: searchLoadingBuilder,
          emptyBuilder: searchEmptyBuilder,
          errorBuilder: searchErrorBuilder,
          tileColor: tileColor,
          color: itemTextColor,
          fontSize: itemFontSize,
          fontWeight: itemFontWeight,
          fontFamily: itemFontFamily,
          style: itemStyle,
          searchFillColor: searchFillColor,
          searchBorderColor: searchBorderColor,
          searchBorderRadius: searchBorderRadius,
          compareFn: compareFn,
          isDisabledItem: isDisabledItem,
          favoriteItems: favoriteItems,
          onFindPaged: onFindPaged,
          loadMoreBuilder: loadMoreBuilder,
        );
      }
      dialog.show();

    case ACDDropdownMode.menu:
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final RenderBox overlayBox =
          Navigator.of(context).overlay!.context.findRenderObject()!
              as RenderBox;
      final Offset topLeft = box.localToGlobal(
        Offset(0, box.size.height),
        ancestor: overlayBox,
      );
      final Offset bottomRight = box.localToGlobal(
        box.size.bottomRight(Offset.zero),
        ancestor: overlayBox,
      );
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlayBox.size,
      );
      final double width = popupWidth ?? box.size.width;
      final double height = popupHeight ?? 320;

      showMenu<void>(
        context: context,
        position: position,
        constraints: BoxConstraints(minWidth: width, maxWidth: width),
        items: [
          PopupMenuItem<void>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: width,
              height: height,
              child: ACDSearchableListTile<T>(
                items: items,
                multiple: multiple,
                itemAsString: itemAsString,
                itemBuilder: itemBuilder,
                onFind: onFind,
                searchDebounce: searchDebounce,
                initialValue: multiple ? null : field.value as T?,
                initialValues: initialValues,
                onChange: onSingleChange,
                onMultipleItemsChange: onMultiChange,
                isClickAutoDismiss: true,
                showConfirmCancelButtons: showConfirmCancelButtons,
                confirmText: confirmText,
                cancelText: cancelText,
                confirmColor: confirmColor,
                cancelColor: cancelColor,
                confirmFontWeight: confirmFontWeight,
                checkboxActiveColor: checkboxActiveColor,
                showSearchBox: showSearchBox,
                searchHint: searchHint,
                loadingBuilder: searchLoadingBuilder,
                emptyBuilder: searchEmptyBuilder,
                errorBuilder: searchErrorBuilder,
                tileColor: tileColor,
                color: itemTextColor,
                fontSize: itemFontSize,
                fontWeight: itemFontWeight,
                fontFamily: itemFontFamily,
                style: itemStyle,
                searchFillColor: searchFillColor,
                searchBorderColor: searchBorderColor,
                searchBorderRadius: searchBorderRadius,
                compareFn: compareFn,
                isDisabledItem: isDisabledItem,
                favoriteItems: favoriteItems,
                onFindPaged: onFindPaged,
                loadMoreBuilder: loadMoreBuilder,
                dialogDismiss: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      );
  }
}
