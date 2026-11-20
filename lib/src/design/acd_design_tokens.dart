import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'acd_design.dart';

/// The palette awesome_custom_dialog widgets use for their *default* colors
/// (explicit color parameters always win), resolved for the active design
/// and brightness — so defaults follow dark mode instead of hard-coded
/// light-theme values.
///
/// Material values come from the ambient `ColorScheme`; Cupertino values
/// from `CupertinoTheme` and iOS system colors, resolved for the current
/// brightness and contrast.
@immutable
class ACDDesignTokens {
  /// Creates a token set. Normally obtained via [ACDDesignTokens.of].
  const ACDDesignTokens({
    required this.design,
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceContainer,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.separator,
    required this.track,
    required this.disabled,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.barrier,
  });

  /// The design these tokens were resolved for.
  final ACDResolvedDesign design;

  /// Light or dark.
  final Brightness brightness;

  /// Accent color.
  final Color primary;

  /// Content on [primary].
  final Color onPrimary;

  /// Card/dialog background.
  final Color surface;

  /// Raised container background (popups, fields).
  final Color surfaceContainer;

  /// Primary text/icon color on [surface].
  final Color onSurface;

  /// Secondary text/icon color on [surface].
  final Color onSurfaceVariant;

  /// Borders and outlines.
  final Color outline;

  /// Hairline dividers.
  final Color separator;

  /// Inactive progress/switch track.
  final Color track;

  /// Disabled content.
  final Color disabled;

  /// Error state.
  final Color error;

  /// Success state.
  final Color success;

  /// Warning state.
  final Color warning;

  /// Informational state.
  final Color info;

  /// Modal barrier.
  final Color barrier;

  /// Resolves tokens for [design] at [context].
  static ACDDesignTokens of(BuildContext context, ACDResolvedDesign design) {
    switch (design) {
      case ACDResolvedDesign.material:
        final ThemeData theme = Theme.of(context);
        final ColorScheme cs = theme.colorScheme;
        final bool dark = cs.brightness == Brightness.dark;
        return ACDDesignTokens(
          design: design,
          brightness: cs.brightness,
          primary: cs.primary,
          onPrimary: cs.onPrimary,
          surface: cs.surface,
          surfaceContainer: cs.surfaceContainerHigh,
          onSurface: cs.onSurface,
          onSurfaceVariant: cs.onSurfaceVariant,
          outline: cs.outline,
          separator: cs.outlineVariant,
          track: cs.surfaceContainerHighest,
          disabled: cs.onSurface.withValues(alpha: 0.38),
          error: cs.error,
          success: dark ? const Color(0xFF81C995) : const Color(0xFF1E8E3E),
          warning: dark ? const Color(0xFFFDD663) : const Color(0xFFB06000),
          info: cs.primary,
          barrier: Colors.black54,
        );
      case ACDResolvedDesign.cupertino:
        Color r(Color c) => CupertinoDynamicColor.resolve(c, context);
        final CupertinoThemeData theme = CupertinoTheme.of(context);
        final Brightness brightness =
            theme.brightness ??
            MediaQuery.maybePlatformBrightnessOf(context) ??
            Brightness.light;
        return ACDDesignTokens(
          design: design,
          brightness: brightness,
          primary: r(theme.primaryColor),
          onPrimary: r(theme.primaryContrastingColor),
          surface: r(CupertinoColors.systemBackground),
          surfaceContainer: r(CupertinoColors.secondarySystemGroupedBackground),
          onSurface: r(CupertinoColors.label),
          onSurfaceVariant: r(CupertinoColors.secondaryLabel),
          outline: r(CupertinoColors.opaqueSeparator),
          separator: r(CupertinoColors.separator),
          track: r(CupertinoColors.systemFill),
          disabled: r(CupertinoColors.tertiaryLabel),
          error: r(CupertinoColors.systemRed),
          success: r(CupertinoColors.systemGreen),
          warning: r(CupertinoColors.systemOrange),
          info: r(CupertinoColors.systemBlue),
          barrier: r(kCupertinoModalBarrierColor),
        );
    }
  }
}
