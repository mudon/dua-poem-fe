import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/poem_repository.dart';
import 'poem_event.dart';
import 'poem_state.dart';

class PoemBloc extends Bloc<PoemEvent, PoemState> {
  final PoemRepository _poemRepo;

  PoemBloc(this._poemRepo) : super(PoemState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<ReportPoem>(_onReport);
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.toggleLike(event.poemId, event.currentlyLiked);
    final newLiked = Map<String, bool>.from(state.likedStates);
    if (result.isSuccess) {
      newLiked[event.poemId] = !event.currentlyLiked;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'like', likedStates: newLiked));
  }

  Future<void> _onToggleBookmark(ToggleBookmark event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.toggleBookmark(event.poemId, event.currentlyFavorited);
    final newFavorited = Map<String, bool>.from(state.favoritedStates);
    if (result.isSuccess) {
      newFavorited[event.poemId] = !event.currentlyFavorited;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'bookmark', favoritedStates: newFavorited));
  }

  Future<void> _onReport(ReportPoem event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.reportPoem(event.poemId, event.reason, event.description);
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'report'));
  }
}
