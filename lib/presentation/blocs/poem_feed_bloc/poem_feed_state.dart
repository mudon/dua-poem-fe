import '../../../data/models/poem_model.dart';

class PoemFeedState {
  final bool isLoading;
  final String? error;
  final List<PoemModel> windowPoems;
  final int windowPoemsStart;
  final int totalLoadedPoems;
  final String? latterCursorPoems;
  final String? olderCursorPoems;
  final bool hasMoreLatterPoems;
  final bool hasMoreOlderPoems;
  final bool loadingLatterPoems;
  final bool loadingOlderPoems;

  PoemFeedState({
    this.isLoading = true,
    this.error,
    this.windowPoems = const [],
    this.windowPoemsStart = 0,
    this.totalLoadedPoems = 0,
    this.latterCursorPoems,
    this.olderCursorPoems,
    this.hasMoreLatterPoems = false,
    this.hasMoreOlderPoems = true,
    this.loadingLatterPoems = false,
    this.loadingOlderPoems = false,
  });

  PoemFeedState copyWith({
    bool? isLoading,
    String? error,
    List<PoemModel>? windowPoems,
    int? windowPoemsStart,
    int? totalLoadedPoems,
    String? latterCursorPoems,
    String? olderCursorPoems,
    bool? hasMoreLatterPoems,
    bool? hasMoreOlderPoems,
    bool? loadingLatterPoems,
    bool? loadingOlderPoems,
    bool clearError = false,
  }) {
    return PoemFeedState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      windowPoems: windowPoems ?? this.windowPoems,
      windowPoemsStart: windowPoemsStart ?? this.windowPoemsStart,
      totalLoadedPoems: totalLoadedPoems ?? this.totalLoadedPoems,
      latterCursorPoems: latterCursorPoems ?? this.latterCursorPoems,
      olderCursorPoems: olderCursorPoems ?? this.olderCursorPoems,
      hasMoreLatterPoems: hasMoreLatterPoems ?? this.hasMoreLatterPoems,
      hasMoreOlderPoems: hasMoreOlderPoems ?? this.hasMoreOlderPoems,
      loadingLatterPoems: loadingLatterPoems ?? this.loadingLatterPoems,
      loadingOlderPoems: loadingOlderPoems ?? this.loadingOlderPoems,
    );
  }
}
