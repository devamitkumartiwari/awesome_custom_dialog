import 'package:material_ui/material_ui.dart';

import 'acd_design.dart';
import 'acd_strings.dart';

/// Sets the default [ACDDesign], haptics and [ACDStrings] for every
/// awesome_custom_dialog widget below it. Optional: without a scope, widgets
/// render as [ACDDesign.material] with English strings.
///
/// A widget's own `design:` parameter always wins over the scope.
///
/// ```dart
/// ACDDesignScope(
///   design: ACDDesign.adaptive, // Cupertino on iOS/macOS, Material elsewhere
///   child: MaterialApp(home: HomePage()),
/// )
/// ```
///
/// Changing [design] rebuilds only widgets that depend on the scope.
class ACDDesignScope extends InheritedWidget {
  /// Creates a design scope.
  const ACDDesignScope({
    super.key,
    this.design = ACDDesign.material,
    this.hapticsEnabled = true,
    this.strings = ACDStrings.english,
    required super.child,
  });

  /// Default design for descendants that don't set their own.
  final ACDDesign design;

  /// Master switch for the package's haptic feedback. Per-widget haptic
  /// options still apply when this is `true`.
  final bool hapticsEnabled;

  /// Strings used by descendant widgets.
  final ACDStrings strings;

  /// The nearest scope, registering a rebuild dependency, or `null`.
  static ACDDesignScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ACDDesignScope>();

  /// The nearest scope's [strings], or English defaults.
  static ACDStrings stringsOf(BuildContext context) =>
      maybeOf(context)?.strings ?? ACDStrings.english;

  @override
  bool updateShouldNotify(ACDDesignScope oldWidget) =>
      design != oldWidget.design ||
      hapticsEnabled != oldWidget.hapticsEnabled ||
      !identical(strings, oldWidget.strings);
}
