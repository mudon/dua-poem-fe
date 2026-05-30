class PoemState {
  final bool isProcessing;
  final String? error;
  final String? actionType;
  final Map<String, bool> likedStates;
  final Map<String, bool> favoritedStates;
  final Map<String, int> likeCounts;
  final Map<String, int> bookmarkCounts;
  final String? lastToggledPoemId;

  PoemState({
    this.isProcessing = false,
    this.error,
    this.actionType,
    this.likedStates = const {},
    this.favoritedStates = const {},
    this.likeCounts = const {},
    this.bookmarkCounts = const {},
    this.lastToggledPoemId,
  });

  PoemState copyWith({
    bool? isProcessing,
    String? error,
    String? actionType,
    Map<String, bool>? likedStates,
    Map<String, bool>? favoritedStates,
    Map<String, int>? likeCounts,
    Map<String, int>? bookmarkCounts,
    String? lastToggledPoemId,
  }) {
    return PoemState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      actionType: actionType ?? this.actionType,
      likedStates: likedStates ?? this.likedStates,
      favoritedStates: favoritedStates ?? this.favoritedStates,
      likeCounts: likeCounts ?? this.likeCounts,
      bookmarkCounts: bookmarkCounts ?? this.bookmarkCounts,
      lastToggledPoemId: lastToggledPoemId ?? this.lastToggledPoemId,
    );
  }
}
