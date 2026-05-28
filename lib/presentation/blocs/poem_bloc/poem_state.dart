class PoemState {
  final bool isProcessing;
  final String? error;
  final String? actionType;
  final Map<String, bool> likedStates;
  final Map<String, bool> favoritedStates;

  PoemState({
    this.isProcessing = false,
    this.error,
    this.actionType,
    this.likedStates = const {},
    this.favoritedStates = const {},
  });

  PoemState copyWith({
    bool? isProcessing,
    String? error,
    String? actionType,
    Map<String, bool>? likedStates,
    Map<String, bool>? favoritedStates,
  }) {
    return PoemState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      actionType: actionType ?? this.actionType,
      likedStates: likedStates ?? this.likedStates,
      favoritedStates: favoritedStates ?? this.favoritedStates,
    );
  }
}
