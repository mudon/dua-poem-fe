import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/models/signalr/poem_content_update_model.dart';
import '../../../data/repositories/poem_repository.dart';
import '../../../data/services/signalr_service.dart';
import 'poem_event.dart';
import 'poem_state.dart';

class PoemBloc extends Bloc<PoemEvent, PoemState> {
  final PoemRepository _poemRepo;
  StreamSubscription? _signalRSub;
  StreamSubscription? _notificationSub;

  PoemBloc(this._poemRepo) : super(PoemState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<RecordView>(_onRecordView);
    on<ReportPoem>(_onReport);
    on<SignalRLikeCountUpdated>(_onSignalRLikeCountUpdated);
    on<SignalRFavoritesCountUpdated>(_onSignalRFavoritesCountUpdated);
    on<SignalRViewsCountUpdated>(_onSignalRViewsCountUpdated);
    on<SignalRReportsCountUpdated>(_onSignalRReportsCountUpdated);
    on<SignalRReportReturned>(_onSignalRReportReturned);
    on<ClearReturnedReports>(_onClearReturnedReports);
    on<UpdatePoem>(_onUpdatePoem);
    on<SignalRPoemContentUpdated>(_onSignalRPoemContentUpdated);
    _listenToSignalR();
    _listenToNotifications();
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

    getIt<SignalRService>().onPoemContentUpdated.listen((update) {
      try {
        add(SignalRPoemContentUpdated(
          poemId: update.id,
          title: update.title,
          content: update.content,
          transliteration: update.transliteration,
          translation: update.translation,
          description: update.description,
          author: update.author,
          updatedAt: update.updatedAt,
        ));
      } catch (_) {}
    });
  }

  void _listenToNotifications() {
    _notificationSub = getIt<SignalRService>().onNotificationReceived.listen((notification) {
      try {
        if (notification.type == 'report_reopened') {
          final data = notification.data;
          if (data == null) return;
          final parsed = jsonDecode(data) as Map<String, dynamic>;
          final poemId = parsed['poemId'] as String?;
          if (poemId == null) return;
          add(SignalRReportReturned(poemId));
        }
      } catch (_) {}
    });
  }

  Future<void> _onUpdatePoem(UpdatePoem event, Emitter<PoemState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final data = <String, dynamic>{
      'title': event.title,
      'content': event.content ?? '',
      'transliteration': event.transliteration,
      'translation': event.translation,
    };
    final result = await _poemRepo.updatePoem(event.poemId, data);
    emit(state.copyWith(isProcessing: false));
    if (result.isSuccess) {
      final updated = result.data!;
      final newContentUpdates = Map<String, PoemContentUpdateModel?>.from(state.contentUpdates);
      newContentUpdates[event.poemId] = PoemContentUpdateModel(
        id: updated.id,
        title: updated.title,
        content: updated.content,
        transliteration: updated.transliteration,
        translation: updated.translation,
        description: updated.description,
        author: updated.author,
        updatedAt: updated.updatedAt ?? '',
      );
      emit(state.copyWith(
        contentUpdates: newContentUpdates,
        actionType: 'content_updated',
        lastToggledPoemId: event.poemId,
      ));
    } else {
      emit(state.copyWith(error: result.error, actionType: 'update_error'));
    }
  }

  void _onSignalRPoemContentUpdated(SignalRPoemContentUpdated event, Emitter<PoemState> emit) {
    print('[SignalR] PoemBloc received SignalRPoemContentUpdated: poemId=${event.poemId}, title=${event.title}');
    final newContentUpdates = Map<String, PoemContentUpdateModel?>.from(state.contentUpdates);
    newContentUpdates[event.poemId] = PoemContentUpdateModel(
      id: event.poemId,
      title: event.title,
      content: event.content,
      transliteration: event.transliteration,
      translation: event.translation,
      description: event.description,
      author: event.author,
      updatedAt: event.updatedAt,
    );
    emit(state.copyWith(
      contentUpdates: newContentUpdates,
      actionType: 'content_updated',
      lastToggledPoemId: event.poemId,
    ));
  }

  void _onSignalRReportReturned(SignalRReportReturned event, Emitter<PoemState> emit) {
    final updated = Set<String>.from(state.returnedReportIds)..add(event.poemId);
    emit(state.copyWith(returnedReportIds: updated, actionType: 'signalr_report_returned', lastToggledPoemId: event.poemId));
  }

  void _onClearReturnedReports(ClearReturnedReports event, Emitter<PoemState> emit) {
    emit(state.copyWith(returnedReportIds: const {}));
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
    _notificationSub?.cancel();
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

  void _onSignalRViewsCountUpdated(SignalRViewsCountUpdated event, Emitter<PoemState> emit) {
    print('[SignalR] PoemBloc received SignalRViewsCountUpdated: poemId=${event.poemId}, viewsCount=${event.viewsCount}');
    final newViewCounts = Map<String, int>.from(state.viewCounts);
    newViewCounts[event.poemId] = event.viewsCount;
    emit(state.copyWith(
      viewCounts: newViewCounts,
      actionType: 'signalr_view',
      lastToggledPoemId: event.poemId,
    ));
  }

  void _onSignalRReportsCountUpdated(SignalRReportsCountUpdated event, Emitter<PoemState> emit) {
    print('[SignalR] PoemBloc received SignalRReportsCountUpdated: poemId=${event.poemId}, reportsCount=${event.reportsCount}');
    final newReportCounts = Map<String, int>.from(state.reportCounts);
    newReportCounts[event.poemId] = event.reportsCount;
    emit(state.copyWith(
      reportCounts: newReportCounts,
      actionType: 'signalr_report',
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
    emit(state.copyWith(
      isProcessing: false,
      error: result.isSuccess ? null : result.error,
      actionType: 'report',
      lastToggledPoemId: event.poemId,
    ));
  }
}
