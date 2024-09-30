import 'package:flutter/material.dart';

import 'awesome_custom_dialog.dart';

class ACDRadioListTile extends StatefulWidget {
  const ACDRadioListTile({
    super.key,
    this.items,
    this.initialValue,
    this.color,
    this.activeColor,
    this.onChanged,
  })  : assert(items != null);

  final List<ACDRadioItem>? items;
  final Color? color;
  final Color? activeColor;
  final dynamic initialValue;
  final Function(int)? onChanged;

  @override
  State<StatefulWidget> createState() {
    return ACDRadioListTileState();
  }
}

class ACDRadioListTileState extends State<ACDRadioListTile> {
  var groupId = -1;

  void initialSelectedItem() {
    if (groupId == -1) {
      groupId = widget.initialValue ?? -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    initialSelectedItem();

    return ListView.builder(
      padding: const EdgeInsets.all(0.0),
      shrinkWrap: true,
      itemCount: widget.items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return Material(
          color: widget.color,
          child: RadioListTile(
            title: Text(
              widget.items?[index].text ?? "",
              style: TextStyle(
                  fontSize: widget.items?[index].fontSize ?? 14,
                  fontWeight:
                  widget.items?[index].fontWeight ?? FontWeight.normal,
                  color: widget.items?[index].color ?? Colors.black),
            ),
            value: index,
            groupValue: groupId,
            activeColor: widget.activeColor,
            onChanged: (int? value) {
              setState(() {
                if (widget.onChanged != null) {
                  widget.onChanged!(value ?? 0);
                }
                groupId = value ?? -1;
              });
            },
          ),
        );
      },
    );
  }
}