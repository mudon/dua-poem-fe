import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/repositories/poem_repository.dart';
import '../../../data/services/signalr_service.dart';
import 'poem_event.dart';
import 'poem_state.dart';

class PoemBloc extends Bloc<PoemEvent, PoemState> {
  final PoemRepository _poemRepo;
  StreamSubscription? _signalRSub;

  PoemBloc(this._poemRepo) : super(PoemState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<RecordView>(_onRecordView);
    on<ReportPoem>(_onReport);
    on<SignalRLikeCountUpdated>(_onSignalRLikeCountUpdated);
    on<SignalRFavoritesCountUpdated>(_onSignalRFavoritesCountUpdated);
    _listenToSignalR();
  }

  void _listenToSignalR() {
    _signalRSub = getIt<SignalRService>().onLikesCountUpdated.listen((update) {
      try {
        final id = update.id;
        add(SignalRLikeCountUpdated(id, update.likesCount));
      } catch (_) {}
    });

    getIt<SignalRService>().onFavoritesCountUpdated.listen((update) {
      try {
        final id = update.id;
        add(SignalRFavoritesCountUpdated(id, update.favoritesCount));
      } catch (_) {}
    });
  }

  void _onSignalRLikeCountUpdated(SignalRLikeCountUpdated event, Emitter<PoemState> emit) {
    print('[SignalR] PoemBloc received SignalRLikeCountUpdated: poemId=${event.poemId}, likesCount=${event.likesCount}');
    final newLikeCounts = Map<String, int>.from(state.likeCounts);
    newLikeCounts[event.poemId] = event.likesCount;
    emit(state.copyWith(
      likeCounts: newLikeCounts,
      actionType: 'signalr_like',
      lastToggledPoemId: event.poemId,
    ));
  }

  @override
  Future<void> close() {
    _signalRSub?.cancel();
    return super.close();
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.toggleLike(event.poemId, event.currentlyLiked);
    final newLiked = Map<String, bool>.from(state.likedStates);
    if (result.isSuccess) {
      newLiked[event.poemId] = !event.currentlyLiked;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'like', likedStates: newLiked, lastToggledPoemId: event.poemId));
  }

  Future<void> _onToggleBookmark(ToggleBookmark event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _poemRepo.toggleBookmark(event.poemId, event.currentlyFavorited);
    final newFavorited = Map<String, bool>.from(state.favoritedStates);
    if (result.isSuccess) {
      newFavorited[event.poemId] = !event.currentlyFavorited;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'bookmark', favoritedStates: newFavorited, lastToggledPoemId: event.poemId));
  }

  void _onSignalRFavoritesCountUpdated(SignalRFavoritesCountUpdated event, Emitter<PoemState> emit) {
    print('[SignalR] PoemBloc received SignalRFavoritesCountUpdated: poemId=${event.poemId}, favoritesCount=${event.favoritesCount}');
    final newBookmarkCounts = Map<String, int>.from(state.bookmarkCounts);
    newBookmarkCounts[event.poemId] = event.favoritesCount;
    emit(state.copyWith(
      bookmarkCounts: newBookmarkCounts,
      actionType: 'signalr_bookmark',
      lastToggledPoemId: event.poemId,
    ));
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
