import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/enums/notification_type.dart';
import '../../../core/enums/avatar_type.dart';
import '../../../data/models/signalr/dua_content_update_model.dart';
import '../../../data/models/signalr/profile_update_model.dart';
import '../../../data/repositories/dua_repository.dart';
import '../../../data/models/dua_model.dart';
import '../../../data/services/signalr_service.dart';
import 'dua_event.dart';
import 'dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final DuaRepository _duaRepo;
  StreamSubscription? _signalRSub;
  StreamSubscription? _notificationSub;

  DuaBloc(this._duaRepo) : super(DuaState()) {
    on<ToggleLike>(_onToggleLike);
    on<ToggleBookmark>(_onToggleBookmark);
    on<RecordView>(_onRecordView);
    on<ReportDua>(_onReport);
    on<SignalRLikeCountUpdated>(_onSignalRLikeCountUpdated);
    on<SignalRFavoritesCountUpdated>(_onSignalRFavoritesCountUpdated);
    on<SignalRViewsCountUpdated>(_onSignalRViewsCountUpdated);
    on<SignalRReportsCountUpdated>(_onSignalRReportsCountUpdated);
    on<SignalRReportReturned>(_onSignalRReportReturned);
    on<ClearReturnedReports>(_onClearReturnedReports);
    on<DuaCreated>(_onDuaCreated);
    on<UpdateDua>(_onUpdateDua);
    on<DeleteDua>(_onDeleteDua);
    on<SignalRDuaDeleted>(_onSignalRDuaDeleted);
    on<SignalRProfileUpdated>(_onSignalRProfileUpdated);
    on<SignalRDuaContentUpdated>(_onSignalRDuaContentUpdated);
    on<SignalRDuaCreated>(_onSignalRDuaCreated);
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

    getIt<SignalRService>().onDuaContentUpdated.listen((update) {
      try {
        add(SignalRDuaContentUpdated(
          duaId: update.id,
          title: update.title,
          arabicText: update.arabicText,
          transliteration: update.transliteration,
          translation: update.translation,
          description: update.description,
          whenToRecite: update.whenToRecite,
          occasion: update.occasion,
          repetitionCount: update.repetitionCount,
          updatedAt: update.updatedAt,
        ));
      } catch (_) {}
    });

    getIt<SignalRService>().onDuaDeleted.listen((duaId) {
      try {
        add(SignalRDuaDeleted(duaId));
      } catch (_) {}
    });

    getIt<SignalRService>().onProfileUpdated.listen((update) {
      try {
        add(SignalRProfileUpdated(
          userId: update.userId,
          firstName: update.firstName,
          lastName: update.lastName,
          avatarType: update.avatarType?.toString(),
          avatarValue: update.avatarValue,
          selectedBadgeSlug: update.selectedBadgeSlug,
        ));
      } catch (_) {}
    });

    getIt<SignalRService>().onDuaCreated.listen((data) {
      try {
        final dua = DuaModel.fromApiJson(data);
        add(SignalRDuaCreated(dua));
      } catch (_) {}
    });
  }

  void _listenToNotifications() {
    _notificationSub = getIt<SignalRService>().onNotificationReceived.listen((notification) {
      try {
        if (notification.type == NotificationType.reportReopened) {
          final data = notification.data;
          if (data == null) return;
          final parsed = jsonDecode(data) as Map<String, dynamic>;
          final duaId = parsed['duaId'] as String?;
          if (duaId == null) return;
          add(SignalRReportReturned(duaId));
        }
      } catch (_) {}
    });
  }

  Future<void> _onUpdateDua(UpdateDua event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final data = <String, dynamic>{
      'title': event.title,
      'arabicText': event.arabicText ?? '',
      'transliteration': event.transliteration,
      'translation': event.translation,
    };
    final result = await _duaRepo.updateDua(event.duaId, data);
    emit(state.copyWith(isProcessing: false));
    if (result.isSuccess) {
      final updated = result.data!;
      final newContentUpdates = Map<String, DuaContentUpdateModel?>.from(state.contentUpdates);
      newContentUpdates[event.duaId] = DuaContentUpdateModel(
        id: updated.id,
        title: updated.title,
        arabicText: updated.arabicText,
        transliteration: updated.transliteration,
        translation: updated.translation,
        description: updated.description,
        whenToRecite: updated.whenToRecite,
        occasion: updated.occasion,
        repetitionCount: updated.repetitionCount ?? 0,
        updatedAt: updated.updatedAt ?? '',
      );
      emit(state.copyWith(
        contentUpdates: newContentUpdates,
        actionType: 'content_updated',
        lastToggledDuaId: event.duaId,
      ));
    } else {
      emit(state.copyWith(error: result.error, actionType: 'update_error'));
    }
  }

  void _onSignalRProfileUpdated(SignalRProfileUpdated event, Emitter<DuaState> emit) {
    print('[SignalR] DuaBloc received SignalRProfileUpdated: userId=${event.userId}, userName=${event.userName}');
    final newProfileUpdates = Map<String, ProfileUpdateModel>.from(state.profileUpdates);
    newProfileUpdates[event.userId] = ProfileUpdateModel(
      userId: event.userId,
      firstName: event.firstName,
      lastName: event.lastName,
      avatarType: event.avatarType != null ? AvatarType.fromValue(event.avatarType) : null,
      avatarValue: event.avatarValue,
      selectedBadgeSlug: event.selectedBadgeSlug,
    );
    emit(state.copyWith(
      profileUpdates: newProfileUpdates,
      actionType: 'profile_update',
      lastToggledDuaId: event.userId,
    ));
  }

  void _onSignalRDuaContentUpdated(SignalRDuaContentUpdated event, Emitter<DuaState> emit) {
    print('[SignalR] DuaBloc received SignalRDuaContentUpdated: duaId=${event.duaId}, title=${event.title}');
    final newContentUpdates = Map<String, DuaContentUpdateModel?>.from(state.contentUpdates);
    newContentUpdates[event.duaId] = DuaContentUpdateModel(
      id: event.duaId,
      title: event.title,
      arabicText: event.arabicText,
      transliteration: event.transliteration,
      translation: event.translation,
      description: event.description,
      whenToRecite: event.whenToRecite,
      occasion: event.occasion,
      repetitionCount: event.repetitionCount,
      updatedAt: event.updatedAt,
    );
    emit(state.copyWith(
      contentUpdates: newContentUpdates,
      actionType: 'content_updated',
      lastToggledDuaId: event.duaId,
    ));
  }

  void _onSignalRDuaCreated(SignalRDuaCreated event, Emitter<DuaState> emit) {
    print('[SignalR] DuaBloc received SignalRDuaCreated: duaId=${event.dua.id}, title=${event.dua.title}');
    emit(state.copyWith(
      actionType: 'created',
      lastToggledDuaId: event.dua.id,
      createdDua: event.dua,
      error: null,
    ));
  }

  void _onSignalRReportReturned(SignalRReportReturned event, Emitter<DuaState> emit) {
    final updated = Set<String>.from(state.returnedReportIds)..add(event.duaId);
    emit(state.copyWith(returnedReportIds: updated, actionType: 'signalr_report_returned', lastToggledDuaId: event.duaId));
  }

  void _onClearReturnedReports(ClearReturnedReports event, Emitter<DuaState> emit) {
    emit(state.copyWith(returnedReportIds: const {}));
  }

  void _onDuaCreated(DuaCreated event, Emitter<DuaState> emit) {
    emit(state.copyWith(actionType: 'created', lastToggledDuaId: event.dua.id, createdDua: event.dua, error: null));
  }

  Future<void> _onDeleteDua(DeleteDua event, Emitter<DuaState> emit) async {
    emit(state.copyWith(isProcessing: true));
    final result = await _duaRepo.deleteDua(event.duaId);
    emit(state.copyWith(isProcessing: false));
    if (result.isSuccess) {
      emit(state.copyWith(actionType: 'deleted', lastToggledDuaId: event.duaId));
    } else {
      emit(state.copyWith(error: result.error, actionType: 'delete_error'));
    }
  }

  void _onSignalRDuaDeleted(SignalRDuaDeleted event, Emitter<DuaState> emit) {
    emit(state.copyWith(actionType: 'deleted', lastToggledDuaId: event.duaId));
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
    _notificationSub?.cancel();
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
