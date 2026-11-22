import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import '../list_tile/acd_checkbox_list_tile.dart';
import 'acd_dialog.dart';
import '../list_tile/acd_list_tile_item.dart';
import '../list_tile/acd_radio_list_tile.dart';
import '../motion/acd_motion.dart';
import '../motion/acd_stagger_options.dart';

/// Adds `listOfACDListTile()`, `listOfACDRadioButton()`, and
/// `listOfACDCheckbox()` to [ACDDialog] for adding scrollable list content.
extension ACDDialogLists on ACDDialog {
  /// Adds a scrollable list of tappable rows built from [items]. Returns
  /// this dialog for chaining.
  ACDDialog listOfACDListTile({
    List<ACDListTileItem>? items,
    double? height,
    EdgeInsets? padding,
    Color? tileColor,
    bool isClickAutoDismiss = true,
    Function(int)? onClickItemListener,
    ScrollPhysics? physics,
    ScrollController? controller,
    BorderRadius? borderRadius,
    // Entrance-only stagger for this row of tiles. `null` (the default)
    // keeps today's unanimated behavior.
    ACDStaggerOptions? stagger,
  }) {
    final int itemCount = items?.length ?? 0;
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SizedBox(
          height: height,
          // Design resolved once per list (not per row) when it builds.
          child: Builder(
            builder: (listContext) {
              final ACDResolvedDesign design = resolveDesign(listContext);
              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: physics,
                controller: controller,
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int index) {
                  final ACDListTileItem? item = items?[index];
                  void onTap() {
                    onClickItemListener?.call(index);
                    if (isClickAutoDismiss) dismiss();
                  }

                  final Widget title = Text(
                    item?.text ?? '',
                    style: TextStyle(
                      color: item?.color,
                      fontSize: item?.fontSize,
                      fontWeight: item?.fontWeight,
                      fontFamily: item?.fontFamily,
                    ).merge(item?.style),
                  );
                  final Widget tile = design.isCupertino
                      ? ACDAdaptiveListTile(
                          design: design,
                          backgroundColor: tileColor,
                          contentPadding: item?.padding,
                          leading: item?.leading,
                          trailing: item?.trailing,
                          onTap: onTap,
                          title: title,
                        )
                      : acdEnsureMaterial(
                          context,
                          Material(
                            color: tileColor ?? acdMaterialSurface(context),
                            child: ListTile(
                              onTap: onTap,
                              // BUG: defaulting to EdgeInsets.zero left
                              // icons/text flush against the dialog edge with no
                              // breathing room — match Flutter's own ListTile
                              // default instead.
                              contentPadding:
                                  item?.padding ??
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              leading: item?.leading,
                              trailing: item?.trailing,
                              shape: borderRadius == null
                                  ? null
                                  : RoundedRectangleBorder(
                                      borderRadius: borderRadius,
                                    ),
                              title: title,
                            ),
                          ),
                        );
                  if (stagger == null) return tile;
                  return ACDMotion(
                    key: ValueKey<int>(index),
                    delay: stagger.delayForIndex(
                      index,
                      itemCount,
                      visible: true,
                    ),
                    duration: stagger.itemDuration,
                    curve: stagger.curve,
                    effect: stagger.effect,
                    exitEffect: stagger.exitEffect,
                    child: tile,
                  );
                },
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
    // Entrance-only stagger for this row of tiles. `null` (the default)
    // keeps today's unanimated behavior.
    ACDStaggerOptions? stagger,
  }) {
    if (context == null) return this;
    final size = MediaQuery.sizeOf(context!);
    return widget(
      Container(
        height: height,
        padding: padding,
        constraints: BoxConstraints(
          minHeight: size.height * .1,
          minWidth: size.width * .1,
          maxHeight: size.height * .5,
        ),
        // Builder: read `design` when the dialog builds, so it applies
        // even if set after this call in the chain.
        child: Builder(
          builder: (_) => ACDRadioListTile(
            design: design,
            items: items,
            initialValue: initialValue,
            color: color,
            activeColor: activeColor,
            physics: physics,
            controller: controller,
            onChanged: onClickItemListener,
            borderRadius: borderRadius,
            stagger: stagger,
          ),
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
    // Entrance-only stagger for this row of tiles. `null` (the default)
    // keeps today's unanimated behavior.
    ACDStaggerOptions? stagger,
  }) {
    if (context == null) return this;
    final size = MediaQuery.sizeOf(context!);
    return widget(
      Container(
        height: height,
        padding: padding,
        constraints: BoxConstraints(
          minHeight: size.height * .1,
          minWidth: size.width * .1,
          maxHeight: size.height * .5,
        ),
        child: Builder(
          builder: (_) => ACDCheckboxListTile(
            design: design,
            items: items,
            initialValues: initialValues,
            color: color,
            activeColor: activeColor,
            physics: physics,
            controller: controller,
            onChanged: onChanged,
            borderRadius: borderRadius,
            stagger: stagger,
          ),
        ),
      ),
    );
  }
}
