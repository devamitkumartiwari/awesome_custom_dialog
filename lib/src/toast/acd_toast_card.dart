import 'package:flutter/material.dart';

import '../core/acd_content_type.dart';
import 'acd_toast_close_button_mode.dart';
import 'acd_toast_config.dart';
import 'acd_toast_controller.dart';
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
  final void Function({bool immediate}) onDismissRequested;

  @override
  State<ACDToastCard> createState() => _ACDToastCardState();
}

class _ACDToastCardState extends State<ACDToastCard> {
  bool _hovering = false;

  ACDToastConfig get _config => widget.config;

  @override
  Widget build(BuildContext context) {
    if (_config.customBuilder != null) {
      return _config.customBuilder!(
        context,
        _config,
        () => widget.onDismissRequested(),
      );
    }

    final Color baseColor =
        _config.backgroundColor ??
        _config.contentType?.color ??
        ACDToastConfig.fallback.backgroundColor!;
    final ACDToastStyle style = _config.style ?? ACDToastStyle.filled;
    final ACDToastStyleResolved resolved = style.resolve(baseColor);
    final Color textColor =
        _config.textColor ?? ACDToastConfig.fallback.textColor!;

    final Color? effectiveFill = _config.backgroundGradient == null
        ? resolved.fill
        : null;
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
          _config.borderRadius ?? ACDToastConfig.fallback.borderRadius!,
        );

    // Always wrapped in a Material ancestor (matching ACDDialog's own
    // _buildContentCard) — without one, Text inside falls back to Flutter's
    // debug-mode placeholder style (yellow text, double yellow underline)
    // instead of an invisible/typography-inherited style.
    Widget card;
    if (_config.shape != null) {
      card = Material(
        shape: _config.shape,
        color: effectiveFill ?? Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: _buildInner(context, textColor, null),
      );
    } else {
      card = Material(
        type: MaterialType.transparency,
        borderRadius: effectiveRadius,
        clipBehavior: Clip.antiAlias,
        child: _buildInner(
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
        ),
      );
    }

    // Shadow always on the outermost, unclipped layer — a clip wrapper
    // around the fill (above) must never also clip this away.
    Widget result = Container(
      decoration: BoxDecoration(boxShadow: _config.boxShadow),
      child: card,
    );

    result = MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        if (_config.pauseOnHover ?? false) widget.controller.pause();
      },
      onExit: (_) {
        setState(() => _hovering = false);
        if (_config.pauseOnHover ?? false) widget.controller.resume();
      },
      child: (_config.dismissOnTap ?? false)
          ? GestureDetector(
              onTap: () {
                _config.onTap?.call();
                widget.onDismissRequested();
              },
              child: result,
            )
          : (_config.onTap != null
                ? GestureDetector(onTap: _config.onTap, child: result)
                : result),
    );

    if (_config.dragToDismiss ?? false) {
      result = Dismissible(
        key: ValueKey('${widget.controller.id}-dismissible'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => widget.onDismissRequested(immediate: true),
        child: result,
      );
    }

    return Semantics(
      container: true,
      liveRegion: true,
      label: _config.message,
      child: result,
    );
  }

  Widget _buildInner(
    BuildContext context,
    Color textColor,
    Decoration? decoration,
  ) {
    final IconData? resolvedIcon = _config.icon ?? _config.contentType?.icon;
    final bool showIcon = (_config.showIcon ?? true) && resolvedIcon != null;
    final ACDToastCloseButtonMode closeMode =
        _config.closeButtonMode ?? ACDToastCloseButtonMode.never;
    final bool showClose =
        closeMode == ACDToastCloseButtonMode.always ||
        (closeMode == ACDToastCloseButtonMode.onHover && _hovering);

    final Widget messageWidget = Text(
      _config.message,
      style: TextStyle(
        color: textColor,
        fontSize: _config.fontSize ?? ACDToastConfig.fallback.fontSize!,
        fontFamily: _config.fontFamily,
      ).merge(_config.textStyle),
    );

    final Widget contentRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIcon) ...[
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
          const SizedBox(width: 8),
          Opacity(
            opacity: showClose ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !showClose,
              child: GestureDetector(
                onTap: () {
                  _config.onCloseButtonTap?.call();
                  widget.onDismissRequested();
                },
                child: Icon(
                  _config.closeIcon ?? ACDToastConfig.fallback.closeIcon!,
                  color: textColor,
                  size: 18,
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
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Icon(widget.icon, color: widget.color, size: 20),
    );
  }
}
