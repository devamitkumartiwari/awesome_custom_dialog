import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';

import '../core/acd_content_type.dart';
import '../core/acd_gravity.dart';
import 'acd_toast_close_button_mode.dart';
import 'acd_toast_config.dart';
import 'acd_toast_controller.dart';
import 'acd_toast_dismiss_reason.dart';
import 'acd_toast_progress_bar.dart';
import 'acd_toast_style.dart';

/// The actual visual toast card: style-variant background, icon, message,
/// close button, optional actions row and progress bar. Built from a fully
/// [ACDToastConfig.resolve]d config, so every field it reads is guaranteed
/// non-null for anything [ACDToastConfig.fallback] provides a default for.
class ACDToastCard extends StatefulWidget {
  /// Creates an [ACDToastCard].
  const ACDToastCard({
    super.key,
    required this.config,
    required this.controller,
    required this.onDismissRequested,
  });

  /// This toast's fully-resolved configuration.
  final ACDToastConfig config;

  /// The owning controller — read for its [ACDToastController.pause]/
  /// [ACDToastController.resume] (pause-on-hover) and
  /// [ACDToastController.progressController] (progress bar).
  final ACDToastController controller;

  /// Called to request this toast be dismissed (tap/close-button/drag).
  final void Function({bool immediate, ACDToastDismissReason reason})
  onDismissRequested;

  @override
  State<ACDToastCard> createState() => _ACDToastCardState();
}

/// The light-theme default toast fill (unchanged since 1.x).
const Color _kLightDefaultFill = Color(0xDD000000);

class _ACDToastCardState extends State<ACDToastCard> {
  bool _hovering = false;

  ACDToastConfig get _config => widget.config;

  @override
  Widget build(BuildContext context) {
    if (_config.customBuilder != null) {
      return _config.customBuilder!(
        context,
        _config,
        () => widget.onDismissRequested(reason: ACDToastDismissReason.user),
      );
    }

    final ACDResolvedDesign design = ACDDesign.resolve(context, _config.design);
    // iOS HUD look: a translucent, blurred pill — used for Cupertino when the
    // caller hasn't styled the toast themselves.
    final bool iosHud =
        design.isCupertino &&
        _config.backgroundColor == null &&
        _config.contentType == null &&
        _config.backgroundGradient == null &&
        _config.decoration == null &&
        _config.shape == null &&
        _config.style == null;
    final ACDDesignTokens? tokens = iosHud
        ? ACDDesignTokens.of(context, design)
        : null;

    // The plain default toast (no colour, no content type): near-black in a
    // light theme as always, but the inverse surface in a dark theme — a
    // black toast on a dark screen barely shows.
    final bool plainDefault =
        _config.backgroundColor == null && _config.contentType == null;
    final ThemeData theme = Theme.of(context);
    final bool darkDefault =
        plainDefault && theme.brightness == Brightness.dark;
    final Color baseColor =
        _config.backgroundColor ??
        _config.contentType?.color ??
        (darkDefault ? theme.colorScheme.inverseSurface : _kLightDefaultFill);
    final ACDToastStyle style = _config.style ?? ACDToastStyle.filled;
    final ACDToastStyleResolved resolved = style.resolve(baseColor);
    final Color textColor =
        _config.textColor ??
        tokens?.onSurface ??
        (darkDefault ? theme.colorScheme.onInverseSurface : Colors.white);

    final Color? effectiveFill = tokens != null
        ? tokens.surfaceContainer.withValues(alpha: 0.82)
        : (_config.backgroundGradient == null ? resolved.fill : null);
    final BorderSide? effectiveBorder =
        _config.border ??
        (_config.borderColor != null
            ? BorderSide(
                color: _config.borderColor!,
                width:
                    _config.borderWidth ?? ACDToastConfig.fallback.borderWidth!,
              )
            : resolved.border);
    final BorderRadius effectiveRadius =
        _config.cornerRadius ??
        BorderRadius.circular(
          _config.borderRadius ??
              (iosHud ? 22 : ACDToastConfig.fallback.borderRadius!),
        );

    // Always wrapped in a surface that supplies a text style — without one,
    // Text inside falls back to Flutter's debug-mode placeholder style
    // (yellow text, double yellow underline). Material: a Material (as
    // before); Cupertino: clip + Cupertino text style, no Material needed.
    Widget card;
    if (_config.shape != null) {
      card = ACDAdaptiveSurface(
        design: design,
        shape: _config.shape,
        color: effectiveFill ?? Colors.transparent,
        child: _buildInner(context, textColor, null, design),
      );
    } else {
      Widget inner = _buildInner(
        context,
        textColor,
        _config.decoration ??
            BoxDecoration(
              color: effectiveFill,
              gradient: _config.backgroundGradient,
              border: effectiveBorder != null
                  ? Border.fromBorderSide(effectiveBorder)
                  : null,
            ),
        design,
      );
      if (iosHud) {
        inner = BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: inner,
        );
      }
      card = ACDAdaptiveSurface(
        design: design,
        borderRadius: effectiveRadius,
        child: inner,
      );
    }

