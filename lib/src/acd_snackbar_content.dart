import 'package:flutter/material.dart';

import 'acd_content_type.dart';

// ── ACDSnackbarContent ────────────────────────────────────────────────────────
// FEAT-16: awesome_snackbar_content parity. Standalone widget — usable
// directly inside a real SnackBar/ScaffoldMessenger/MaterialBanner exactly
// like the source package, or via the ACDDialog.snackbar() convenience
// factory (see acd_dialog.dart). The source package renders its icon bubble
// and decorative corner "splash" with bundled SVG assets; this package stays
// dependency-free (no flutter_svg/asset pipeline), so both are reproduced
// with plain Flutter primitives (Icon + CustomPaint) instead.

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
    this.icon,
    this.titleTextStyle,
    this.messageTextStyle,
    this.borderRadius = 20.0,
    this.padding,
    this.inMaterialBanner = false,
    this.onClose,
    this.closeIcon = Icons.close_rounded,
  });

  /// The banner's bold heading.
  final String title;

  /// The banner's body text.
  final String message;

  /// Which ready-made look to use (also picks the default [color]/[icon]).
  final ACDContentType contentType;

  /// Overrides the background color implied by [contentType].
  final Color? color;

  /// Overrides the icon implied by [contentType].
  final IconData? icon;

  /// Full style control for the title, merged over the default white/bold
  /// style.
  final TextStyle? titleTextStyle;

  /// Full style control for the message, merged over the default white
  /// style.
  final TextStyle? messageTextStyle;

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

  @override
  Widget build(BuildContext context) {
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
                  color: resolvedColor,
                  borderRadius: BorderRadius.circular(borderRadius),
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
                padding: const EdgeInsets.fromLTRB(70, 5, 12, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 22 : 18,
                              fontWeight: FontWeight.w600,
                            ).merge(titleTextStyle),
                          ),
                        ),
                        IconButton(
                          icon: Icon(closeIcon, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed:
                              onClose ??
                              () =>
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
                        ).merge(messageTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Icon bubble (back.svg + type-icon stand-in)
            Positioned(
              left: 16,
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
