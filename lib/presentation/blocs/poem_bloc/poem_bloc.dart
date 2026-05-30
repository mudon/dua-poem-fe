import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/poem_repository.dart';
import 'poem_event.dart';
import 'poem_state.dart';

class PoemBloc extends Bloc<PoemEvent, PoemState> {
  final PoemRepository _poemRepo;

  PoemBloc(this._poemRepo) : super(PoemState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<RecordView>(_onRecordView);
    on<ReportPoem>(_onReport);
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.toggleLike(event.poemId, event.currentlyLiked);
    final newLiked = Map<String, bool>.from(state.likedStates);
    final newLikeCounts = Map<String, int>.from(state.likeCounts);
    if (result.isSuccess) {
      newLiked[event.poemId] = !event.currentlyLiked;
      newLikeCounts[event.poemId] = event.currentCount + (event.currentlyLiked ? -1 : 1);
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'like', likedStates: newLiked, likeCounts: newLikeCounts, lastToggledPoemId: event.poemId));
  }

  Future<void> _onToggleBookmark(ToggleBookmark event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.toggleBookmark(event.poemId, event.currentlyFavorited);
    final newFavorited = Map<String, bool>.from(state.favoritedStates);
    final newBookmarkCounts = Map<String, int>.from(state.bookmarkCounts);
    if (result.isSuccess) {
      newFavorited[event.poemId] = !event.currentlyFavorited;
      newBookmarkCounts[event.poemId] = event.currentCount + (event.currentlyFavorited ? -1 : 1);
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'bookmark', favoritedStates: newFavorited, bookmarkCounts: newBookmarkCounts, lastToggledPoemId: event.poemId));
  }

  void _onRecordView(RecordView event, Emitter<PoemState> emit) {
    final newViewCounts = Map<String, int>.from(state.viewCounts);
    newViewCounts[event.poemId] = event.viewCount;
    emit(state.copyWith(actionType: 'view', viewCounts: newViewCounts, lastToggledPoemId: event.poemId));
  }

  Future<void> _onReport(ReportPoem event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.reportPoem(event.poemId, event.reason, event.description);
    final newReportCounts = Map<String, int>.from(state.reportCounts);
    if (result.isSuccess) {
      final current = state.reportCounts[event.poemId] ?? 0;
      newReportCounts[event.poemId] = current + 1;
    }
    emit(state.copyWith(
      isProcessing: false,
      error: result.isSuccess ? null : result.error,
      actionType: 'report',
      reportCounts: newReportCounts,
      lastToggledPoemId: event.poemId,
    ));
  }
}
