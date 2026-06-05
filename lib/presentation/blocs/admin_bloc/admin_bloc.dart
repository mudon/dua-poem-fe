import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/services/signalr_service.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepo;
  StreamSubscription? _notificationSub;
  StreamSubscription? _reportsSub;

  AdminBloc(this._adminRepo) : super(AdminState()) {
    on<LoadPendingRevisions>(_onLoadPending);
    on<ReviewRevision>(_onReviewRevision);
    _listenToSignalR();
  }

  void _listenToSignalR() {
    _notificationSub = getIt<SignalRService>().onNotificationReceived.listen((notification) {
      if (notification.type == 'revision_submitted') {
        add(LoadPendingRevisions());
      }
    });
    _reportsSub = getIt<SignalRService>().onReportsCountUpdated.listen((_) {
      add(LoadPendingRevisions());
    });
  }

  Future<void> _onLoadPending(LoadPendingRevisions event, Emitter<AdminState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _adminRepo.getPendingRevisions();
    if (result.isSuccess) {
      emit(state.copyWith(revisions: result.data!, isLoading: false));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _onReviewRevision(ReviewRevision event, Emitter<AdminState> emit) async {
    emit(state.copyWith(isReviewing: true, clearError: true));
    final result = await _adminRepo.reviewRevision(
      event.revisionId,
      event.contentType,
      event.actions,
    );
    if (result.isSuccess) {
      emit(state.copyWith(
        isReviewing: false,
        reviewSuccess: 'Revision reviewed successfully',
      ));
      add(LoadPendingRevisions());
    } else {
      emit(state.copyWith(isReviewing: false, error: result.error));
    }
  }

  @override
  Future<void> close() {
    _notificationSub?.cancel();
    _reportsSub?.cancel();
    return super.close();
  }
}
