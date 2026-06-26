import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/poem_repository.dart';
import 'poem_feed_event.dart';
import 'poem_feed_state.dart';

const int _pageSize = 20;

class PoemFeedBloc extends Bloc<PoemFeedEvent, PoemFeedState> {
  final PoemRepository _poemRepo;

  PoemFeedBloc(this._poemRepo) : super(PoemFeedState()) {
    on<FetchLatestPoems>(_fetchLatest);
    on<FetchOlderPoems>(_fetchOlder);
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
        totalLoadedPoems: paged.data.length,
        olderCursorPoems: paged.nextCursor,
        hasMoreOlderPoems: paged.hasMore,
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
        totalLoadedPoems: paged.data.length,
        olderCursorPoems: paged.nextCursor,
        hasMoreOlderPoems: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
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
      final updatedWindow = [...state.windowPoems, ...newItems];
      emit(state.copyWith(
        loadingOlderPoems: false,
        windowPoems: updatedWindow,
        olderCursorPoems: paged.nextCursor,
        hasMoreOlderPoems: paged.hasMore && paged.data.length == _pageSize,
        totalLoadedPoems: state.totalLoadedPoems + newItems.length,
      ));
    } else {
      emit(state.copyWith(loadingOlderPoems: false, error: result.error));
    }
  }

  void _onInsert(InsertPoemToFeed event, Emitter<PoemFeedState> emit) {
    if (state.windowPoems.any((p) => p.id == event.poem.id)) return;
    emit(state.copyWith(
      windowPoems: [event.poem, ...state.windowPoems],
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
