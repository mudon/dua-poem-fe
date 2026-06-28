import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/signalr_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepo;
  StreamSubscription? _notificationSub;
  int _currentPage = 1;

  NotificationBloc(this._notificationRepo) : super(NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllRead>(_onMarkAllRead);
    on<NotificationReceived>(_onNotificationReceived);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
    _listenToSignalR();
  }

  void _listenToSignalR() {
    _notificationSub = getIt<SignalRService>().onNotificationReceived.listen((update) {
      try {
        final notification = NotificationModel(
          id: update.id,
          type: update.type,
          title: update.title,
          body: update.body,
          data: update.data,
          isRead: update.isRead,
          createdAt: update.createdAt,
        );
        print('[NotificationBloc] Received notification via SignalR: type=${notification.type}, title=${notification.title}');
        add(NotificationReceived(notification));
      } catch (e) {
        print('[NotificationBloc] Error processing SignalR notification: $e');
      }
    });
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    if (event.refresh) {
      _currentPage = 1;
    }
    if (_currentPage == 1) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    final result = await _notificationRepo.getNotifications(page: _currentPage);
    if (result.isSuccess) {
      final list = result.data!;
      final allNotifications = event.refresh
          ? list
          : [...state.notifications, ...list];
      emit(state.copyWith(
        notifications: allNotifications,
        hasMore: list.length >= 20,
        isLoading: false,
      ));
      _currentPage++;
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }

    if (event.refresh || _currentPage == 2) {
      final countResult = await _notificationRepo.getUnreadCount();
      if (countResult.isSuccess) {
        emit(state.copyWith(unreadCount: countResult.data!));
      }
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepo.markAsRead(event.id);
    if (result.isSuccess) {
      final updated = state.notifications.map((n) =>
        n.id == event.id ? n.copyWith(isRead: true) : n,
      ).toList();
      emit(state.copyWith(
        notifications: updated,
        unreadCount: (state.unreadCount - 1).clamp(0, state.unreadCount),
      ));
    }
  }

  Future<void> _onMarkAllRead(MarkAllRead event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(isMarkingAllRead: true));
    final result = await _notificationRepo.markAllAsRead();
    if (result.isSuccess) {
      final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(state.copyWith(
        notifications: updated,
        unreadCount: 0,
        isMarkingAllRead: false,
      ));
    } else {
      emit(state.copyWith(isMarkingAllRead: false, error: result.error));
    }
  }

  void _onNotificationReceived(NotificationReceived event, Emitter<NotificationState> emit) {
    final alreadyExists = state.notifications.any((n) => n.id == event.notification.id);
    if (alreadyExists) return;
    print('[NotificationBloc] _onNotificationReceived: type=${event.notification.type}, unreadCount=${state.unreadCount + 1}');
    final updated = [event.notification, ...state.notifications];
    emit(state.copyWith(
      notifications: updated,
      unreadCount: state.unreadCount + 1,
    ));
  }

  Future<void> _onRefreshUnreadCount(RefreshUnreadCount event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepo.getUnreadCount();
    if (result.isSuccess) {
      emit(state.copyWith(unreadCount: result.data!));
    }
  }

  @override
  Future<void> close() {
    _notificationSub?.cancel();
    return super.close();
  }
}
