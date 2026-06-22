import '../../../data/models/dua_model.dart';

class DuaFeedState {
  final bool isLoading;
  final String? error;
  final List<DuaModel> windowDuas;
  final int windowDuasStart;
  final int totalLoadedDuas;
  final String? latterCursorDuas;
  final String? olderCursorDuas;
  final bool hasMoreLatterDuas;
  final bool hasMoreOlderDuas;
  final bool loadingLatterDuas;
  final bool loadingOlderDuas;

  DuaFeedState({
    this.isLoading = true,
    this.error,
    this.windowDuas = const [],
    this.windowDuasStart = 0,
    this.totalLoadedDuas = 0,
    this.latterCursorDuas,
    this.olderCursorDuas,
    this.hasMoreLatterDuas = false,
    this.hasMoreOlderDuas = true,
    this.loadingLatterDuas = false,
    this.loadingOlderDuas = false,
  });

  DuaFeedState copyWith({
    bool? isLoading,
    String? error,
    List<DuaModel>? windowDuas,
    int? windowDuasStart,
    int? totalLoadedDuas,
    String? latterCursorDuas,
    String? olderCursorDuas,
    bool? hasMoreLatterDuas,
    bool? hasMoreOlderDuas,
    bool? loadingLatterDuas,
    bool? loadingOlderDuas,
    bool clearError = false,
  }) {
    return DuaFeedState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      windowDuas: windowDuas ?? this.windowDuas,
      windowDuasStart: windowDuasStart ?? this.windowDuasStart,
      totalLoadedDuas: totalLoadedDuas ?? this.totalLoadedDuas,
      latterCursorDuas: latterCursorDuas ?? this.latterCursorDuas,
      olderCursorDuas: olderCursorDuas ?? this.olderCursorDuas,
      hasMoreLatterDuas: hasMoreLatterDuas ?? this.hasMoreLatterDuas,
      hasMoreOlderDuas: hasMoreOlderDuas ?? this.hasMoreOlderDuas,
      loadingLatterDuas: loadingLatterDuas ?? this.loadingLatterDuas,
      loadingOlderDuas: loadingOlderDuas ?? this.loadingOlderDuas,
    );
  }
}
