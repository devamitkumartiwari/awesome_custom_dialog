import 'package:material_ui/material_ui.dart';

import '../core/acd_content_type.dart';
import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

// ── ACDSnackbarContent ────────────────────────────────────────────────────────
// FEAT-16: standalone widget — usable directly inside a real
// SnackBar/ScaffoldMessenger/MaterialBanner, or via the ACDDialog.snackbar()
// convenience factory (see acd_dialog.dart). The icon bubble and decorative
// corner "splash" are drawn with plain Flutter primitives (Icon + CustomPaint)
// rather than bundled image assets, keeping the package dependency-free (no
// flutter_svg/asset pipeline).

/// A colorful success/failure/warning/help snackbar banner. Use it directly
/// inside a Flutter `SnackBar`/`ScaffoldMessenger`/`MaterialBanner`, or via
/// the `ACDDialog.snackbar()` convenience factory.
class ACDSnackbarContent extends StatelessWidget {
  /// Creates an [ACDSnackbarContent].
  const ACDSnackbarContent({
    super.key,
    required this.title,
    required this.message,
    this.contentType = ACDContentType.success,
    this.color,
    this.gradient,
    this.icon,
    this.titleTextStyle,
    this.titleFontSize,
    this.titleFontWeight,
    this.titleFontFamily,
    this.messageTextStyle,
    this.messageFontSize,
    this.messageFontWeight,
    this.messageFontFamily,
    this.borderRadius = 20.0,
    this.padding,
    this.inMaterialBanner = false,
    this.onClose,
    this.closeIcon = Icons.close_rounded,
    this.elevation = 0,
    this.boxShadow,
    this.design,
  });

  /// The banner's bold heading.
  final String title;

  /// The banner's body text.
  final String message;

  /// Which ready-made look to use (also picks the default [color]/[icon]).
  final ACDContentType contentType;

  /// Overrides the background color implied by [contentType].
  final Color? color;

  /// Gradient background, overriding [color]/[contentType]'s color when set.
  final Gradient? gradient;

  /// Overrides the icon implied by [contentType].
  final IconData? icon;

  /// Full style control for the title, merged over
  /// [titleFontSize]/[titleFontWeight]/[titleFontFamily] and the default
  /// white/bold style.
  final TextStyle? titleTextStyle;

  /// Title text size shortcut.
  final double? titleFontSize;

  /// Title text weight shortcut.
  final FontWeight? titleFontWeight;

  /// Title text font family shortcut.
  final String? titleFontFamily;

  /// Full style control for the message, merged over
  /// [messageFontSize]/[messageFontWeight]/[messageFontFamily] and the
  /// default white style.
  final TextStyle? messageTextStyle;

  /// Message text size shortcut.
  final double? messageFontSize;

  /// Message text weight shortcut.
  final FontWeight? messageFontWeight;

  /// Message text font family shortcut.
  final String? messageFontFamily;

  /// Corner radius of the banner card.
  final double borderRadius;

  /// Outer padding; defaults to a small top gap unless [inMaterialBanner].
  final EdgeInsets? padding;

  /// Set to `true` when hosting inside a `MaterialBanner`, which already
  /// reserves its own top spacing.
  final bool inMaterialBanner;

  /// Called when the close button is tapped. Defaults to
  /// `ScaffoldMessenger.of(context).hideCurrentSnackBar()`.
  final VoidCallback? onClose;

  /// Icon for the close button.
  final IconData closeIcon;

