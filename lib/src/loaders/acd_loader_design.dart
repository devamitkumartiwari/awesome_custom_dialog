import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_tokens.dart';

/// Default (track, progress) colors for the percent loaders, used only when
/// the caller didn't pass explicit colors.
///
/// Material light keeps the original look (fixed grey track, scheme
/// primary). Material dark swaps the fixed light-grey track — near
/// invisible on dark surfaces — for the scheme's track color. Cupertino
/// uses iOS system fill + accent.
({Color track, Color progress}) acdLoaderDefaults(
  BuildContext context,
  ACDDesign? design,
) {
  final ACDResolvedDesign resolved = ACDDesign.resolve(context, design);
  final ACDDesignTokens tokens = ACDDesignTokens.of(context, resolved);
  final bool keepClassicTrack =
      !resolved.isCupertino && tokens.brightness == Brightness.light;
  return (
    track: keepClassicTrack ? const Color(0xFFB8C7CB) : tokens.track,
    progress: tokens.primary,
  );
}

/// Wraps a determinate loader so screen readers announce its value (like
/// Flutter's own ProgressIndicator does).
Widget acdLoaderSemantics({
  required double percent,
  required Widget child,
  String? label,
}) {
  return Semantics(
    label: label,
    value: '${(percent.clamp(0.0, 1.0) * 100).round()}%',
    child: child,
  );
}
