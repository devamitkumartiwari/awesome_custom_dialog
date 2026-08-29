import 'package:flutter/material.dart';

/// Where a dialog, toast, or snackbar is positioned on screen. Assign to
/// `ACDDialog.gravity`.
enum ACDGravity {
  /// Flush against the left edge, vertically centered.
  left,

  /// Near the top edge, horizontally centered.
  top,

  /// Near the bottom edge, horizontally centered.
  bottom,

  /// Flush against the right edge, vertically centered.
  right,

  /// Centered on screen (the default).
  center,

  /// Top-right corner.
  rightTop,

  /// Top-left corner.
  leftTop,

  /// Bottom-right corner.
  rightBottom,

  /// Bottom-left corner.
  leftBottom,

  /// Only meaningful for button rows (`twoButton`) — spaces buttons evenly.
  spaceEvenly,
}

// Resolve effective margin based on gravity if none provided
EdgeInsets acdResolveMarginForGravity(ACDGravity gravity, EdgeInsets margin) {
  if (margin != EdgeInsets.zero) return margin;
  switch (gravity) {
    case ACDGravity.top:
    case ACDGravity.leftTop:
    case ACDGravity.rightTop:
      return const EdgeInsets.fromLTRB(24, 16, 24, 0);
    case ACDGravity.bottom:
    case ACDGravity.leftBottom:
    case ACDGravity.rightBottom:
      return const EdgeInsets.fromLTRB(24, 0, 24, 16);
    // BUG: left/right gravity (e.g. side panels) previously fell through
    // to the symmetric-horizontal default below, which floats them 24px
    // off the edge they're meant to hug instead of sitting flush against
    // it — inconsistent with the top/bottom cases above, which are flush
    // (0) against their near edge and only inset (24) on the far side.
    case ACDGravity.left:
      return const EdgeInsets.fromLTRB(0, 16, 24, 16);
    case ACDGravity.right:
      return const EdgeInsets.fromLTRB(24, 16, 0, 16);
    default:
      return const EdgeInsets.symmetric(horizontal: 24);
  }
}

Alignment acdGravityToAlignment(ACDGravity g) {
  switch (g) {
    case ACDGravity.top:
      return Alignment.topCenter;
    case ACDGravity.bottom:
      return Alignment.bottomCenter;
    case ACDGravity.left:
      return Alignment.centerLeft;
    case ACDGravity.right:
      return Alignment.centerRight;
    case ACDGravity.leftTop:
      return Alignment.topLeft;
    case ACDGravity.rightTop:
      return Alignment.topRight;
    case ACDGravity.leftBottom:
      return Alignment.bottomLeft;
    case ACDGravity.rightBottom:
      return Alignment.bottomRight;
    case ACDGravity.center:
    case ACDGravity.spaceEvenly:
      return Alignment.center;
  }
}

MainAxisAlignment acdColumnMainAxisAlignment(ACDGravity g) {
  switch (g) {
    case ACDGravity.bottom:
    case ACDGravity.leftBottom:
    case ACDGravity.rightBottom:
      return MainAxisAlignment.end;
    case ACDGravity.top:
    case ACDGravity.leftTop:
    case ACDGravity.rightTop:
      return MainAxisAlignment.start;
    default:
      return MainAxisAlignment.center;
  }
}

CrossAxisAlignment acdColumnCrossAxisAlignment(ACDGravity g) {
  switch (g) {
    case ACDGravity.left:
    case ACDGravity.leftTop:
    case ACDGravity.leftBottom:
      return CrossAxisAlignment.start;
    case ACDGravity.right:
    case ACDGravity.rightTop:
    case ACDGravity.rightBottom:
      return CrossAxisAlignment.end;
    default:
      return CrossAxisAlignment.center;
  }
}

MainAxisAlignment acdRowAlignment(ACDGravity? g) {
  switch (g) {
    case ACDGravity.left:
      return MainAxisAlignment.start;
    case ACDGravity.right:
      return MainAxisAlignment.end;
    case ACDGravity.spaceEvenly:
      return MainAxisAlignment.spaceEvenly;
    default:
      return MainAxisAlignment.center;
  }
}