    // Shadow always on the outermost, unclipped layer — a clip wrapper
    // around the fill (above) must never also clip this away.
    Widget result = Container(
      decoration: BoxDecoration(boxShadow: _config.boxShadow),
      child: card,
    );

    // Hover only changes what's drawn in onHover close-button mode — skip
    // the rebuild otherwise.
    final bool hoverAffectsUi =
        _config.closeButtonMode == ACDToastCloseButtonMode.onHover;
    result = MouseRegion(
      onEnter: (_) {
        if (hoverAffectsUi) setState(() => _hovering = true);
        if (_config.pauseOnHover ?? false) widget.controller.pause();
      },
      onExit: (_) {
        if (hoverAffectsUi) setState(() => _hovering = false);
        if (_config.pauseOnHover ?? false) widget.controller.resume();
      },
      child: (_config.dismissOnTap ?? false)
          ? GestureDetector(
              onTap: () {
                _config.onTap?.call();
                widget.onDismissRequested(reason: ACDToastDismissReason.user);
              },
              child: result,
            )
          : (_config.onTap != null
                ? GestureDetector(onTap: _config.onTap, child: result)
                : result),
    );

    if (_config.pauseOnHover ?? false) {
      // Touch has no hover: holding a finger on the toast pauses it too.
      result = Listener(
        onPointerDown: (PointerDownEvent e) {
          if (e.kind != ui.PointerDeviceKind.mouse) widget.controller.pause();
        },
        onPointerUp: (PointerUpEvent e) {
          if (e.kind != ui.PointerDeviceKind.mouse) widget.controller.resume();
        },
        onPointerCancel: (PointerCancelEvent e) {
          if (e.kind != ui.PointerDeviceKind.mouse) widget.controller.resume();
        },
        child: result,
      );
    }

    if (_config.dragToDismiss ?? false) {
      void swiped(DismissDirection _) => widget.onDismissRequested(
        immediate: true,
        reason: ACDToastDismissReason.swipe,
      );
      result = Dismissible(
        key: ObjectKey(widget.controller),
        direction: DismissDirection.horizontal,
        onDismissed: swiped,
        child: result,
      );
      // Top/bottom toasts can also be flicked off their own edge.
      final DismissDirection? vertical = switch (_config.gravity) {
        ACDGravity.top ||
        ACDGravity.leftTop ||
        ACDGravity.rightTop => DismissDirection.up,
        ACDGravity.bottom ||
        ACDGravity.leftBottom ||
        ACDGravity.rightBottom => DismissDirection.down,
        _ => null,
      };
      if (vertical != null) {
        result = Dismissible(
          key: ValueKey<Object>((widget.controller, 'vertical')),
          direction: vertical,
          onDismissed: swiped,
          child: result,
        );
      }
    }

