import '../../../data/models/dua_model.dart';
import '../../../data/models/signalr/dua_content_update_model.dart';

class DuaState {
  final bool isProcessing;
  final String? error;
  final String? actionType;
  final Map<String, bool> likedStates;
  final Map<String, bool> favoritedStates;
  final Map<String, int> likeCounts;
  final Map<String, int> bookmarkCounts;
  final Map<String, int> viewCounts;
  final Map<String, int> reportCounts;
  final Map<String, DuaContentUpdateModel?> contentUpdates;
  final Set<String> returnedReportIds;
  final String? lastToggledDuaId;
  final DuaModel? createdDua;

  DuaState({
    this.isProcessing = false,
    this.error,
    this.actionType,
    this.likedStates = const {},
    this.favoritedStates = const {},
    this.likeCounts = const {},
    this.bookmarkCounts = const {},
    this.viewCounts = const {},
    this.reportCounts = const {},
    this.contentUpdates = const {},
    this.returnedReportIds = const {},
    this.lastToggledDuaId,
    this.createdDua,
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
    Map<String, int>? reportCounts,
    Map<String, DuaContentUpdateModel?>? contentUpdates,
    Set<String>? returnedReportIds,
    String? lastToggledDuaId,
    DuaModel? createdDua,
  }) {
    return DuaState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      actionType: actionType,
      likedStates: likedStates ?? this.likedStates,
      favoritedStates: favoritedStates ?? this.favoritedStates,
      likeCounts: likeCounts ?? this.likeCounts,
      bookmarkCounts: bookmarkCounts ?? this.bookmarkCounts,
      viewCounts: viewCounts ?? this.viewCounts,
      reportCounts: reportCounts ?? this.reportCounts,
      contentUpdates: contentUpdates ?? this.contentUpdates,
      returnedReportIds: returnedReportIds ?? this.returnedReportIds,
      lastToggledDuaId: lastToggledDuaId ?? this.lastToggledDuaId,
      createdDua: createdDua,
    );
  }
}
