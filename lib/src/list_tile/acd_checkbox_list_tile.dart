import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import '../motion/acd_motion.dart';
import '../motion/acd_stagger_options.dart';

/// One option for `ACDDialog.listOfACDCheckbox()`.
class ACDCheckboxItem {
  /// Creates an [ACDCheckboxItem].
  const ACDCheckboxItem({
    this.padding,
    this.leading,
    this.trailing,
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

  /// Widget shown opposite the checkbox (before it, since the control
  /// itself defaults to the trailing side). Ignored if [trailing] is also
  /// set — `CheckboxListTile` only has one such slot, matching Flutter's
  /// own constraint; set at most one of the two.
  final Widget? leading;

  /// Widget shown opposite the checkbox, with the control moved to the
  /// leading side to make room. Takes priority over [leading] if both are
  /// set — see [leading]'s note.
  final Widget? trailing;

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
    this.borderRadius,
    this.stagger,
    this.design,
  });

  /// The selectable options.
  final List<ACDCheckboxItem>? items;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign].
  final ACDDesign? design;

  /// Entrance-only stagger for these rows. `null` (the default) keeps
  /// today's unanimated behavior.
  final ACDStaggerOptions? stagger;

  /// Indices checked initially.
  final List<int>? initialValues;

  /// Background color of each row.
  final Color? color;

  /// Corner rounding for each row.
  final BorderRadius? borderRadius;

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

  void _toggle(int index, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(index);
      } else {
        _selected.remove(index);
      }
    });
    widget.onChanged?.call(_selected.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    // Resolved once per list, never per row.
    final ACDResolvedDesign design = ACDDesign.resolve(context, widget.design);
    final Color? cupertinoText = design.isCupertino
        ? ACDDesignTokens.of(context, design).onSurface
        : null;
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.physics,
      controller: widget.controller,
      itemCount: widget.items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items![index];
        final bool checked = _selected.contains(index);
        if (design.isCupertino) {
          final Widget row = ACDAdaptiveListTile(
            design: design,
            selected: checked,
            backgroundColor: widget.color,
            contentPadding: item.padding,
            onTap: () {
              ACDHaptics.selection(context);
              _toggle(index, !checked);
            },
            leading: ACDAdaptiveCheckbox(
              design: design,
              value: checked,
              activeColor: widget.activeColor,
              onChanged: (v) => _toggle(index, v ?? false),
            ),
            trailing: item.trailing ?? item.leading,
            title: Text(
              item.text ?? '',
              style: TextStyle(
                fontSize: item.fontSize,
                fontWeight: item.fontWeight,
                fontFamily: item.fontFamily,
                color: item.color ?? cupertinoText,
              ).merge(item.style),
            ),
          );
          return _staggered(index, row);
        }
        final Widget tile = acdEnsureMaterial(
          context,
          Material(
            color: widget.color,
            child: CheckboxListTile(
              title: Text(
                item.text ?? '',
                style: TextStyle(
                  fontSize: item.fontSize ?? 14,
                  fontWeight: item.fontWeight ?? FontWeight.normal,
                  fontFamily: item.fontFamily,
                  color: item.color ?? acdMaterialOnSurface(context),
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
              // CheckboxListTile has one extra slot (`secondary`), not
              // independent leading/trailing — see ACDCheckboxItem's dartdoc.
              secondary: item.trailing ?? item.leading,
              controlAffinity: item.trailing != null
                  ? ListTileControlAffinity.leading
                  : ListTileControlAffinity.platform,
              shape: widget.borderRadius == null
                  ? null
                  : RoundedRectangleBorder(borderRadius: widget.borderRadius!),
              onChanged: (bool? value) => _toggle(index, value == true),
            ),
          ),
        );
        return _staggered(index, tile);
      },
    );
  }

  Widget _staggered(int index, Widget tile) {
    final ACDStaggerOptions? stagger = widget.stagger;
    if (stagger == null) return tile;
    return ACDMotion(
      key: ValueKey<int>(index),
      delay: stagger.delayForIndex(
        index,
        widget.items?.length ?? 0,
        visible: true,
      ),
      duration: stagger.itemDuration,
      curve: stagger.curve,
      effect: stagger.effect,
      exitEffect: stagger.exitEffect,
      child: tile,
    );
  }
}
