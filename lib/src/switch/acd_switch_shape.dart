/// The track/thumb shape an [ACDSwitch] renders by default (ignored once
/// `trackBuilder`/`thumbBuilder`/`trackShapeBorder`/`thumbShapeBorder` are
/// supplied and take over).
enum ACDSwitchShape {
  /// A fully-rounded (stadium) track with a circular thumb.
  pill,

  /// A rounded-rectangle track with a rounded-rectangle thumb.
  roundedRectangle,
}
