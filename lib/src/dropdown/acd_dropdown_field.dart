import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../core/acd_dialog.dart';
import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/acd_design_tokens.dart';
import '../design/acd_strings.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
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
    this.clearIcon,
    this.searchHint,
    this.showSearchBox = true,
    this.searchLoadingBuilder,
    this.searchEmptyBuilder,
    this.searchErrorBuilder,
    this.popupHeight,
    this.popupWidth,
    this.tileColor,
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
    this.groupBy,
    this.cacheResults = false,
    this.onCreate,
    this.onFindPaged,
    this.loadMoreBuilder,
    this.design,
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
               return _ACDDropdownBox(
                 design: design,
                 decoration: decoration,
                 errorText: field.errorText,
                 enabled: enabled,
                 isEmpty: !hasValue,
                 valueLabel: hasValue
                     ? (itemAsString?.call(value) ?? value.toString())
                     : '',
                 showClearButton: showClearButton && hasValue,
                 clearIcon: clearIcon,
                 onClear: () {
                   field.didChange(null);
                   onChanged?.call(null);
                 },
                 onOpen: () => _openPopup<T>(
                   context: innerContext,
                   design: design,
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
                   groupBy: groupBy,
                   cacheResults: cacheResults,
                   onCreate: onCreate,
                   maxSelection: null,
                   showSelectAll: false,
                   onFindPaged: onFindPaged,
                   loadMoreBuilder: loadMoreBuilder,
                   onSingleChange: (item) {
                     field.didChange(item);
                     onChanged?.call(item);
                   },
                 ),
                 child: dropdownBuilder?.call(innerContext, value),
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
  final IconData? clearIcon;

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
  final Color? tileColor;

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

  /// Groups popup rows under section headers — see `ACDSearchableListTile.groupBy`.
  final String Function(T item)? groupBy;

  /// Caches `onFind` results per query while the popup is open.
  final bool cacheResults;

  /// Offers a "Create" row when a search finds nothing — see
  /// `ACDSearchableListTile.onCreate`.
  final Future<T?> Function(String query)? onCreate;

  /// Paginated async search/load — see `ACDSearchableListTile.onFindPaged`.
  /// When set, supersedes both [items] and [onFind].
  final Future<List<T>> Function(String keyword, int page)? onFindPaged;

  /// Trailing row shown while more of [onFindPaged]'s pages remain to load.
  final Widget Function(BuildContext context)? loadMoreBuilder;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign]. Applies to
  /// the closed field and the popup.
  final ACDDesign? design;
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
    this.clearIcon,
    this.showConfirmCancelButtons = true,
    this.confirmText,
    this.cancelText,
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
    this.tileColor,
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
    this.groupBy,
    this.cacheResults = false,
    this.onCreate,
    this.maxSelection,
    this.showSelectAll = false,
    this.onFindPaged,
    this.loadMoreBuilder,
    this.design,
    this.displayMode = ACDMultiDisplay.chips,
    this.maxVisibleChips = 3,
    this.chipBuilder,
    super.validator,
    super.onSaved,
    super.enabled,
    super.autovalidateMode,
  }) : assert(maxVisibleChips == null || maxVisibleChips > 0),
       super(
         initialValue: initialValue,
         builder: (FormFieldState<List<T>> field) {
           return Builder(
             builder: (innerContext) {
               final List<T> value = field.value ?? const [];
               final bool hasValue = value.isNotEmpty;
               String label(T item) =>
                   itemAsString?.call(item) ?? item.toString();
               void remove(T item) {
                 final List<T> next = [
                   for (final T v in value)
                     if (!(compareFn?.call(v, item) ?? v == item)) v,
                 ];
                 field.didChange(next);
                 onChanged?.call(next);
                 acdAnnounce(
                   innerContext,
                   ACDDesignScope.stringsOf(innerContext)
                       .itemRemovedAnnouncement(label(item)),
                 );
               }

               final Widget? display =
                   dropdownBuilder?.call(innerContext, value) ??
                   (displayMode == ACDMultiDisplay.chips && hasValue
                       ? _ACDSelectionChips<T>(
                           design: design,
                           values: value,
                           label: label,
                           enabled: enabled,
                           maxVisible: maxVisibleChips,
                           chipBuilder: chipBuilder,
                           onRemove: remove,
                         )
                       : null);
               return _ACDDropdownBox(
                 design: design,
                 decoration: decoration,
                 errorText: field.errorText,
                 enabled: enabled,
                 isEmpty: !hasValue,
                 valueLabel: value
                     .map((item) => itemAsString?.call(item) ?? item.toString())
                     .join(', '),
                 showClearButton: showClearButton && hasValue,
                 clearIcon: clearIcon,
                 onClear: () {
                   field.didChange(const []);
                   onChanged?.call(const []);
                 },
                 onOpen: () => _openPopup<T>(
                   context: innerContext,
                   design: design,
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
                   groupBy: groupBy,
                   cacheResults: cacheResults,
                   onCreate: onCreate,
                   maxSelection: maxSelection,
                   showSelectAll: showSelectAll,
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
                 ),
                 child: display,
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
  /// back to [displayMode] (removable chips by default) when omitted.
  final Widget Function(BuildContext context, List<T> values)? dropdownBuilder;

  /// How the selection is shown when [dropdownBuilder] is null: removable
  /// chips (default since 2.0) or the older comma-joined text.
  final ACDMultiDisplay displayMode;

  /// Chips shown before collapsing the rest into a "+N" chip. `null` shows
  /// every selected item.
  final int? maxVisibleChips;

  /// Custom chip for one selected item; call `onRemove` to deselect it
  /// (`null` when the field is disabled).
  final Widget Function(BuildContext context, T item, VoidCallback? onRemove)?
  chipBuilder;

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
  final IconData? clearIcon;

  /// Whether to show the built-in Confirm/Cancel row in the popup.
  final bool showConfirmCancelButtons;

  /// Confirm button label.
  final String? confirmText;

  /// Cancel button label.
  final String? cancelText;

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
  final Color? tileColor;

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

  /// Groups popup rows under section headers — see `ACDSearchableListTile.groupBy`.
  final String Function(T item)? groupBy;

  /// Caches `onFind` results per query while the popup is open.
  final bool cacheResults;

  /// Offers a "Create" row when a search finds nothing — see
  /// `ACDSearchableListTile.onCreate`.
  final Future<T?> Function(String query)? onCreate;

  /// The most items that can be selected.
  final int? maxSelection;

  /// Adds a "Select all" row to the popup.
  final bool showSelectAll;

  /// Paginated async search/load — see `ACDSearchableListTile.onFindPaged`.
  /// When set, supersedes both [items] and [onFind].
  final Future<List<T>> Function(String keyword, int page)? onFindPaged;

  /// Trailing row shown while more of [onFindPaged]'s pages remain to load.
  final Widget Function(BuildContext context)? loadMoreBuilder;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign]. Applies to
  /// the closed field and the popup.
  final ACDDesign? design;
}

// ── Shared popup presentation ─────────────────────────────────────────────
//
// Both ACDDropdownField and ACDMultiDropdownField delegate here: dialog and
// bottomSheet modes reuse the existing ACDDialog.searchableList()/
// multiSearchableList() extensions untouched (just different ACDGravity);
// menu mode anchors the same ACDSearchableListTile content under the field
// in an anchored popup route (both designs: flips above when there's no
// room, clamps to the screen, traps focus, closes on Esc/back/outside tap);
// actionSheet/picker are the iOS-native presentations.
void _openPopup<T>({
  required BuildContext context,
  required ACDDesign? design,
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
  required Color? tileColor,
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
  required String Function(T item)? groupBy,
  required bool cacheResults,
  required Future<T?> Function(String query)? onCreate,
  required int? maxSelection,
  required bool showSelectAll,
  required Future<List<T>> Function(String keyword, int page)? onFindPaged,
  required Widget Function(BuildContext context)? loadMoreBuilder,
  void Function(T? item)? onSingleChange,
  void Function(List<T> items)? onMultiChange,
  List<T>? initialValues,
  bool showConfirmCancelButtons = true,
  String? confirmText,
  String? cancelText,
  Color? confirmColor,
  Color? cancelColor,
  FontWeight? confirmFontWeight,
  Color? checkboxActiveColor,
}) {
  final ACDResolvedDesign resolvedDesign = ACDDesign.resolve(context, design);
  ACDDropdownMode effective = mode;
  if (mode == ACDDropdownMode.adaptive) {
    // iOS: a short fixed list → action sheet; a longer single-select list →
    // wheel picker; searchable/remote → sheet with a search field.
    // Material: the centered dialog.
    final bool searchable = onFind != null || onFindPaged != null;
    effective = !resolvedDesign.isCupertino
        ? ACDDropdownMode.dialog
        : searchable
        ? ACDDropdownMode.bottomSheet
        : (items.length <= 7 || multiple)
        ? ACDDropdownMode.actionSheet
        : ACDDropdownMode.picker;
  }
  // The iOS-native presentations need a Cupertino design; under Material
  // they fall back to the bottom sheet (never crash).
  if ((effective == ACDDropdownMode.actionSheet ||
          effective == ACDDropdownMode.picker) &&
      !resolvedDesign.isCupertino) {
    effective = ACDDropdownMode.bottomSheet;
  }
  // A wheel picker is single-select; multi-select uses the action sheet.
  if (effective == ACDDropdownMode.picker && multiple) {
    effective = ACDDropdownMode.actionSheet;
  }

  switch (effective) {
    case ACDDropdownMode.adaptive:
      break; // resolved above
    case ACDDropdownMode.actionSheet:
      _showActionSheet<T>(
        context: context,
        multiple: multiple,
        items: items,
        label: (T item) => itemAsString?.call(item) ?? item.toString(),
        compareFn: compareFn,
        isDisabledItem: isDisabledItem,
        selected: multiple
            ? (initialValues ?? <T>[])
            : [if (field.value != null) field.value as T],
        onSingleChange: onSingleChange,
        onMultiChange: onMultiChange,
      );
    case ACDDropdownMode.picker:
      _showPicker<T>(
        context: context,
        items: [
          for (final T item in items)
            if (!(isDisabledItem?.call(item) ?? false)) item,
        ],
        label: (T item) => itemAsString?.call(item) ?? item.toString(),
        compareFn: compareFn,
        selected: field.value as T?,
        onSingleChange: onSingleChange,
      );
    case ACDDropdownMode.dialog:
    case ACDDropdownMode.bottomSheet:
      final dialog = ACDDialog(design: design).build(context)
        ..borderRadius = 16
        ..height = popupHeight ?? 420;
      if (effective == ACDDropdownMode.bottomSheet) {
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
          groupBy: groupBy,
          cacheResults: cacheResults,
          onCreate: onCreate,
          maxSelection: maxSelection,
          showSelectAll: showSelectAll,
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
          groupBy: groupBy,
          cacheResults: cacheResults,
          onCreate: onCreate,
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
      final Offset bottomRight = box.localToGlobal(
        box.size.bottomRight(Offset.zero),
        ancestor: overlayBox,
      );
      final double width = popupWidth ?? box.size.width;
      final double height = popupHeight ?? 320;
      final ACDResolvedDesign resolved = resolvedDesign;

      Widget buildList(VoidCallback dismiss) => ACDSearchableListTile<T>(
        design: design,
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
        groupBy: groupBy,
        cacheResults: cacheResults,
        onCreate: onCreate,
        maxSelection: maxSelection,
        showSelectAll: showSelectAll,
        onFindPaged: onFindPaged,
        loadMoreBuilder: loadMoreBuilder,
        dialogDismiss: dismiss,
      );

      // One anchored popover for both designs (an iOS pull-down / an M3
      // menu surface) on a plain PopupRoute: no Material ancestor or
      // localizations needed, focus is trapped while open, and Esc, back or
      // a tap outside closes it.
      Navigator.of(context).push(
        _ACDAnchoredPopupRoute<void>(
          anchor: Rect.fromPoints(
            box.localToGlobal(Offset.zero, ancestor: overlayBox),
            bottomRight,
          ),
          size: Size(width, height),
          barrierLabel: ACDDesignScope.stringsOf(context).close,
          builder: (popupContext) => ACDAdaptivePopupSurface(
            design: resolved,
            elevation: 3,
            borderRadius: BorderRadius.all(
              Radius.circular(resolved.isCupertino ? 14 : 8),
            ),
            child: buildList(() => Navigator.of(popupContext).pop()),
          ),
        ),
      );
  }
}

bool _acdSame<T>(T a, T b, bool Function(T a, T b)? compareFn) =>
    compareFn?.call(a, b) ?? a == b;

/// iOS action sheet: one row per item (checkmark on the selection), plus
/// Cancel. Multi-select rows toggle in place and a bold "Done" commits.
void _showActionSheet<T>({
  required BuildContext context,
  required bool multiple,
  required List<T> items,
  required String Function(T item) label,
  required bool Function(T a, T b)? compareFn,
  required bool Function(T item)? isDisabledItem,
  required List<T> selected,
  required void Function(T? item)? onSingleChange,
  required void Function(List<T> items)? onMultiChange,
}) {
  final ACDStrings strings = ACDDesignScope.stringsOf(context);
  final List<T> picked = [...selected];
  bool isPicked(T item) => picked.any((p) => _acdSame(p, item, compareFn));

  unawaited(
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final ACDDesignTokens tokens = ACDDesignTokens.of(
            sheetContext,
            ACDResolvedDesign.cupertino,
          );
          Widget row(T item) {
            final bool disabled = isDisabledItem?.call(item) ?? false;
            final bool on = isPicked(item);
            return CupertinoActionSheetAction(
              onPressed: () {
                if (disabled) return;
                ACDHaptics.selection(sheetContext);
                if (!multiple) {
                  Navigator.of(sheetContext).pop();
                  onSingleChange?.call(item);
                  return;
                }
                setSheetState(() {
                  if (on) {
                    picked.removeWhere((p) => _acdSame(p, item, compareFn));
                  } else {
                    picked.add(item);
                  }
                });
              },
              child: Semantics(
                selected: on,
                enabled: !disabled,
                child: Row(
                  children: [
                    const SizedBox(width: 28),
                    Expanded(
                      child: Text(
                        label(item),
                        textAlign: TextAlign.center,
                        style: disabled
                            ? TextStyle(color: tokens.disabled)
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: on
                          ? Icon(
                              ACDIcon.check.of(ACDResolvedDesign.cupertino),
                              size: 20,
                              color: tokens.primary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }

          return CupertinoActionSheet(
            actions: [
              for (final T item in items) row(item),
              if (multiple)
                CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    onMultiChange?.call(List<T>.unmodifiable(picked));
                  },
                  child: Text(strings.done),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(strings.cancel),
            ),
          );
        },
      ),
    ),
  );
}

/// iOS wheel picker in a bottom sheet with a Cancel / Done header. The
/// value commits on Done; each detent ticks a selection haptic.
void _showPicker<T>({
  required BuildContext context,
  required List<T> items,
  required String Function(T item) label,
  required bool Function(T a, T b)? compareFn,
  required T? selected,
  required void Function(T? item)? onSingleChange,
}) {
  if (items.isEmpty) return;
  final ACDStrings strings = ACDDesignScope.stringsOf(context);
  final int initial = selected == null
      ? 0
      : items
            .indexWhere((i) => _acdSame(i, selected, compareFn))
            .clamp(0, items.length - 1);
  int current = initial;

  unawaited(
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        final ACDDesignTokens tokens = ACDDesignTokens.of(
          sheetContext,
          ACDResolvedDesign.cupertino,
        );
        final double bottom = MediaQuery.paddingOf(sheetContext).bottom;
        return Container(
          height: 260 + bottom,
          padding: EdgeInsets.only(bottom: bottom),
          color: tokens.surface,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: tokens.separator, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(strings.cancel),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        onSingleChange?.call(items[current]);
                      },
                      child: Text(
                        strings.done,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  useMagnifier: true,
                  magnification: 1.1,
                  scrollController: FixedExtentScrollController(
                    initialItem: initial,
                  ),
                  onSelectedItemChanged: (int i) {
                    current = i;
                    ACDHaptics.selection(sheetContext);
                  },
                  children: [
                    for (final T item in items)
                      Center(
                        child: Text(
                          label(item),
                          style: TextStyle(color: tokens.onSurface),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// The closed-field selection of [ACDMultiDropdownField] as removable chips:
/// Material `InputChip`s, or iOS-style pills whose remove glyph has a 44 pt
/// hit area. Items past [maxVisible] collapse into a "+N" chip; tapping a
/// chip's body (not its remove button) still opens the popup.
class _ACDSelectionChips<T> extends StatelessWidget {
  const _ACDSelectionChips({
    required this.design,
    required this.values,
    required this.label,
    required this.enabled,
    required this.maxVisible,
    required this.chipBuilder,
    required this.onRemove,
  });

  final ACDDesign? design;
  final List<T> values;
  final String Function(T item) label;
  final bool enabled;
  final int? maxVisible;
  final Widget Function(BuildContext context, T item, VoidCallback? onRemove)?
  chipBuilder;
  final void Function(T item) onRemove;

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign resolved = ACDDesign.resolve(context, design);
    final ACDStrings strings = ACDDesignScope.stringsOf(context);
    final int shown = maxVisible == null
        ? values.length
        : values.length.clamp(0, maxVisible!);
    final int hidden = values.length - shown;

    Widget chipFor(T item) {
      final VoidCallback? remove = enabled ? () => onRemove(item) : null;
      final Widget? custom = chipBuilder?.call(context, item, remove);
      if (custom != null) return custom;
      return switch (resolved) {
        ACDResolvedDesign.material => InputChip(
          label: Text(label(item)),
          isEnabled: enabled,
          onDeleted: remove,
          deleteButtonTooltipMessage: strings.removeItemLabel(label(item)),
        ),
        ACDResolvedDesign.cupertino => _ACDCupertinoPill(
          label: label(item),
          removeLabel: strings.removeItemLabel(label(item)),
          onRemove: remove,
        ),
      };
    }

    final Widget? more = hidden > 0
        ? switch (resolved) {
            ACDResolvedDesign.material => Chip(
              label: Text(strings.moreItemsLabel(hidden)),
            ),
            ACDResolvedDesign.cupertino => _ACDCupertinoPill(
              label: strings.moreItemsLabel(hidden),
            ),
          }
        : null;

    return Wrap(
      spacing: resolved.isCupertino ? 0 : 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [for (int i = 0; i < shown; i++) chipFor(values[i]), ?more],
    );
  }
}

/// iOS-style token: a 30 pt tinted pill inside a 44 pt row, whose remove
/// glyph owns a full 44×44 pt hit area (overlapping the pill's end).
class _ACDCupertinoPill extends StatelessWidget {
  const _ACDCupertinoPill({
    required this.label,
    this.removeLabel,
    this.onRemove,
  });

  final String label;
  final String? removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final ACDDesignTokens tokens = ACDDesignTokens.of(
      context,
      ACDResolvedDesign.cupertino,
    );
    final bool removable = onRemove != null;
    final Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        height: 30,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 10,
                end: removable ? 0 : 10,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: tokens.primary, fontSize: 15),
              ),
            ),
            if (removable) const SizedBox(width: 26),
          ],
        ),
      ),
    );
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Padding(
            // Room for the remove hit box overhanging the pill's end, plus
            // the gap to the next chip.
            padding: EdgeInsetsDirectional.only(end: removable ? 9 : 6),
            child: pill,
          ),
          if (removable)
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              width: 44,
              child: Semantics(
                button: true,
                label: removeLabel,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRemove,
                  child: Center(
                    child: Icon(
                      ACDIcon.clear.of(ACDResolvedDesign.cupertino),
                      size: 16,
                      color: tokens.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The closed (collapsed) state of [ACDDropdownField] /
/// [ACDMultiDropdownField]: a Material `InputDecorator` field, or an iOS
/// grouped-row style field, with keyboard activation (Enter/Space), button
/// semantics and an optional clear button.
class _ACDDropdownBox extends StatefulWidget {
  /// Creates the closed-state field.
  const _ACDDropdownBox({
    required this.design,
    required this.decoration,
    required this.errorText,
    required this.enabled,
    required this.isEmpty,
    required this.valueLabel,
    required this.showClearButton,
    required this.clearIcon,
    required this.onClear,
    required this.onOpen,
    this.child,
  });

  /// Requested design.
  final ACDDesign? design;

  /// The caller's decoration.
  final InputDecoration decoration;

  /// Validation error from the form field (wins over the decoration's).
  final String? errorText;

  /// Whether the field can be opened.
  final bool enabled;

  /// Whether nothing is selected.
  final bool isEmpty;

  /// Text shown for the selection (when [child] is null) and announced.
  final String valueLabel;

  /// Whether to show the clear button.
  final bool showClearButton;

  /// Clear button icon; defaults per design.
  final IconData? clearIcon;

  /// Clears the selection.
  final VoidCallback onClear;

  /// Opens the popup.
  final VoidCallback onOpen;

  /// Custom selection display (the field's `dropdownBuilder`).
  final Widget? child;

  @override
  State<_ACDDropdownBox> createState() => _ACDDropdownBoxState();
}

class _ACDDropdownBoxState extends State<_ACDDropdownBox> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign design = ACDDesign.resolve(context, widget.design);
    final ACDDesignTokens tokens = ACDDesignTokens.of(context, design);
    final ACDStrings strings = ACDDesignScope.stringsOf(context);
    // A validation error wins; otherwise keep the caller's own errorText
    // (it used to be overwritten with null).
    final String? errorText = widget.errorText ?? widget.decoration.errorText;

    final Widget valueDisplay =
        widget.child ??
        Text(widget.valueLabel, overflow: TextOverflow.ellipsis);

    final Widget? clear = widget.showClearButton && widget.enabled
        ? Semantics(
            button: true,
            label: strings.clear,
            // 48 dp / 44 pt hit area around the 18 px glyph.
            child: ACDAdaptiveTappable(
              design: design,
              borderRadius: BorderRadius.circular(24),
              onTap: widget.onClear,
              child: ACDTapTargetBox(
                design: design,
                child: Icon(
                  widget.clearIcon ?? ACDIcon.clear.of(design),
                  size: 18,
                  color: design.isCupertino ? tokens.onSurfaceVariant : null,
                ),
              ),
            ),
          )
        : null;

    final Widget chevron = Icon(
      ACDIcon.chevronDown.of(design),
      size: design.isCupertino ? 18 : null,
      color: widget.enabled
          ? (design.isCupertino ? tokens.onSurfaceVariant : null)
          : tokens.disabled,
    );

    final Widget field = switch (design) {
      // The clear button + chevron sit in the decorator's suffix slot, which
      // InputDecorator already sizes for 48 dp icons — so the larger clear
      // hit area doesn't make the field taller. The whole field opens the
      // popup; the clear button (deeper in the tree) wins its own taps.
      ACDResolvedDesign.material => acdEnsureMaterial(
        context,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? widget.onOpen : null,
          child: InputDecorator(
            decoration: widget.decoration.copyWith(
              enabled: widget.enabled,
              errorText: errorText,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?widget.decoration.suffixIcon,
                  ?clear,
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: chevron,
                  ),
                ],
              ),
            ),
            isEmpty: widget.isEmpty,
            isFocused: _focused,
            child: valueDisplay,
          ),
        ),
      ),
      ACDResolvedDesign.cupertino => _cupertinoField(
        context,
        tokens,
        errorText,
        Row(
          children: [
            Expanded(child: valueDisplay),
            ?clear,
            const SizedBox(width: 4),
            chevron,
          ],
        ),
      ),
    };

    // Keyboard: focusable, Enter/Space opens. Screen readers: a button that
    // announces the current value.
    return FocusableActionDetector(
      enabled: widget.enabled,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      mouseCursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onOpen();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.decoration.labelText ?? widget.decoration.hintText,
        value: widget.valueLabel,
        onTap: widget.enabled ? widget.onOpen : null,
        child: field,
      ),
    );
  }

  Widget _cupertinoField(
    BuildContext context,
    ACDDesignTokens tokens,
    String? errorText,
    Widget row,
  ) {
    final String? label =
        widget.decoration.labelText ?? widget.decoration.hintText;
    final Widget box = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? widget.onOpen : null,
      child: Container(
        // No vertical padding: the 44 pt minimum centres the text, and the
        // 44 pt clear button fits without growing the row.
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: tokens.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: errorText != null
                ? tokens.error
                : (_focused ? tokens.primary : tokens.separator),
          ),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: widget.enabled ? tokens.onSurface : tokens.disabled,
            fontSize: 17,
          ),
          child: Row(
            children: [
              if (label != null && !widget.isEmpty) ...[
                Text(label, style: TextStyle(color: tokens.onSurfaceVariant)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: widget.isEmpty && label != null
                    ? Text(
                        label,
                        style: TextStyle(color: tokens.onSurfaceVariant),
                      )
                    : Align(
                        alignment: label != null
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: row,
                      ),
              ),
              if (widget.isEmpty && label != null)
                Icon(
                  ACDIcon.chevronDown.of(ACDResolvedDesign.cupertino),
                  size: 18,
                  color: tokens.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
    if (errorText == null) return box;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box,
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
          child: Semantics(
            liveRegion: true,
            child: Text(
              errorText,
              style: TextStyle(color: tokens.error, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

/// An anchored popover route (used for Cupertino menu-mode dropdowns):
/// opens below [anchor] — or above it when there isn't room — clamped to
/// the screen, with a fade/scale entrance (instant under reduce motion).
class _ACDAnchoredPopupRoute<R> extends PopupRoute<R> {
  /// Creates the route.
  _ACDAnchoredPopupRoute({
    required this.anchor,
    required this.size,
    required this.builder,
    required this.barrierLabel,
  });

  /// The field's rect in the navigator overlay's coordinates.
  final Rect anchor;

  /// Desired popup size.
  final Size size;

  /// Popup content builder.
  final WidgetBuilder builder;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return CustomSingleChildLayout(
      delegate: _AnchoredPopupLayout(
        anchor: anchor,
        size: size,
        safeTop: padding.top + 8,
        safeBottom: padding.bottom + keyboard + 8,
        textDirection: Directionality.of(context),
      ),
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (acdReduceMotion(context)) return child;
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        alignment: Alignment.topCenter,
        scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}

class _AnchoredPopupLayout extends SingleChildLayoutDelegate {
  _AnchoredPopupLayout({
    required this.anchor,
    required this.size,
    required this.safeTop,
    required this.safeBottom,
    required this.textDirection,
  });

  final Rect anchor;
  final Size size;
  final double safeTop;
  final double safeBottom;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double below = constraints.maxHeight - safeBottom - anchor.bottom;
    final double above = anchor.top - safeTop;
    final double room = below >= size.height
        ? below
        : (above > below ? above : below);
    return BoxConstraints.tightFor(
      // max(0, …): clamp() throws when its upper bound is negative (a
      // window narrower than the 16 px inset, or no room left at all).
      width: size.width.clamp(0, math.max(0.0, constraints.maxWidth - 16)),
      height: size.height.clamp(0, math.max(0.0, room)),
    );
  }

  @override
  Offset getPositionForChild(Size screen, Size child) {
    final double below = screen.height - safeBottom - anchor.bottom;
    final bool flip = below < child.height && anchor.top - safeTop > below;
    final double y = flip ? anchor.top - child.height - 4 : anchor.bottom + 4;
    // Align to the field's start edge: its right edge under RTL.
    final double preferred = textDirection == TextDirection.rtl
        ? anchor.right - child.width
        : anchor.left;
    final double maxX = math.max(8.0, screen.width - child.width - 8);
    final double x = preferred.clamp(8.0, maxX);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_AnchoredPopupLayout old) =>
      anchor != old.anchor ||
      size != old.size ||
      safeTop != old.safeTop ||
      safeBottom != old.safeBottom ||
      textDirection != old.textDirection;
}
