import '../../../data/models/poem_model.dart';

class PoemFeedState {
  final bool isLoading;
  final String? error;
  final List<PoemModel> windowPoems;
  final int totalLoadedPoems;
  final String? olderCursorPoems;
  final bool hasMoreOlderPoems;
  final bool loadingOlderPoems;

  PoemFeedState({
    this.isLoading = true,
    this.error,
    this.windowPoems = const [],
    this.totalLoadedPoems = 0,
    this.olderCursorPoems,
    this.hasMoreOlderPoems = true,
    this.loadingOlderPoems = false,
  });

  PoemFeedState copyWith({
    bool? isLoading,
    String? error,
    List<PoemModel>? windowPoems,
    int? totalLoadedPoems,
    String? olderCursorPoems,
    bool? hasMoreOlderPoems,
    bool? loadingOlderPoems,
    bool clearError = false,
  }) {
    return PoemFeedState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      windowPoems: windowPoems ?? this.windowPoems,
      totalLoadedPoems: totalLoadedPoems ?? this.totalLoadedPoems,
      olderCursorPoems: olderCursorPoems ?? this.olderCursorPoems,
      hasMoreOlderPoems: hasMoreOlderPoems ?? this.hasMoreOlderPoems,
      loadingOlderPoems: loadingOlderPoems ?? this.loadingOlderPoems,
    );
  }
}
