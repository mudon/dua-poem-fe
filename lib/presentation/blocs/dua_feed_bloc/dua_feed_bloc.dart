import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dua_repository.dart';
import 'dua_feed_event.dart';
import 'dua_feed_state.dart';

const int _maxWindow = 60;
const int _pageSize = 20;

class DuaFeedBloc extends Bloc<DuaFeedEvent, DuaFeedState> {
  final DuaRepository _duaRepo;

  DuaFeedBloc(this._duaRepo) : super(DuaFeedState()) {
    on<FetchLatestDuas>(_fetchLatest);
    on<FetchOlderDuas>(_fetchOlder);
    on<FetchLatterDuas>(_fetchLatter);
    on<ResetDuas>(_reset);
    on<InsertDuaToFeed>(_onInsert);
    on<RemoveDuaFromFeed>(_onRemove);
    on<UpdateDuaInFeed>(_onUpdate);
  }

  Future<void> _fetchLatest(FetchLatestDuas event, Emitter<DuaFeedState> emit) async {
    debugPrint('[DUA_FEED] fetching latest, limit=${event.limit}');
    emit(state.copyWith(isLoading: true));
    final result = await _duaRepo.getLatestDuas(limit: event.limit);
    if (result.isSuccess) {
      final paged = result.data!;
      debugPrint('[DUA_FEED] latest: ${paged.data.length} items, hasMore=${paged.hasMore}');
      emit(state.copyWith(
        isLoading: false,
        windowDuas: paged.data,
        windowDuasStart: 0,
        totalLoadedDuas: paged.data.length,
        olderCursorDuas: paged.nextCursor,
        hasMoreOlderDuas: paged.hasMore,
        latterCursorDuas: null,
        hasMoreLatterDuas: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _reset(ResetDuas event, Emitter<DuaFeedState> emit) async {
    debugPrint('[DUA_FEED] reset');
    emit(state.copyWith(isLoading: true));
    final result = await _duaRepo.getLatestDuas(limit: event.limit);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        isLoading: false,
        windowDuas: paged.data,
        windowDuasStart: 0,
        totalLoadedDuas: paged.data.length,
        olderCursorDuas: paged.nextCursor,
        hasMoreOlderDuas: paged.hasMore,
        latterCursorDuas: null,
        hasMoreLatterDuas: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _fetchLatter(FetchLatterDuas event, Emitter<DuaFeedState> emit) async {
    if (state.loadingLatterDuas || !state.hasMoreLatterDuas || state.windowDuas.isEmpty) return;
    debugPrint('[DUA_FEED] fetching latter, '
        'cursor=${state.latterCursorDuas?.substring(0, 8) ?? "none"} '
        'firstId=${state.windowDuas.first.id.substring(0, 8)}...');
    emit(state.copyWith(loadingLatterDuas: true));
    final firstId = state.windowDuas.first.id;
    final result = await _duaRepo.getLatter(firstId, cursor: state.latterCursorDuas, limit: _pageSize);
    if (result.isSuccess) {
      final paged = result.data!;
      final newItems = paged.data;
      debugPrint('[DUA_FEED] latter: ${newItems.length} items hasMore=${paged.hasMore}');
      if (newItems.isEmpty) {
        emit(state.copyWith(loadingLatterDuas: false));
        return;
      }
      final updatedWindow = [...newItems, ...state.windowDuas];
      final newStart = state.windowDuasStart - newItems.length;
      if (updatedWindow.length > _maxWindow) {
        updatedWindow.removeRange(updatedWindow.length - _pageSize, updatedWindow.length);
      }
      emit(state.copyWith(
        loadingLatterDuas: false,
        windowDuas: updatedWindow,
        windowDuasStart: newStart,
        totalLoadedDuas: state.totalLoadedDuas + newItems.length,
        latterCursorDuas: paged.nextCursor,
        hasMoreLatterDuas: paged.hasMore && paged.data.length == _pageSize,
      ));
    } else {
      emit(state.copyWith(loadingLatterDuas: false, error: result.error));
    }
  }

  Future<void> _fetchOlder(FetchOlderDuas event, Emitter<DuaFeedState> emit) async {
    if (state.loadingOlderDuas || !state.hasMoreOlderDuas || state.windowDuas.isEmpty) return;
    debugPrint('[DUA_FEED] fetching older, '
        'cursor=${state.olderCursorDuas?.substring(0, 8) ?? "none"} '
        'lastId=${state.windowDuas.last.id.substring(0, 8)}...');
    emit(state.copyWith(loadingOlderDuas: true));
    final result = await _duaRepo.getOlder(state.windowDuas.last.id, cursor: state.olderCursorDuas, limit: _pageSize);
    if (result.isSuccess) {
      final paged = result.data!;
      final newItems = paged.data;
      debugPrint('[DUA_FEED] older: ${newItems.length} items hasMore=${paged.hasMore}');
      var updatedWindow = [...state.windowDuas, ...newItems];
      var newStart = state.windowDuasStart;
      var trimmed = false;
      if (updatedWindow.length > _maxWindow) {
        updatedWindow.removeRange(0, _pageSize);
        newStart += _pageSize;
        trimmed = true;
      }
      emit(state.copyWith(
        loadingOlderDuas: false,
        windowDuas: updatedWindow,
        windowDuasStart: newStart,
        olderCursorDuas: paged.nextCursor,
        hasMoreOlderDuas: paged.hasMore && paged.data.length == _pageSize,
        totalLoadedDuas: state.totalLoadedDuas + newItems.length,
        hasMoreLatterDuas: trimmed ? true : state.hasMoreLatterDuas,
      ));
    } else {
      emit(state.copyWith(loadingOlderDuas: false, error: result.error));
    }
  }

  void _onInsert(InsertDuaToFeed event, Emitter<DuaFeedState> emit) {
    if (state.windowDuas.any((d) => d.id == event.dua.id)) return;
    final updatedWindow = [event.dua, ...state.windowDuas];
    emit(state.copyWith(
      windowDuas: updatedWindow.length > _maxWindow ? updatedWindow.sublist(0, _maxWindow) : updatedWindow,
      totalLoadedDuas: state.totalLoadedDuas + 1,
    ));
  }

  void _onRemove(RemoveDuaFromFeed event, Emitter<DuaFeedState> emit) {
    if (!state.windowDuas.any((d) => d.id == event.duaId)) return;
    emit(state.copyWith(
      windowDuas: state.windowDuas.where((d) => d.id != event.duaId).toList(),
      totalLoadedDuas: state.totalLoadedDuas - 1,
    ));
  }

  void _onUpdate(UpdateDuaInFeed event, Emitter<DuaFeedState> emit) {
    final updated = state.windowDuas.map((d) {
      if (d.id != event.duaId) return d;
      return d.copyWith(
        title: event.title,
        arabicText: event.arabicText,
        transliteration: event.transliteration,
        translation: event.translation,
        description: event.description,
        whenToRecite: event.whenToRecite,
        occasion: event.occasion,
        repetitionCount: event.repetitionCount,
        updatedAt: event.updatedAt,
        isLiked: event.isLiked,
        likeCount: event.likeCount,
        isFavorited: event.isFavorited,
        bookmarkCount: event.bookmarkCount,
        views: event.views,
        activeReportCount: event.reportCount,
      );
    }).toList();
    emit(state.copyWith(windowDuas: updated));
  }
}
