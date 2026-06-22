import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/poem_repository.dart';
import 'poem_feed_event.dart';
import 'poem_feed_state.dart';

const int _maxWindow = 60;
const int _pageSize = 20;

class PoemFeedBloc extends Bloc<PoemFeedEvent, PoemFeedState> {
  final PoemRepository _poemRepo;

  PoemFeedBloc(this._poemRepo) : super(PoemFeedState()) {
    on<FetchLatestPoems>(_fetchLatest);
    on<FetchOlderPoems>(_fetchOlder);
    on<FetchLatterPoems>(_fetchLatter);
    on<ResetPoems>(_reset);
    on<InsertPoemToFeed>(_onInsert);
    on<RemovePoemFromFeed>(_onRemove);
    on<UpdatePoemInFeed>(_onUpdate);
  }

  Future<void> _fetchLatest(FetchLatestPoems event, Emitter<PoemFeedState> emit) async {
    debugPrint('[POEM_FEED] fetching latest, limit=${event.limit}');
    emit(state.copyWith(isLoading: true));
    final result = await _poemRepo.getLatestPoems(limit: event.limit);
    if (result.isSuccess) {
      final paged = result.data!;
      debugPrint('[POEM_FEED] latest: ${paged.data.length} items, hasMore=${paged.hasMore}');
      emit(state.copyWith(
        isLoading: false,
        windowPoems: paged.data,
        windowPoemsStart: 0,
        totalLoadedPoems: paged.data.length,
        olderCursorPoems: paged.nextCursor,
        hasMoreOlderPoems: paged.hasMore,
        latterCursorPoems: null,
        hasMoreLatterPoems: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _reset(ResetPoems event, Emitter<PoemFeedState> emit) async {
    debugPrint('[POEM_FEED] reset');
    emit(state.copyWith(isLoading: true));
    final result = await _poemRepo.getLatestPoems(limit: event.limit);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        isLoading: false,
        windowPoems: paged.data,
        windowPoemsStart: 0,
        totalLoadedPoems: paged.data.length,
        olderCursorPoems: paged.nextCursor,
        hasMoreOlderPoems: paged.hasMore,
        latterCursorPoems: null,
        hasMoreLatterPoems: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _fetchLatter(FetchLatterPoems event, Emitter<PoemFeedState> emit) async {
    if (state.loadingLatterPoems || !state.hasMoreLatterPoems || state.windowPoems.isEmpty) return;
    debugPrint('[POEM_FEED] fetching latter, '
        'cursor=${state.latterCursorPoems?.substring(0, 8) ?? "none"} '
        'firstId=${state.windowPoems.first.id.substring(0, 8)}...');
    emit(state.copyWith(loadingLatterPoems: true));
    final firstId = state.windowPoems.first.id;
    final result = await _poemRepo.getLatter(firstId, cursor: state.latterCursorPoems, limit: _pageSize);
    if (result.isSuccess) {
      final paged = result.data!;
      final newItems = paged.data;
      debugPrint('[POEM_FEED] latter: ${newItems.length} items hasMore=${paged.hasMore}');
      if (newItems.isEmpty) {
        emit(state.copyWith(loadingLatterPoems: false));
        return;
      }
      final updatedWindow = [...newItems, ...state.windowPoems];
      final newStart = state.windowPoemsStart - newItems.length;
      if (updatedWindow.length > _maxWindow) {
        updatedWindow.removeRange(updatedWindow.length - _pageSize, updatedWindow.length);
      }
      emit(state.copyWith(
        loadingLatterPoems: false,
        windowPoems: updatedWindow,
        windowPoemsStart: newStart,
        latterCursorPoems: paged.nextCursor,
        hasMoreLatterPoems: paged.hasMore && paged.data.length == _pageSize,
      ));
    } else {
      emit(state.copyWith(loadingLatterPoems: false, error: result.error));
    }
  }

  Future<void> _fetchOlder(FetchOlderPoems event, Emitter<PoemFeedState> emit) async {
    if (state.loadingOlderPoems || !state.hasMoreOlderPoems || state.windowPoems.isEmpty) return;
    debugPrint('[POEM_FEED] fetching older, '
        'cursor=${state.olderCursorPoems?.substring(0, 8) ?? "none"} '
        'lastId=${state.windowPoems.last.id.substring(0, 8)}...');
    emit(state.copyWith(loadingOlderPoems: true));
    final result = await _poemRepo.getOlder(state.windowPoems.last.id, cursor: state.olderCursorPoems, limit: _pageSize);
    if (result.isSuccess) {
      final paged = result.data!;
      final newItems = paged.data;
      debugPrint('[POEM_FEED] older: ${newItems.length} items hasMore=${paged.hasMore}');
      var updatedWindow = [...state.windowPoems, ...newItems];
      var newStart = state.windowPoemsStart;
      var trimmed = false;
      if (updatedWindow.length > _maxWindow) {
        updatedWindow.removeRange(0, _pageSize);
        newStart += _pageSize;
        trimmed = true;
      }
      emit(state.copyWith(
        loadingOlderPoems: false,
        windowPoems: updatedWindow,
        windowPoemsStart: newStart,
        olderCursorPoems: paged.nextCursor,
        hasMoreOlderPoems: paged.hasMore && paged.data.length == _pageSize,
        totalLoadedPoems: state.totalLoadedPoems + newItems.length,
        hasMoreLatterPoems: trimmed ? true : state.hasMoreLatterPoems,
      ));
    } else {
      emit(state.copyWith(loadingOlderPoems: false, error: result.error));
    }
  }

  void _onInsert(InsertPoemToFeed event, Emitter<PoemFeedState> emit) {
    if (state.windowPoems.any((p) => p.id == event.poem.id)) return;
    final updatedWindow = [event.poem, ...state.windowPoems];
    emit(state.copyWith(
      windowPoems: updatedWindow.length > _maxWindow ? updatedWindow.sublist(0, _maxWindow) : updatedWindow,
      totalLoadedPoems: state.totalLoadedPoems + 1,
    ));
  }

  void _onRemove(RemovePoemFromFeed event, Emitter<PoemFeedState> emit) {
    if (!state.windowPoems.any((p) => p.id == event.poemId)) return;
    emit(state.copyWith(
      windowPoems: state.windowPoems.where((p) => p.id != event.poemId).toList(),
      totalLoadedPoems: state.totalLoadedPoems - 1,
    ));
  }

  void _onUpdate(UpdatePoemInFeed event, Emitter<PoemFeedState> emit) {
    final updated = state.windowPoems.map((p) {
      if (p.id != event.poemId) return p;
      return p.copyWith(
        title: event.title,
        content: event.content,
        transliteration: event.transliteration,
        translation: event.translation,
        description: event.description,
        author: event.author,
        updatedAt: event.updatedAt,
        isLiked: event.isLiked,
        likeCount: event.likeCount,
        isFavorited: event.isFavorited,
        bookmarkCount: event.bookmarkCount,
        views: event.views,
        activeReportCount: event.reportCount,
      );
    }).toList();
    emit(state.copyWith(windowPoems: updated));
  }
}
