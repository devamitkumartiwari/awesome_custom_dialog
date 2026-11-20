import 'package:material_ui/material_ui.dart';

import 'acd_design_scope.dart';

/// Which design system an awesome_custom_dialog widget renders with.
///
/// Every widget in this package takes an optional `design:` parameter. When
/// it is `null`, the nearest [ACDDesignScope] decides; with no scope either,
/// the widget renders as [material] — exactly as in earlier releases.
///
/// ```dart
/// // Per widget:
/// ACDPinField(design: ACDDesign.cupertino, length: 6);
///
/// // App-wide default:
/// ACDDesignScope(design: ACDDesign.adaptive, child: MaterialApp(...));
/// ```
enum ACDDesign {
  /// Material 3 look and behaviour.
  material,

  /// iOS (Cupertino) look and behaviour.
  cupertino,

  /// Cupertino on iOS/macOS, Material everywhere else. Also resolves to
  /// Cupertino when the tree has no `MaterialLocalizations` (a bare
  /// `CupertinoApp`), so it can never hit Material-only assertions.
  adaptive;

  /// Resolves the effective design for a widget at [context].
  ///
  /// Precedence: [override] (the widget's own `design`) → nearest
  /// [ACDDesignScope] → [ACDDesign.material].
  ///
  /// Cost: one inherited lookup plus, for [adaptive] only, a theme and a
  /// localizations lookup — call once per build and pass the result down.
  static ACDResolvedDesign resolve(
    BuildContext context, [
    ACDDesign? override,
  ]) {
    final ACDDesign design =
        override ?? ACDDesignScope.maybeOf(context)?.design ?? material;
    switch (design) {
      case ACDDesign.material:
        return ACDResolvedDesign.material;
      case ACDDesign.cupertino:
        return ACDResolvedDesign.cupertino;
      case ACDDesign.adaptive:
        final bool hasMaterialL10n =
            Localizations.of<MaterialLocalizations>(
              context,
              MaterialLocalizations,
            ) !=
            null;
        if (!hasMaterialL10n) return ACDResolvedDesign.cupertino;
        switch (Theme.of(context).platform) {
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            return ACDResolvedDesign.cupertino;
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            return ACDResolvedDesign.material;
        }
    }
  }
}

/// The concrete design a widget renders with, after [ACDDesign.adaptive]
/// has been resolved for the current platform.
enum ACDResolvedDesign {
  /// Render the Material variant.
  material,

  /// Render the Cupertino variant.
  cupertino;

  /// Whether this is [cupertino].
  bool get isCupertino => this == ACDResolvedDesign.cupertino;
}
