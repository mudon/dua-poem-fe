import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dua_repository.dart';
import '../../../data/repositories/poem_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DuaRepository _duaRepo;
  final PoemRepository _poemRepo;

  HomeBloc(this._duaRepo, this._poemRepo) : super(HomeState()) {
    on<FetchLatestDuas>(_fetchDuas);
    on<FetchLatestPoems>(_fetchPoems);
    on<FetchMoreDuas>(_fetchMoreDuas);
    on<FetchMorePoems>(_fetchMorePoems);
    on<ToggleHomeTab>((event, emit) => emit(state.copyWith(showDuasTab: event.showDuas)));
    on<SearchRequested>(_search);
    on<FetchMoreSearchResults>(_searchMore);
    on<ClearSearch>((event, emit) => emit(state.copyWith(
      isSearching: false, isSearchLoading: false, loadingMoreSearch: false,
      searchQuery: '', searchDuas: [], searchPoems: [],
      searchDuaCursor: null, searchPoemCursor: null, hasMoreSearchDuas: true, hasMoreSearchPoems: true,
    )));
    on<FetchMyDuas>(_fetchMyDuas);
    on<FetchMoreMyDuas>(_fetchMoreMyDuas);
    on<FetchMyPoems>(_fetchMyPoems);
    on<FetchMoreMyPoems>(_fetchMoreMyPoems);
    on<UpdateDua>(_onUpdateDua);
    on<UpdatePoem>(_onUpdatePoem);
    on<RemoveDua>(_onRemoveDua);
    on<RemovePoem>(_onRemovePoem);
  }

  Future<void> _fetchDuas(FetchLatestDuas event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _duaRepo.getLatestDuas(limit: event.limit);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        isLoading: false,
        latestDuas: paged.data,
        duaCursor: paged.nextCursor,
        hasMoreDuas: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _fetchPoems(FetchLatestPoems event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _poemRepo.getLatestPoems(limit: event.limit);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        isLoading: false,
        latestPoems: paged.data,
        poemCursor: paged.nextCursor,
        hasMorePoems: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _fetchMoreDuas(FetchMoreDuas event, Emitter<HomeState> emit) async {
    if (state.loadingMoreDuas || !state.hasMoreDuas) return;
    emit(state.copyWith(loadingMoreDuas: true));
    final result = await _duaRepo.getLatestDuas(limit: event.limit, cursor: event.cursor);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        loadingMoreDuas: false,
        latestDuas: [...state.latestDuas, ...paged.data],
        duaCursor: paged.nextCursor,
        hasMoreDuas: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(loadingMoreDuas: false, error: result.error));
    }
  }

  Future<void> _fetchMorePoems(FetchMorePoems event, Emitter<HomeState> emit) async {
    if (state.loadingMorePoems || !state.hasMorePoems) return;
    emit(state.copyWith(loadingMorePoems: true));
    final result = await _poemRepo.getLatestPoems(limit: event.limit, cursor: event.cursor);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        loadingMorePoems: false,
        latestPoems: [...state.latestPoems, ...paged.data],
        poemCursor: paged.nextCursor,
        hasMorePoems: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(loadingMorePoems: false, error: result.error));
    }
  }

  Future<void> _fetchMyDuas(FetchMyDuas event, Emitter<HomeState> emit) async {
    emit(state.copyWith(myDuasLoading: true));
    final result = await _duaRepo.getUserDuas(event.userId);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        myDuasLoading: false,
        myDuas: paged.data,
        myDuasCursor: paged.nextCursor,
        hasMoreMyDuas: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(myDuasLoading: false, myDuas: [], error: result.error));
    }
  }

  Future<void> _fetchMoreMyDuas(FetchMoreMyDuas event, Emitter<HomeState> emit) async {
    if (state.loadingMoreMyDuas || !state.hasMoreMyDuas || state.myDuasCursor == null) return;
    emit(state.copyWith(loadingMoreMyDuas: true));
    final result = await _duaRepo.getUserDuas(event.userId, cursor: event.cursor);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        loadingMoreMyDuas: false,
        myDuas: [...state.myDuas, ...paged.data],
        myDuasCursor: paged.nextCursor,
        hasMoreMyDuas: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(loadingMoreMyDuas: false, error: result.error));
    }
  }

  Future<void> _fetchMyPoems(FetchMyPoems event, Emitter<HomeState> emit) async {
    emit(state.copyWith(myPoemsLoading: true));
    final result = await _poemRepo.getUserPoems(event.userId);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        myPoemsLoading: false,
        myPoems: paged.data,
        myPoemsCursor: paged.nextCursor,
        hasMoreMyPoems: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(myPoemsLoading: false, myPoems: [], error: result.error));
    }
  }

  Future<void> _fetchMoreMyPoems(FetchMoreMyPoems event, Emitter<HomeState> emit) async {
    if (state.loadingMoreMyPoems || !state.hasMoreMyPoems || state.myPoemsCursor == null) return;
    emit(state.copyWith(loadingMoreMyPoems: true));
    final result = await _poemRepo.getUserPoems(event.userId, cursor: event.cursor);
    if (result.isSuccess) {
      final paged = result.data!;
      emit(state.copyWith(
        loadingMoreMyPoems: false,
        myPoems: [...state.myPoems, ...paged.data],
        myPoemsCursor: paged.nextCursor,
        hasMoreMyPoems: paged.hasMore,
      ));
    } else {
      emit(state.copyWith(loadingMoreMyPoems: false, error: result.error));
    }
  }

  void _onUpdateDua(UpdateDua event, Emitter<HomeState> emit) {
    final updatedLatest = state.latestDuas.map((d) {
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
    final updatedMy = state.myDuas.map((d) {
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
    emit(state.copyWith(latestDuas: updatedLatest, myDuas: updatedMy));
  }

  void _onUpdatePoem(UpdatePoem event, Emitter<HomeState> emit) {
    final updatedLatest = state.latestPoems.map((p) {
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
    final updatedMy = state.myPoems.map((p) {
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
    emit(state.copyWith(latestPoems: updatedLatest, myPoems: updatedMy));
  }

  void _onRemoveDua(RemoveDua event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      latestDuas: state.latestDuas.where((d) => d.id != event.duaId).toList(),
      myDuas: state.myDuas.where((d) => d.id != event.duaId).toList(),
    ));
  }

  void _onRemovePoem(RemovePoem event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      latestPoems: state.latestPoems.where((p) => p.id != event.poemId).toList(),
      myPoems: state.myPoems.where((p) => p.id != event.poemId).toList(),
    ));
  }

  Future<void> _search(SearchRequested event, Emitter<HomeState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(isSearching: false, searchQuery: '', searchDuas: [], searchPoems: []));
      return;
    }

    if (event.query == state.searchQuery && state.isSearching) return;

    emit(state.copyWith(
      searchQuery: event.query, isSearching: true, isSearchLoading: true, error: null,
      searchDuas: [], searchPoems: [],
      searchDuaCursor: null, searchPoemCursor: null,
      hasMoreSearchDuas: true, hasMoreSearchPoems: true,
    ));

    final queryAtCall = event.query;
    final limit = 20;
    final duasResult = await _duaRepo.search(event.query, limit: limit);
    final poemsResult = await _poemRepo.search(event.query, limit: limit);

    if (queryAtCall != state.searchQuery) return;

    final duasPaged = duasResult.isSuccess ? duasResult.data! : null;
    final poemsPaged = poemsResult.isSuccess ? poemsResult.data! : null;

    emit(state.copyWith(
      isSearchLoading: false,
      searchDuas: duasPaged?.data ?? [],
      searchPoems: poemsPaged?.data ?? [],
      searchDuaCursor: duasPaged?.nextCursor,
      searchPoemCursor: poemsPaged?.nextCursor,
      hasMoreSearchDuas: duasPaged?.hasMore ?? false,
      hasMoreSearchPoems: poemsPaged?.hasMore ?? false,
      error: (!duasResult.isSuccess || !poemsResult.isSuccess) ? 'Search failed for some results' : null,
    ));
  }

  Future<void> _searchMore(FetchMoreSearchResults event, Emitter<HomeState> emit) async {
    if (state.loadingMoreSearch) return;

    emit(state.copyWith(loadingMoreSearch: true));

    final queryAtCall = event.query;

    if (event.showDuasTab) {
      if (!state.hasMoreSearchDuas || state.searchDuaCursor == null) {
        emit(state.copyWith(loadingMoreSearch: false));
        return;
      }
      final result = await _duaRepo.search(event.query, limit: event.limit, cursor: state.searchDuaCursor);
      if (queryAtCall != state.searchQuery) { emit(state.copyWith(loadingMoreSearch: false)); return; }
      if (result.isSuccess) {
        final paged = result.data!;
        emit(state.copyWith(
          loadingMoreSearch: false,
          searchDuas: [...state.searchDuas, ...paged.data],
          searchDuaCursor: paged.nextCursor,
          hasMoreSearchDuas: paged.hasMore,
        ));
      } else {
        emit(state.copyWith(loadingMoreSearch: false));
      }
    } else {
      if (!state.hasMoreSearchPoems || state.searchPoemCursor == null) {
        emit(state.copyWith(loadingMoreSearch: false));
        return;
      }
      final result = await _poemRepo.search(event.query, limit: event.limit, cursor: state.searchPoemCursor);
      if (queryAtCall != state.searchQuery) { emit(state.copyWith(loadingMoreSearch: false)); return; }
      if (result.isSuccess) {
        final paged = result.data!;
        emit(state.copyWith(
          loadingMoreSearch: false,
          searchPoems: [...state.searchPoems, ...paged.data],
          searchPoemCursor: paged.nextCursor,
          hasMoreSearchPoems: paged.hasMore,
        ));
      } else {
        emit(state.copyWith(loadingMoreSearch: false));
      }
    }
  }
}
