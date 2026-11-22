import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_platform_support.dart';

/// The grab handle at the top of an `ACDDialog.bottomSheet()`.
class ACDSheetHandle extends StatelessWidget {
  /// Creates an [ACDSheetHandle] in [design].
  const ACDSheetHandle({super.key, required this.design});

  /// The resolved design (Material 3 or iOS proportions).
  final ACDResolvedDesign design;

  @override
  Widget build(BuildContext context) {
    final ACDDesignTokens tokens = ACDDesignTokens.of(context, design);
    final bool cupertino = design.isCupertino;
    return ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.only(top: cupertino ? 6 : 16, bottom: 8),
        child: Center(
          child: Container(
            width: cupertino ? 36 : 32,
            height: cupertino ? 5 : 4,
            decoration: BoxDecoration(
              color: tokens.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets a bottom sheet be dragged down: past [dismissFraction] of its
/// height (or on a downward flick) it calls [onDismiss]; otherwise it
/// springs back. Dragging up is resisted, never moves the sheet above its
/// resting position.
class ACDSheetDrag extends StatefulWidget {
  /// Creates an [ACDSheetDrag].
  const ACDSheetDrag({
    super.key,
    required this.child,
    required this.onDismiss,
    this.enabled = true,
    this.dismissFraction = 0.35,
  });

  /// The sheet.
  final Widget child;

  /// Called once the user drags/flings the sheet away.
  final VoidCallback onDismiss;

  /// Whether dragging is allowed at all.
  final bool enabled;

  /// How far down (as a fraction of the sheet's height) a release must be
  /// to dismiss.
  final double dismissFraction;

  @override
  State<ACDSheetDrag> createState() => _ACDSheetDragState();
}

class _ACDSheetDragState extends State<ACDSheetDrag>
    with SingleTickerProviderStateMixin {
  late final AnimationController _offset = AnimationController.unbounded(
    vsync: this,
  );
  final GlobalKey _sheetKey = GlobalKey();
  bool _dismissed = false;

  double get _height => _sheetKey.currentContext?.size?.height ?? 1;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _onUpdate(DragUpdateDetails d) {
    if (_dismissed) return;
    _offset.value = (_offset.value + d.delta.dy).clamp(0.0, double.infinity);
  }

  void _onEnd(DragEndDetails d) {
    if (_dismissed) return;
    final double velocity = d.primaryVelocity ?? 0;
    final bool dismiss =
        velocity > 700 || _offset.value > _height * widget.dismissFraction;
    if (dismiss) {
      _dismissed = true;
      widget.onDismiss();
      return;
    }
    if (acdReduceMotion(context)) {
      _offset.value = 0;
      return;
    }
    _offset.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 500, damping: 40),
        _offset.value,
        0,
        velocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return GestureDetector(
      onVerticalDragUpdate: _onUpdate,
      onVerticalDragEnd: _onEnd,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _offset.value.clamp(0.0, double.infinity)),
          child: child,
        ),
        child: KeyedSubtree(key: _sheetKey, child: widget.child),
      ),
    );
  }
}
