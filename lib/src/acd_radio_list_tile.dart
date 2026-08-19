import 'package:flutter/material.dart';

/// One option for `ACDDialog.listOfACDRadioButton()`.
class ACDRadioItem {
  /// Creates an [ACDRadioItem].
  const ACDRadioItem({
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.style,
    this.onTap,
  });

  /// Content padding for this option. Defaults to a sensible horizontal
  /// inset if unset.
  final EdgeInsets? padding;

  /// The option's label.
  final String? text;

  /// Text color.
  final Color? color;

  /// Text size.
  final double? fontSize;

  /// Text weight.
  final FontWeight? fontWeight;

  /// Text font family.
  final String? fontFamily;

  /// Full style control, merged over [color]/[fontSize]/[fontWeight]/
  /// [fontFamily] above.
  final TextStyle? style;

  /// Called with this option's index when it's selected.
  final Function(int)? onTap;
}

// ── ACDRadioListTile ──────────────────────────────────────────────────────────

/// The widget behind `ACDDialog.listOfACDRadioButton()`. Not normally
/// constructed directly.
class ACDRadioListTile extends StatefulWidget {
  /// Creates an [ACDRadioListTile].
  const ACDRadioListTile({
    super.key,
    required this.items,
    this.initialValue,
    this.color,
    this.activeColor,
    this.physics,
    this.controller,
    this.onChanged,
  });

  /// The selectable options.
  final List<ACDRadioItem>? items;

  /// Index selected initially.
  final int? initialValue;

  /// Background color of each row.
  final Color? color;

  /// Color of the selected radio button.
  final Color? activeColor;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Scroll controller for the list.
  final ScrollController? controller;

  /// Called with the newly selected index whenever the selection changes.
  final Function(int)? onChanged;

  @override
  State<ACDRadioListTile> createState() => _ACDRadioListTileState();
}

class _ACDRadioListTileState extends State<ACDRadioListTile> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    // RadioListTile.groupValue/onChanged are deprecated in favor of an
    // ancestor RadioGroup — it supplies the group value/change handler to
    // every RadioListTile in the subtree instead of each tile taking them
    // directly.
    return RadioGroup<int>(
      groupValue: _selected,
      onChanged: (int? value) {
        if (value == null) return;
        setState(() => _selected = value);
        widget.onChanged?.call(value);
        widget.items?[value].onTap?.call(value);
      },
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: widget.physics,
        controller: widget.controller,
        itemCount: widget.items?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items![index];
          return Material(
            color: widget.color,
            child: RadioListTile<int>(
              title: Text(
                item.text ?? '',
                style: TextStyle(
                  fontSize: item.fontSize ?? 14,
                  fontWeight: item.fontWeight ?? FontWeight.normal,
                  fontFamily: item.fontFamily,
                  color: item.color ?? Colors.black,
                ).merge(item.style),
              ),
              value: index,
              activeColor: widget.activeColor,
              // BUG: ACDRadioItem.padding was defined but never applied,
              // unlike ACDCheckboxItem.padding in acd_checkbox_list_tile.dart
              // — inconsistent API.
              // BUG: defaulting to EdgeInsets.zero left icons/text flush
              // against the dialog edge with no breathing room — match
              // Flutter's own ListTile default instead.
              contentPadding:
                  item.padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          );
        },
      ),
    );
  }
}
