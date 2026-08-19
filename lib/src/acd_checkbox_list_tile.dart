import 'package:flutter/material.dart';

/// One option for `ACDDialog.listOfACDCheckbox()`.
class ACDCheckboxItem {
  /// Creates an [ACDCheckboxItem].
  const ACDCheckboxItem({
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.style,
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
}

// ── ACDCheckboxListTile ───────────────────────────────────────────────────────

/// The widget behind `ACDDialog.listOfACDCheckbox()`. Not normally
/// constructed directly.
class ACDCheckboxListTile extends StatefulWidget {
  /// Creates an [ACDCheckboxListTile].
  const ACDCheckboxListTile({
    super.key,
    required this.items,
    this.initialValues,
    this.color,
    this.activeColor,
    this.physics,
    this.controller,
    this.onChanged,
  });

  /// The selectable options.
  final List<ACDCheckboxItem>? items;

  /// Indices checked initially.
  final List<int>? initialValues;

  /// Background color of each row.
  final Color? color;

  /// Color of a checked checkbox.
  final Color? activeColor;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Scroll controller for the list.
  final ScrollController? controller;

  /// Called with the full set of checked indices whenever it changes.
  final Function(List<int>)? onChanged;

  @override
  State<ACDCheckboxListTile> createState() => _ACDCheckboxListTileState();
}

class _ACDCheckboxListTileState extends State<ACDCheckboxListTile> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.initialValues ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.physics,
      controller: widget.controller,
      itemCount: widget.items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items![index];
        return Material(
          color: widget.color,
          child: CheckboxListTile(
            title: Text(
              item.text ?? '',
              style: TextStyle(
                fontSize: item.fontSize ?? 14,
                fontWeight: item.fontWeight ?? FontWeight.normal,
                fontFamily: item.fontFamily,
                color: item.color ?? Colors.black,
              ).merge(item.style),
            ),
            value: _selected.contains(index),
            activeColor: widget.activeColor,
            checkColor: Colors.white,
            // BUG: defaulting to EdgeInsets.zero left icons/text flush
            // against the dialog edge with no breathing room — match
            // Flutter's own ListTile default instead.
            contentPadding:
                item.padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  _selected.add(index);
                } else {
                  _selected.remove(index);
                }
              });
              widget.onChanged?.call(_selected.toList()..sort());
            },
          ),
        );
      },
    );
  }
}
