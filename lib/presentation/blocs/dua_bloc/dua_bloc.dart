import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/repositories/dua_repository.dart';
import '../../../data/services/signalr_service.dart';
import 'dua_event.dart';
import 'dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final DuaRepository _duaRepo;
  StreamSubscription? _signalRSub;

  DuaBloc(this._duaRepo) : super(DuaState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<RecordView>(_onRecordView);
    on<ReportDua>(_onReport);
    on<SignalRLikeCountUpdated>(_onSignalRLikeCountUpdated);
    _listenToSignalR();
  }

  void _listenToSignalR() {
    _signalRSub = getIt<SignalRService>().onLikesCountUpdated.listen((update) {
      try {
        final id = update.id;
        add(SignalRLikeCountUpdated(id, update.likesCount));
      } catch (_) {}
    });
  }

  void _onSignalRLikeCountUpdated(SignalRLikeCountUpdated event, Emitter<DuaState> emit) {
    print('[SignalR] DuaBloc received SignalRLikeCountUpdated: duaId=${event.duaId}, likesCount=${event.likesCount}');
    final newLikeCounts = Map<String, int>.from(state.likeCounts);
    newLikeCounts[event.duaId] = event.likesCount;
    emit(state.copyWith(
      likeCounts: newLikeCounts,
      actionType: 'signalr_like',
      lastToggledDuaId: event.duaId,
    ));
  }

  @override
  Future<void> close() {
    _signalRSub?.cancel();
    return super.close();
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.toggleLike(event.duaId, event.currentlyLiked);
    final newLiked = Map<String, bool>.from(state.likedStates);
    if (result.isSuccess) {
      newLiked[event.duaId] = !event.currentlyLiked;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'like', likedStates: newLiked, lastToggledDuaId: event.duaId));
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
