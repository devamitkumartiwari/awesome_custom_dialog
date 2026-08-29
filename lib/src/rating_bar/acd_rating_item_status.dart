/// The fill state of one [ACDRatingBar] item, passed to a custom
/// `itemBuilder` alongside the continuous `fillFraction` it's a convenience
/// bucketing of.
enum ACDRatingItemStatus {
  /// Not filled at all (`fillFraction == 0`).
  empty,

  /// Partially filled (`0 < fillFraction < 1`) — reached via `allowHalfRating`
  /// or a fractional `ratingPrecision`.
  half,

  /// Fully filled (`fillFraction == 1`).
  filled,
}
