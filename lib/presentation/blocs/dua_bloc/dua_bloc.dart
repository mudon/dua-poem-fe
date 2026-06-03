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
    on<SignalRFavoritesCountUpdated>(_onSignalRFavoritesCountUpdated);
    on<SignalRViewsCountUpdated>(_onSignalRViewsCountUpdated);
    on<SignalRReportsCountUpdated>(_onSignalRReportsCountUpdated);
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

    getIt<SignalRService>().onViewsCountUpdated.listen((update) {
      try {
        final id = update.id;
        add(SignalRViewsCountUpdated(id, update.viewsCount));
      } catch (_) {}
    });

    getIt<SignalRService>().onReportsCountUpdated.listen((update) {
      try {
        final id = update.id;
        add(SignalRReportsCountUpdated(id, update.reportsCount));
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
    if (result.isSuccess) {
      newFavorited[event.duaId] = !event.currentlyFavorited;
    }
    emit(state.copyWith(isProcessing: false, error: result.isSuccess ? null : result.error, actionType: 'bookmark', favoritedStates: newFavorited, lastToggledDuaId: event.duaId));
  }

  void _onSignalRFavoritesCountUpdated(SignalRFavoritesCountUpdated event, Emitter<DuaState> emit) {
    print('[SignalR] DuaBloc received SignalRFavoritesCountUpdated: duaId=${event.duaId}, favoritesCount=${event.favoritesCount}');
    final newBookmarkCounts = Map<String, int>.from(state.bookmarkCounts);
    newBookmarkCounts[event.duaId] = event.favoritesCount;
    emit(state.copyWith(
      bookmarkCounts: newBookmarkCounts,
      actionType: 'signalr_bookmark',
      lastToggledDuaId: event.duaId,
    ));
  }

  void _onSignalRViewsCountUpdated(SignalRViewsCountUpdated event, Emitter<DuaState> emit) {
    print('[SignalR] DuaBloc received SignalRViewsCountUpdated: duaId=${event.duaId}, viewsCount=${event.viewsCount}');
    final newViewCounts = Map<String, int>.from(state.viewCounts);
    newViewCounts[event.duaId] = event.viewsCount;
    emit(state.copyWith(
      viewCounts: newViewCounts,
      actionType: 'signalr_view',
      lastToggledDuaId: event.duaId,
    ));
  }

  void _onSignalRReportsCountUpdated(SignalRReportsCountUpdated event, Emitter<DuaState> emit) {
    print('[SignalR] DuaBloc received SignalRReportsCountUpdated: duaId=${event.duaId}, reportsCount=${event.reportsCount}');
    final newReportCounts = Map<String, int>.from(state.reportCounts);
    newReportCounts[event.duaId] = event.reportsCount;
    emit(state.copyWith(
      reportCounts: newReportCounts,
      actionType: 'signalr_report',
      lastToggledDuaId: event.duaId,
    ));
  }

  void _onRecordView(RecordView event, Emitter<DuaState> emit) {
    final newViewCounts = Map<String, int>.from(state.viewCounts);
    newViewCounts[event.duaId] = event.viewCount;
    emit(state.copyWith(actionType: 'view', viewCounts: newViewCounts, lastToggledDuaId: event.duaId));
  }

  Future<void> _onReport(ReportDua event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.reportDua(event.duaId, event.reason, event.description);
    emit(state.copyWith(
      isProcessing: false,
      error: result.isSuccess ? null : result.error,
      actionType: 'report',
      lastToggledDuaId: event.duaId,
    ));
  }
}
