class PoemState {
  final bool isProcessing;
  final String? error;
  final String? actionType;
  final Map<String, bool> likedStates;
  final Map<String, bool> favoritedStates;
  final String? lastToggledPoemId;

  PoemState({
    this.isProcessing = false,
    this.error,
    this.actionType,
    this.likedStates = const {},
    this.favoritedStates = const {},
    this.lastToggledPoemId,
  });

  PoemState copyWith({
    bool? isProcessing,
    String? error,
    String? actionType,
    Map<String, bool>? likedStates,
    Map<String, bool>? favoritedStates,
    String? lastToggledPoemId,
  }) {
    return PoemState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      actionType: actionType ?? this.actionType,
      likedStates: likedStates ?? this.likedStates,
      favoritedStates: favoritedStates ?? this.favoritedStates,
      lastToggledPoemId: lastToggledPoemId ?? this.lastToggledPoemId,
    );
  }
}
