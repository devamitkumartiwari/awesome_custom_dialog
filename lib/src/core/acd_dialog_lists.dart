import 'package:flutter/material.dart';

import '../list_tile/acd_checkbox_list_tile.dart';
import 'acd_dialog.dart';
import '../list_tile/acd_list_tile_item.dart';
import '../list_tile/acd_radio_list_tile.dart';

/// Adds `listOfACDListTile()`, `listOfACDRadioButton()`, and
/// `listOfACDCheckbox()` to [ACDDialog] for adding scrollable list content.
extension ACDDialogLists on ACDDialog {
  /// Adds a scrollable list of tappable rows built from [items]. Returns
  /// this dialog for chaining.
  ACDDialog listOfACDListTile({
    List<ACDListTileItem>? items,
    double? height,
    EdgeInsets? padding,
    Color tileColor = Colors.white,
    bool isClickAutoDismiss = true,
    Function(int)? onClickItemListener,
    ScrollPhysics? physics,
    ScrollController? controller,
    BorderRadius? borderRadius,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SizedBox(
          height: height,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: physics,
            controller: controller,
            itemCount: items?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return Material(
                color: tileColor,
                child: ListTile(
                  onTap: () {
                    onClickItemListener?.call(index);
                    if (isClickAutoDismiss) dismiss();
                  },
                  // BUG: defaulting to EdgeInsets.zero left icons/text flush
                  // against the dialog edge with no breathing room — match
                  // Flutter's own ListTile default instead.
                  contentPadding:
                      items?[index].padding ??
                      const EdgeInsets.symmetric(horizontal: 16.0),
                  leading: items?[index].leading,
                  trailing: items?[index].trailing,
                  shape: borderRadius == null
                      ? null
                      : RoundedRectangleBorder(borderRadius: borderRadius),
                  title: Text(
                    items?[index].text ?? '',
                    style: TextStyle(
                      color: items?[index].color,
                      fontSize: items?[index].fontSize,
                      fontWeight: items?[index].fontWeight,
                      fontFamily: items?[index].fontFamily,
                    ).merge(items?[index].style),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Adds a single-select radio list built from [items]. Returns this
  /// dialog for chaining.
  ACDDialog listOfACDRadioButton({
    List<ACDRadioItem>? items,
    double? height,
    EdgeInsets? padding,
    Color? color,
    Color? activeColor,
    int? initialValue,
    Function(int)? onClickItemListener,
    ScrollPhysics? physics,
    ScrollController? controller,
    BorderRadius? borderRadius,
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
        child: ACDRadioListTile(
          items: items,
          initialValue: initialValue,
          color: color,
          activeColor: activeColor,
          physics: physics,
          controller: controller,
          onChanged: onClickItemListener,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  /// Adds a multi-select checkbox list built from [items]. Returns this
  /// dialog for chaining.
  ACDDialog listOfACDCheckbox({
    List<ACDCheckboxItem>? items,
    double? height,
    EdgeInsets? padding,
    Color? color,
    Color? activeColor,
    List<int>? initialValues,
    Function(List<int>)? onChanged,
    ScrollPhysics? physics,
    ScrollController? controller,
    BorderRadius? borderRadius,
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
        child: ACDCheckboxListTile(
          items: items,
          initialValues: initialValues,
          color: color,
          activeColor: activeColor,
          physics: physics,
          controller: controller,
          onChanged: onChanged,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
