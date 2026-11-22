import 'dart:ui' show FlutterView;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../acd_design_scope.dart';

/// Whether the platform asked to reduce motion (iOS "Reduce Motion",
/// Android "Remove animations"). Animations should jump to their end state.
bool acdReduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Package haptics, honouring [ACDDesignScope.hapticsEnabled].
abstract final class ACDHaptics {
  /// Whether package haptics are on at [context] (the master switch).
  static bool enabled(BuildContext context) =>
      ACDDesignScope.maybeOf(context)?.hapticsEnabled ?? true;

  /// A selection tick (toggles, steps, picking an item).
  static void selection(BuildContext context) {
    if (enabled(context)) HapticFeedback.selectionClick();
  }

  /// A light impact (confirmations).
  static void light(BuildContext context) {
    if (enabled(context)) HapticFeedback.lightImpact();
  }

  /// A heavier impact (errors, warnings).
  static void heavy(BuildContext context) {
    if (enabled(context)) HapticFeedback.heavyImpact();
  }
}

/// Announces [message] to screen readers. Needed in addition to
/// `liveRegion`, which iOS VoiceOver ignores.
void acdAnnounce(BuildContext context, String message) {
  final FlutterView? view = View.maybeOf(context);
  if (view == null || message.isEmpty) return;
  SemanticsService.sendAnnouncement(
    view,
    message,
    Directionality.maybeOf(context) ?? TextDirection.ltr,
  );
}

/// Makes Material-design content safe to build where the app provides no
/// Material scaffolding (e.g. a bare `CupertinoApp` with
/// `ACDDesign.material`): supplies default Material localizations and a
/// transparent `Material` ancestor only when they are missing. A no-op
/// passthrough in normal Material apps.
Widget acdEnsureMaterial(BuildContext context, Widget child) {
  Widget result = child;
  if (Material.maybeOf(context) == null) {
    result = Material(type: MaterialType.transparency, child: result);
  }
  if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) ==
      null) {
    const List<LocalizationsDelegate<dynamic>> delegates =
        <LocalizationsDelegate<dynamic>>[DefaultMaterialLocalizations.delegate];
    result = Localizations.maybeLocaleOf(context) != null
        ? Localizations.override(
            context: context,
            delegates: delegates,
            child: result,
          )
        : Localizations(
            locale: const Locale('en', 'US'),
            delegates: const <LocalizationsDelegate<dynamic>>[
              ...delegates,
              DefaultWidgetsLocalizations.delegate,
            ],
            child: result,
          );
  }
  return result;
}

/// The Material default for a card/row surface: the original
/// `Colors.white` in light mode (pixel-identical to before), the theme's
/// raised surface in dark mode — where white made light theme text
/// unreadable.
Color acdMaterialSurface(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.surfaceContainerHigh
      : Colors.white;
}

/// The Material default for text on [acdMaterialSurface]: the original
/// `Colors.black` in light mode, the theme's `onSurface` in dark mode.
Color acdMaterialOnSurface(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.onSurface
      : Colors.black;
}
