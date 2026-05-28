import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dua_repository.dart';
import 'dua_event.dart';
import 'dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final DuaRepository _duaRepo;

  DuaBloc(this._duaRepo) : super(DuaState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<ReportDua>(_onReport);
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.toggleLike(event.duaId, event.currentlyLiked);
    final newLiked = Map<String, bool>.from(state.likedStates);
    if (result.isSuccess) {
      newLiked[event.duaId] = !event.currentlyLiked;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'like', likedStates: newLiked));
  }

  Future<void> _onToggleBookmark(ToggleBookmark event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.toggleBookmark(event.duaId, event.currentlyFavorited);
    final newFavorited = Map<String, bool>.from(state.favoritedStates);
    if (result.isSuccess) {
      newFavorited[event.duaId] = !event.currentlyFavorited;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'bookmark', favoritedStates: newFavorited));
  }

  Future<void> _onReport(ReportDua event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.reportDua(event.duaId, event.reason, event.description);
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'report'));
  }
}
