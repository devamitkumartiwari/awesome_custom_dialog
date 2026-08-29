/// How [ACDRatingBar] renders its default (non-`itemBuilder`) item.
enum ACDRatingIconStyle {
  /// `Icon` glyphs (`filledIcon`/`halfIcon`/`emptyIcon`) — the default.
  glyph,

  /// A vector star polygon via Flutter's built-in `StarBorder` `ShapeBorder`
  /// (`starPoints`/`starPointRounding`/`starInnerRadiusRatio`), instead of a
  /// font glyph.
  vectorStar,
}
