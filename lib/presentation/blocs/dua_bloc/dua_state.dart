class DuaState {
  final bool isProcessing;
  final String? error;
  final String? actionType;
  final Map<String, bool> likedStates;
  final Map<String, bool> favoritedStates;
  final Map<String, int> likeCounts;
  final Map<String, int> bookmarkCounts;
  final Map<String, int> viewCounts;
  final String? lastToggledDuaId;

  DuaState({
    this.isProcessing = false,
    this.error,
    this.actionType,
    this.likedStates = const {},
    this.favoritedStates = const {},
    this.likeCounts = const {},
    this.bookmarkCounts = const {},
    this.viewCounts = const {},
    this.lastToggledDuaId,
  });

  DuaState copyWith({
    bool? isProcessing,
    String? error,
    String? actionType,
    Map<String, bool>? likedStates,
    Map<String, bool>? favoritedStates,
    Map<String, int>? likeCounts,
    Map<String, int>? bookmarkCounts,
    Map<String, int>? viewCounts,
    String? lastToggledDuaId,
  }) {
    return DuaState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      actionType: actionType ?? this.actionType,
      likedStates: likedStates ?? this.likedStates,
      favoritedStates: favoritedStates ?? this.favoritedStates,
      likeCounts: likeCounts ?? this.likeCounts,
      bookmarkCounts: bookmarkCounts ?? this.bookmarkCounts,
      viewCounts: viewCounts ?? this.viewCounts,
      lastToggledDuaId: lastToggledDuaId ?? this.lastToggledDuaId,
    );
  }
}
