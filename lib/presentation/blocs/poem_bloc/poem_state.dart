import '../../../data/models/poem_model.dart';
import '../../../data/models/signalr/poem_content_update_model.dart';

class PoemState {
  final bool isProcessing;
  final String? error;
  final String? actionType;
  final Map<String, bool> likedStates;
  final Map<String, bool> favoritedStates;
  final Map<String, int> likeCounts;
  final Map<String, int> bookmarkCounts;
  final Map<String, int> viewCounts;
  final Map<String, int> reportCounts;
  final Map<String, PoemContentUpdateModel?> contentUpdates;
  final Set<String> returnedReportIds;
  final String? lastToggledPoemId;
  final PoemModel? createdPoem;

  PoemState({
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
    this.lastToggledPoemId,
    this.createdPoem,
  });

  PoemState copyWith({
    bool? isProcessing,
    String? error,
    String? actionType,
    Map<String, bool>? likedStates,
    Map<String, bool>? favoritedStates,
    Map<String, int>? likeCounts,
    Map<String, int>? bookmarkCounts,
    Map<String, int>? viewCounts,
    Map<String, int>? reportCounts,
    Map<String, PoemContentUpdateModel?>? contentUpdates,
    Set<String>? returnedReportIds,
    String? lastToggledPoemId,
    PoemModel? createdPoem,
  }) {
    return PoemState(
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
      lastToggledPoemId: lastToggledPoemId ?? this.lastToggledPoemId,
      createdPoem: createdPoem,
    );
  }
}
