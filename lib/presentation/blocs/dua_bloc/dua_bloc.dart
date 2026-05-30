import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dua_repository.dart';
import 'dua_event.dart';
import 'dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final DuaRepository _duaRepo;

  DuaBloc(this._duaRepo) : super(DuaState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<RecordView>(_onRecordView);
    on<ReportDua>(_onReport);
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.toggleLike(event.duaId, event.currentlyLiked);
    final newLiked = Map<String, bool>.from(state.likedStates);
    final newLikeCounts = Map<String, int>.from(state.likeCounts);
    if (result.isSuccess) {
      newLiked[event.duaId] = !event.currentlyLiked;
      newLikeCounts[event.duaId] = event.currentCount + (event.currentlyLiked ? -1 : 1);
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'like', likedStates: newLiked, likeCounts: newLikeCounts, lastToggledDuaId: event.duaId));
  }

  Future<void> _onToggleBookmark(ToggleBookmark event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.toggleBookmark(event.duaId, event.currentlyFavorited);
    final newFavorited = Map<String, bool>.from(state.favoritedStates);
    final newBookmarkCounts = Map<String, int>.from(state.bookmarkCounts);
    if (result.isSuccess) {
      newFavorited[event.duaId] = !event.currentlyFavorited;
      newBookmarkCounts[event.duaId] = event.currentCount + (event.currentlyFavorited ? -1 : 1);
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'bookmark', favoritedStates: newFavorited, bookmarkCounts: newBookmarkCounts, lastToggledDuaId: event.duaId));
  }

  void _onRecordView(RecordView event, Emitter<DuaState> emit) {
    final newViewCounts = Map<String, int>.from(state.viewCounts);
    newViewCounts[event.duaId] = event.viewCount;
    emit(state.copyWith(actionType: 'view', viewCounts: newViewCounts, lastToggledDuaId: event.duaId));
  }

  Future<void> _onReport(ReportDua event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.reportDua(event.duaId, event.reason, event.description);
    final newReportCounts = Map<String, int>.from(state.reportCounts);
    if (result.isSuccess) {
      final current = state.reportCounts[event.duaId] ?? 0;
      newReportCounts[event.duaId] = current + 1;
    }
    emit(state.copyWith(
      isProcessing: false,
      error: result.isSuccess ? null : result.error,
      actionType: 'report',
      reportCounts: newReportCounts,
      lastToggledDuaId: event.duaId,
    ));
  }
}
