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
    this.retry = 'Retry',
    this.errorMessage = 'Something went wrong.',
    this.searchHint = 'Search...',
    this.noResultsFor = _defaultNoResultsFor,
    this.successTitle = 'Success',
    this.errorTitle = 'Error',
    this.warningTitle = 'Warning',
    this.infoTitle = 'Info',
    this.undo = 'Undo',
    this.resendCode = 'Resend code',
    this.selectAll = 'Select all',
    this.create = 'Create',
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

  /// Retry action label (e.g. after a failed page load).
  final String retry;

  /// Generic error shown when a search or load fails.
  final String errorMessage;

  /// Placeholder of Material search fields.
  final String searchHint;

  /// Shown when a search finds nothing: `(query)`.
  final String Function(String query) noResultsFor;

  /// Default title of the success() preset.
  final String successTitle;

  /// Default title of the error() preset.
  final String errorTitle;

  /// Default title of the warning() preset.
  final String warningTitle;

  /// Default title of the info() preset.
  final String infoTitle;

  /// Undo action label (undo toasts).
  final String undo;

  /// Label of ACDResendCountdown's button.
  final String resendCode;

  /// Select-all row of multi-select lists.
  final String selectAll;

  /// Prefix of the create-item row: Create "query".
  final String create;

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

  static String _defaultNoResultsFor(String query) => 'No results for "$query"';

  /// English defaults.
  static const ACDStrings english = ACDStrings();

  /// Returns a copy with the given values replaced — handy for overriding
  /// a few strings on top of [english] or another set.
  ACDStrings copyWith({
    String? ok,
    String? cancel,
    String? done,
    String? close,
    String? clear,
    String? search,
    String? noMatches,
    String? loading,
    String? dialogLabel,
    String? on,
    String? off,
    String Function(int count)? resultsAnnouncement,
    String Function(int filled, int length)? pinFieldLabel,
    String Function(int index, int count, String status)? stepLabel,
    String Function(double rating, int max)? ratingLabel,
    String Function(String item)? removeItemLabel,
    String Function(String item)? itemRemovedAnnouncement,
    String Function(int hidden)? moreItemsLabel,
    String? retry,
    String? errorMessage,
    String? searchHint,
    String Function(String query)? noResultsFor,
    String? successTitle,
    String? errorTitle,
    String? warningTitle,
    String? infoTitle,
    String? undo,
    String? resendCode,
    String? selectAll,
    String? create,
  }) {
    return ACDStrings(
      ok: ok ?? this.ok,
      cancel: cancel ?? this.cancel,
      done: done ?? this.done,
      close: close ?? this.close,
      clear: clear ?? this.clear,
      search: search ?? this.search,
      noMatches: noMatches ?? this.noMatches,
      loading: loading ?? this.loading,
      dialogLabel: dialogLabel ?? this.dialogLabel,
      on: on ?? this.on,
      off: off ?? this.off,
      resultsAnnouncement: resultsAnnouncement ?? this.resultsAnnouncement,
      pinFieldLabel: pinFieldLabel ?? this.pinFieldLabel,
      stepLabel: stepLabel ?? this.stepLabel,
      ratingLabel: ratingLabel ?? this.ratingLabel,
      removeItemLabel: removeItemLabel ?? this.removeItemLabel,
      itemRemovedAnnouncement:
          itemRemovedAnnouncement ?? this.itemRemovedAnnouncement,
      moreItemsLabel: moreItemsLabel ?? this.moreItemsLabel,
      retry: retry ?? this.retry,
      errorMessage: errorMessage ?? this.errorMessage,
      searchHint: searchHint ?? this.searchHint,
      noResultsFor: noResultsFor ?? this.noResultsFor,
      successTitle: successTitle ?? this.successTitle,
      errorTitle: errorTitle ?? this.errorTitle,
      warningTitle: warningTitle ?? this.warningTitle,
      infoTitle: infoTitle ?? this.infoTitle,
      undo: undo ?? this.undo,
      resendCode: resendCode ?? this.resendCode,
      selectAll: selectAll ?? this.selectAll,
      create: create ?? this.create,
    );
  }

  // Value equality, so a non-const ACDStrings passed to ACDDesignScope on
  // every rebuild doesn't needlessly rebuild every dependent widget.
  // Function-valued fields compare by identity.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ACDStrings &&
        other.ok == ok &&
        other.cancel == cancel &&
        other.done == done &&
        other.close == close &&
        other.clear == clear &&
        other.search == search &&
        other.noMatches == noMatches &&
        other.loading == loading &&
        other.dialogLabel == dialogLabel &&
        other.on == on &&
        other.off == off &&
        other.resultsAnnouncement == resultsAnnouncement &&
        other.pinFieldLabel == pinFieldLabel &&
        other.stepLabel == stepLabel &&
        other.ratingLabel == ratingLabel &&
        other.removeItemLabel == removeItemLabel &&
        other.itemRemovedAnnouncement == itemRemovedAnnouncement &&
        other.moreItemsLabel == moreItemsLabel &&
        other.retry == retry &&
        other.errorMessage == errorMessage &&
        other.searchHint == searchHint &&
        other.noResultsFor == noResultsFor &&
        other.successTitle == successTitle &&
        other.errorTitle == errorTitle &&
        other.warningTitle == warningTitle &&
        other.infoTitle == infoTitle &&
        other.undo == undo &&
        other.resendCode == resendCode &&
        other.selectAll == selectAll &&
        other.create == create;
  }

  @override
  int get hashCode => Object.hashAll([
    ok,
    cancel,
    done,
    close,
    clear,
    search,
    noMatches,
    loading,
    dialogLabel,
    on,
    off,
    resultsAnnouncement,
    pinFieldLabel,
    stepLabel,
    ratingLabel,
    removeItemLabel,
    itemRemovedAnnouncement,
    moreItemsLabel,
    retry,
    errorMessage,
    searchHint,
    noResultsFor,
    successTitle,
    errorTitle,
    warningTitle,
    infoTitle,
    undo,
    resendCode,
    selectAll,
    create,
  ]);
}
