/// The search lifecycle for `ACDSearchableListTile`, exhaustively handled
/// via a `switch` expression — see `acd_searchable_list_tile.dart`.
sealed class ACDSearchState<T> {
  const ACDSearchState();
}

/// No search performed yet (or the query was just cleared) — shows [items],
/// i.e. the caller-supplied base/initial dataset.
final class ACDSearchIdle<T> extends ACDSearchState<T> {
  /// Creates an [ACDSearchIdle] state holding the base [items].
  const ACDSearchIdle(this.items);

  /// The unfiltered base dataset.
  final List<T> items;
}

/// A search (local filter or `onFind`) is in flight.
final class ACDSearchLoading<T> extends ACDSearchState<T> {
  /// Creates an [ACDSearchLoading] state.
  const ACDSearchLoading();
}

/// Search completed with at least one match.
final class ACDSearchLoaded<T> extends ACDSearchState<T> {
  /// Creates an [ACDSearchLoaded] state holding the matching [items].
  const ACDSearchLoaded(this.items);

  /// The matching results.
  final List<T> items;
}

/// Search completed with zero matches for [query].
final class ACDSearchEmpty<T> extends ACDSearchState<T> {
  /// Creates an [ACDSearchEmpty] state for the given [query].
  const ACDSearchEmpty(this.query);

  /// The query that produced no results.
  final String query;
}

/// `onFind` threw while searching for [query]. [stackTrace] is preserved for
/// callers that want to log it from their `errorBuilder`.
final class ACDSearchError<T> extends ACDSearchState<T> {
  /// Creates an [ACDSearchError] state.
  const ACDSearchError(this.error, this.query, [this.stackTrace]);

  /// The error thrown by `onFind`.
  final Object error;

  /// The query that was being searched for when [error] was thrown.
  final String query;

  /// The stack trace captured alongside [error], if any.
  final StackTrace? stackTrace;
}
