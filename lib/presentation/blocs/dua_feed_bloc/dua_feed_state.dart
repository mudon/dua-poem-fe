import '../../../data/models/dua_model.dart';

class DuaFeedState {
  final bool isLoading;
  final String? error;
  final List<DuaModel> windowDuas;
  final int totalLoadedDuas;
  final String? olderCursorDuas;
  final bool hasMoreOlderDuas;
  final bool loadingOlderDuas;

  DuaFeedState({
    this.isLoading = true,
    this.error,
    this.windowDuas = const [],
    this.totalLoadedDuas = 0,
    this.olderCursorDuas,
    this.hasMoreOlderDuas = true,
    this.loadingOlderDuas = false,
  });

  DuaFeedState copyWith({
    bool? isLoading,
    String? error,
    List<DuaModel>? windowDuas,
    int? totalLoadedDuas,
    String? olderCursorDuas,
    bool? hasMoreOlderDuas,
    bool? loadingOlderDuas,
    bool clearError = false,
  }) {
    return DuaFeedState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      windowDuas: windowDuas ?? this.windowDuas,
      totalLoadedDuas: totalLoadedDuas ?? this.totalLoadedDuas,
      olderCursorDuas: olderCursorDuas ?? this.olderCursorDuas,
      hasMoreOlderDuas: hasMoreOlderDuas ?? this.hasMoreOlderDuas,
      loadingOlderDuas: loadingOlderDuas ?? this.loadingOlderDuas,
    );
  }
}
