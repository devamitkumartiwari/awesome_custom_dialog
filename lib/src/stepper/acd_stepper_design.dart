import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_tokens.dart';

/// The color scheme the stepper widgets paint with: the ambient Material
/// scheme as-is, or — for Cupertino — the same scheme with its roles mapped
/// to iOS system colors (so every existing paint path stays unchanged and
/// dark mode resolves correctly).
ColorScheme acdStepperScheme(BuildContext context, ACDResolvedDesign design) {
  final ColorScheme base = Theme.of(context).colorScheme;
  if (!design.isCupertino) return base;
  final ACDDesignTokens t = ACDDesignTokens.of(context, design);
  return base.copyWith(
    brightness: t.brightness,
    primary: t.primary,
    onPrimary: t.onPrimary,
    surfaceContainerHighest: t.track,
    onSurface: t.onSurface,
    onSurfaceVariant: t.onSurfaceVariant,
    outlineVariant: t.separator,
    outline: t.outline,
  );
}
