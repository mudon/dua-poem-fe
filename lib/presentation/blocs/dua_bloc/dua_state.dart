class DuaState {
  final bool isProcessing;
  final String? error;

  DuaState({this.isProcessing = false, this.error});

  DuaState copyWith({bool? isProcessing, String? error}) {
    return DuaState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}
