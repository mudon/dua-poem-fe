import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dua_repository.dart';
import 'dua_feed_event.dart';
import 'dua_feed_state.dart';

const int _pageSize = 20;

class DuaFeedBloc extends Bloc<DuaFeedEvent, DuaFeedState> {
  final DuaRepository _duaRepo;

  DuaFeedBloc(this._duaRepo) : super(DuaFeedState()) {
    on<FetchLatestDuas>(_fetchLatest);
    on<FetchOlderDuas>(_fetchOlder);
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
        totalLoadedDuas: paged.data.length,
        olderCursorDuas: paged.nextCursor,
        hasMoreOlderDuas: paged.hasMore,
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
        totalLoadedDuas: paged.data.length,
        olderCursorDuas: paged.nextCursor,
        hasMoreOlderDuas: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
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
      final updatedWindow = [...state.windowDuas, ...newItems];
      emit(state.copyWith(
        loadingOlderDuas: false,
        windowDuas: updatedWindow,
        olderCursorDuas: paged.nextCursor,
        hasMoreOlderDuas: paged.hasMore && paged.data.length == _pageSize,
        totalLoadedDuas: state.totalLoadedDuas + newItems.length,
      ));
    } else {
      emit(state.copyWith(loadingOlderDuas: false, error: result.error));
    }
  }

  void _onInsert(InsertDuaToFeed event, Emitter<DuaFeedState> emit) {
    if (state.windowDuas.any((d) => d.id == event.dua.id)) return;
    emit(state.copyWith(
      windowDuas: [event.dua, ...state.windowDuas],
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