    // One announcement: the label carries the message and only the visible
    // message Text is excluded (so it isn't read twice) — the close button
    // and any actions stay reachable for screen-reader users.
    return Semantics(
      container: true,
      liveRegion: true,
      label: _config.message,
      child: result,
    );
  }

  @override
  void didUpdateWidget(covariant ACDToastCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A live update (e.g. a promise toast settling) is news: announce it.
    if (oldWidget.config.message != widget.config.message &&
        widget.config.customBuilder == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) acdAnnounce(context, widget.config.message);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // iOS VoiceOver ignores liveRegion — announce explicitly once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _config.customBuilder == null) {
        acdAnnounce(context, _config.message);
      }
    });
  }

  Widget _buildInner(
    BuildContext context,
    Color textColor,
    Decoration? decoration,
    ACDResolvedDesign design,
  ) {
    final IconData? resolvedIcon = _config.icon ?? _config.contentType?.icon;
    final bool showIcon = (_config.showIcon ?? true) && resolvedIcon != null;
    final ACDToastCloseButtonMode closeMode =
        _config.closeButtonMode ?? ACDToastCloseButtonMode.never;
    final bool showClose =
        closeMode == ACDToastCloseButtonMode.always ||
        (closeMode == ACDToastCloseButtonMode.onHover && _hovering);

    final Widget messageWidget = ExcludeSemantics(
      child: Text(
        _config.message,
        style: TextStyle(
          color: textColor,
          fontSize: _config.fontSize ?? ACDToastConfig.fallback.fontSize!,
          fontFamily: _config.fontFamily,
        ).merge(_config.textStyle),
      ),
    );

    final Widget contentRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_config.showLoadingIndicator ?? false) ...[
          ACDAdaptiveProgress(
            design: ACDDesign.resolve(context, _config.design),
            size: 18,
            strokeWidth: 2,
            color: textColor,
            semanticsLabel: ACDDesignScope.stringsOf(context).loading,
          ),
          const SizedBox(width: 8),
        ] else if (showIcon) ...[
          (_config.animatedIcon ?? false)
              ? _ACDPulsingIcon(icon: resolvedIcon, color: textColor)
              : Icon(resolvedIcon, color: textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              messageWidget,
              if (_config.actions != null && _config.actions!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _config.actions!,
                  ),
                ),
            ],
          ),
        ),
        // Reserves layout space only when a close button can ever show —
        // never() removes the slot entirely rather than hiding an
        // invisible button, which would otherwise leave a dead gap.
        if (closeMode != ACDToastCloseButtonMode.never) ...[
          // No extra spacer: the 48/44 tap box already pads the glyph.
          Opacity(
            opacity: showClose ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !showClose,
              child: Semantics(
                // Its own node — not merged into the toast's message label.
                container: true,
                button: true,
                label: ACDDesignScope.stringsOf(context).close,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _config.onCloseButtonTap?.call();
                    widget.onDismissRequested(
                      reason: ACDToastDismissReason.user,
                    );
                  },
                  // 48 dp / 44 pt hit area around the 18 px glyph.
                  child: ACDTapTargetBox(
                    design: design,
                    child: Icon(
                      _config.closeIcon ??
                          (design.isCupertino
                              ? ACDIcon.close.of(design)
                              : ACDToastConfig.fallback.closeIcon!),
                      color: textColor,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    final Widget content = Container(
      width: _config.width,
      height: _config.height,
      constraints: _config.constraints,
      padding:
          _config.contentPadding ?? ACDToastConfig.fallback.contentPadding!,
      decoration: decoration,
      child: contentRow,
    );

    if (!(_config.showProgressBar ?? false) ||
        widget.controller.progressController == null) {
      return content;
    }

    final Widget bar = ACDToastProgressBar(
      controller: widget.controller.progressController!,
      color: textColor,
    );
    final bool atTop = _config.progressBarAtTop ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: atTop ? [bar, content] : [content, bar],
    );
  }
}

class _ACDPulsingIcon extends StatefulWidget {
  const _ACDPulsingIcon({required this.icon, required this.color});

  final IconData? icon;
  final Color color;

  @override
  State<_ACDPulsingIcon> createState() => _ACDPulsingIconState();
}

class _ACDPulsingIconState extends State<_ACDPulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  // Built once — not per build (a CurvedAnimation per build would leak a
  // listener on the controller every rebuild).
  late final Animation<double> _scale = Tween<double>(
    begin: 0.85,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // An endless pulse is exactly what reduce-motion users opt out of.
    if (acdReduceMotion(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scale,
        child: Icon(widget.icon, color: widget.color, size: 20),
      ),
    );
  }
}
