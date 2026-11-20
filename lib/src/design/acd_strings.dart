import 'package:flutter/foundation.dart';

/// User-facing strings used by awesome_custom_dialog widgets.
///
/// Defaults are English. Override app-wide through
/// [ACDDesignScope.strings], e.g. from your own localization setup:
///
/// ```dart
/// ACDDesignScope(
///   strings: ACDStrings(ok: l10n.ok, cancel: l10n.cancel, ...),
///   child: app,
/// )
/// ```
@immutable
class ACDStrings {
  /// Creates a set of strings; every value defaults to English.
  const ACDStrings({
    this.ok = 'OK',
    this.cancel = 'Cancel',
    this.done = 'Done',
    this.close = 'Close',
    this.clear = 'Clear',
    this.search = 'Search',
    this.noMatches = 'No matches',
    this.loading = 'Loading',
    this.dialogLabel = 'Dialog',
    this.on = 'On',
    this.off = 'Off',
    this.resultsAnnouncement = _defaultResults,
    this.pinFieldLabel = _defaultPinLabel,
    this.stepLabel = _defaultStepLabel,
    this.ratingLabel = _defaultRatingLabel,
    this.removeItemLabel = _defaultRemoveItem,
    this.itemRemovedAnnouncement = _defaultItemRemoved,
    this.moreItemsLabel = _defaultMoreItems,
  });

  /// Confirm action label.
  final String ok;

  /// Cancel action label.
  final String cancel;

  /// Done action label (Cupertino multi-select sheets).
  final String done;

  /// Close button tooltip/semantic label.
  final String close;

  /// Clear button tooltip/semantic label.
  final String clear;

  /// Search field placeholder.
  final String search;

  /// Shown when a search finds nothing.
  final String noMatches;

  /// Semantic label for loading indicators.
  final String loading;

  /// Route/barrier semantic label for dialogs.
  final String dialogLabel;

  /// Switch "on" label.
  final String on;

  /// Switch "off" label.
  final String off;

  /// Screen-reader announcement for a result count.
  final String Function(int count) resultsAnnouncement;

  /// Semantic label for a PIN field: `(filled, length)`.
  final String Function(int filled, int length) pinFieldLabel;

  /// Semantic label for a stepper step: `(index, count, status)`.
  final String Function(int index, int count, String status) stepLabel;

  /// Semantic value for a rating bar: `(rating, max)`.
  final String Function(double rating, int max) ratingLabel;

  /// Semantic label of a selection chip's remove button: `(item)`.
  final String Function(String item) removeItemLabel;

  /// Screen-reader announcement after a chip is removed: `(item)`.
  final String Function(String item) itemRemovedAnnouncement;

  /// The overflow chip of a multi-select field: `(hiddenCount)` → "+3".
  final String Function(int hidden) moreItemsLabel;

  static String _defaultResults(int count) => count == 0
      ? 'No results'
      : count == 1
      ? '1 result'
      : '$count results';

  static String _defaultPinLabel(int filled, int length) =>
      'PIN, $filled of $length entered';

  static String _defaultStepLabel(int index, int count, String status) =>
      'Step ${index + 1} of $count, $status';

  static String _defaultRatingLabel(double rating, int max) {
    final String r = rating == rating.roundToDouble()
        ? rating.toInt().toString()
        : rating.toStringAsFixed(1);
    return '$r of $max';
  }

  static String _defaultRemoveItem(String item) => 'Remove $item';

  static String _defaultItemRemoved(String item) => '$item removed';

  static String _defaultMoreItems(int hidden) => '+$hidden';

  /// English defaults.
  static const ACDStrings english = ACDStrings();
}
