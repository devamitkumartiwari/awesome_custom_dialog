import 'package:flutter/material.dart';

/// Visual style variant for a toast card. Resolved against the toast's base
/// color to decide the actual fill/border treatment — see
/// [ACDToastStyleX.resolve].
enum ACDToastStyle {
  /// Solid background fill (the default — matches this package's original
  /// plain-toast look).
  filled,

  /// No fill — outlined only, in the base color.
  flat,

  /// Tinted, translucent fill with a matching subtle outline.
  flatColored,

  /// No fill and no outline — just the icon/text/progress bar.
  minimal,

  /// A compact single-line layout with a solid fill and no icon bubble.
  simple,
}

/// The resolved fill/border for one [ACDToastStyle], given a base color.
typedef ACDToastStyleResolved = ({Color? fill, BorderSide? border});

/// Resolves each [ACDToastStyle] variant's default decoration.
extension ACDToastStyleX on ACDToastStyle {
  /// Resolves this style against [baseColor] into a fill color and border,
  /// both nullable ([BoxDecoration]-ready). An explicit `border`/`boxShadow`
  /// on [ACDToastConfig] always takes precedence over what this returns —
  /// see `ACDToastCard`.
  ACDToastStyleResolved resolve(Color baseColor) => switch (this) {
    ACDToastStyle.filled => (fill: baseColor, border: null),
    ACDToastStyle.simple => (fill: baseColor, border: null),
    ACDToastStyle.flat => (
      fill: null,
      border: BorderSide(color: baseColor, width: 1.5),
    ),
    ACDToastStyle.flatColored => (
      fill: baseColor.withValues(alpha: 0.12),
      border: BorderSide(color: baseColor.withValues(alpha: 0.4)),
    ),
    ACDToastStyle.minimal => (fill: null, border: null),
  };
}