  /// Drop-shadow elevation for the banner card. Ignored when [boxShadow] is
  /// supplied.
  final double elevation;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign]. Affects
  /// the close button (iOS: no ripple, Cupertino glyph).
  final ACDDesign? design;

  /// Explicit shadow for the banner card, overriding [elevation].
  final List<BoxShadow>? boxShadow;

  Widget _closeButton(BuildContext context) {
    final ACDResolvedDesign resolved = ACDDesign.resolve(context, design);
    // Outside a ScaffoldMessenger (e.g. ACDDialog.snackbar(), a CupertinoApp)
    // there is no current SnackBar to hide — never throw.
    final VoidCallback onPressed =
        onClose ??
        () => ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
    final String label = ACDDesignScope.stringsOf(context).close;
    if (resolved.isCupertino) {
      return Semantics(
        button: true,
        label: label,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 44),
          onPressed: onPressed,
          child: Icon(
            closeIcon == Icons.close_rounded
                ? ACDIcon.close.of(resolved)
                : closeIcon,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }
    return acdEnsureMaterial(
      context,
      IconButton(
        icon: Icon(closeIcon, color: Colors.white),
        tooltip: label,
        padding: EdgeInsets.zero,
        // 48 dp hit area (was zero-constrained, ~24 px).
        constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final bool isTablet = MediaQuery.sizeOf(context).width >= 800;
    final Color resolvedColor = color ?? contentType.color;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: padding ?? EdgeInsets.only(top: inMaterialBanner ? 0 : 16),
      child: SizedBox(
        height: isTablet ? 130 : 100,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Background card
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: gradient == null ? resolvedColor : null,
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow:
                      boxShadow ??
                      (elevation > 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: elevation * 2,
                                offset: Offset(0, elevation / 2),
                              ),
                            ]
                          : null),
                ),
              ),
            ),
            // Decorative bottom-corner splash (bubbles.svg stand-in)
            Positioned.fill(
              child: Transform.flip(
                flipX: rtl,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(borderRadius),
                  ),
                  child: CustomPaint(painter: _ACDSplashPainter(resolvedColor)),
                ),
              ),
            ),
            // Title/close row + message
            Positioned.fill(
              child: Padding(
                // BUG FIX: previously hardcoded fromLTRB, which reserved the
                // icon-bubble gutter on the physical-left even under RTL —
                // half-mirrored alongside the splash's Transform.flip above.
                padding: EdgeInsetsDirectional.fromSTEB(70, 5, 12, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            title,
                            // The card has a fixed height: never let a long
                            // or text-scaled title push the message out.
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize ?? (isTablet ? 22 : 18),
                              fontWeight: titleFontWeight ?? FontWeight.w600,
                              fontFamily: titleFontFamily,
                            ).merge(titleTextStyle),
                          ),
                        ),
                        // Reserves the glyph's old footprint; the 48/44
                        // button itself is overlaid at the card's top-end
                        // so its larger hit area doesn't push the message.
                        const SizedBox(width: 24, height: 24),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: messageFontSize ?? (isTablet ? 16 : 14),
                          fontWeight: messageFontWeight,
                          fontFamily: messageFontFamily,
                        ).merge(messageTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Icon bubble (back.svg + type-icon stand-in)
            // BUG FIX: previously hardcoded to the physical-left, so it
            // stayed put while the splash mirrored under RTL — now uses
            // Positioned.directional so both move together.
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 16,
              top: -6,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: resolvedColor, width: 3),
                ),
                child: Icon(
                  icon ?? contentType.icon,
                  color: resolvedColor,
                  size: 24,
                ),
              ),
            ),
            // Close button last so it sits above everything for hit-testing.
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: 0,
              end: 0,
              child: _closeButton(context),
            ),
          ],
        ),
      ),
    );
  }
}

// FEAT-16: darker-shade circle cluster standing in for the source package's
// bundled bubbles.svg decorative splash, via the same HSL-darkening approach
// the original uses for its accent shading.
class _ACDSplashPainter extends CustomPainter {
  _ACDSplashPainter(this.baseColor);

  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final Paint paint = Paint()
      ..color = hsl
          .withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0))
          .toColor()
          .withValues(alpha: 0.55);

    canvas.drawCircle(Offset(size.width * 0.06, size.height * 0.95), 26, paint);
    canvas.drawCircle(Offset(size.width * 0.16, size.height * 1.05), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.02, size.height * 0.75), 14, paint);
  }

  @override
  bool shouldRepaint(covariant _ACDSplashPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor;
}
