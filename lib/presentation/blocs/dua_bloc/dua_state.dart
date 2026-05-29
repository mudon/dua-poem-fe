class DuaState {
  final bool isProcessing;
  final String? error;
  final String? actionType;
  final Map<String, bool> likedStates;
  final Map<String, bool> favoritedStates;
  final String? lastToggledDuaId;

  DuaState({
    this.isProcessing = false,
    this.error,
    this.actionType,
    this.likedStates = const {},
    this.favoritedStates = const {},
    this.lastToggledDuaId,
  });

  DuaState copyWith({
    bool? isProcessing,
    String? error,
    String? actionType,
    Map<String, bool>? likedStates,
    Map<String, bool>? favoritedStates,
    String? lastToggledDuaId,
  }) {
    return DuaState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      actionType: actionType ?? this.actionType,
      likedStates: likedStates ?? this.likedStates,
      favoritedStates: favoritedStates ?? this.favoritedStates,
      lastToggledDuaId: lastToggledDuaId ?? this.lastToggledDuaId,
    );
  }
}
