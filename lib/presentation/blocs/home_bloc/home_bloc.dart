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
    on<ToggleHomeTab>((event, emit) => emit(state.copyWith(showDuasTab: event.showDuas)));
    on<SearchRequested>(_search);
    on<ClearSearch>((event, emit) => emit(state.copyWith(isSearching: false, searchQuery: '', searchDuas: [], searchPoems: [])));
    on<FetchMyDuas>(_fetchMyDuas);
    on<FetchMyPoems>(_fetchMyPoems);
    on<UpdateDua>(_onUpdateDua);
    on<UpdatePoem>(_onUpdatePoem);
  }

  Future<void> _fetchDuas(FetchLatestDuas event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _duaRepo.getLatestDuas();
    if (result.isSuccess) {
      emit(state.copyWith(isLoading: false, latestDuas: result.data!));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _fetchPoems(FetchLatestPoems event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _poemRepo.getLatestPoems();
    if (result.isSuccess) {
      emit(state.copyWith(isLoading: false, latestPoems: result.data!));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _fetchMyDuas(FetchMyDuas event, Emitter<HomeState> emit) async {
    emit(state.copyWith(myDuasLoading: true));
    final result = await _duaRepo.getUserDuas(event.userId);
    emit(state.copyWith(
      myDuasLoading: false,
      myDuas: result.isSuccess ? result.data! : [],
      error: !result.isSuccess ? result.error : null,
    ));
  }

  Future<void> _fetchMyPoems(FetchMyPoems event, Emitter<HomeState> emit) async {
    emit(state.copyWith(myPoemsLoading: true));
    final result = await _poemRepo.getUserPoems(event.userId);
    emit(state.copyWith(
      myPoemsLoading: false,
      myPoems: result.isSuccess ? result.data! : [],
      error: !result.isSuccess ? result.error : null,
    ));
  }

  void _onUpdateDua(UpdateDua event, Emitter<HomeState> emit) {
    final updatedLatest = state.latestDuas.map((d) {
      if (d.id != event.duaId) return d;
      return d.copyWith(
        isLiked: event.isLiked,
        likeCount: event.likeCount,
        isFavorited: event.isFavorited,
        bookmarkCount: event.bookmarkCount,
      );
    }).toList();
    final updatedMy = state.myDuas.map((d) {
      if (d.id != event.duaId) return d;
      return d.copyWith(
        isLiked: event.isLiked,
        likeCount: event.likeCount,
        isFavorited: event.isFavorited,
        bookmarkCount: event.bookmarkCount,
      );
    }).toList();
    emit(state.copyWith(latestDuas: updatedLatest, myDuas: updatedMy));
  }

  void _onUpdatePoem(UpdatePoem event, Emitter<HomeState> emit) {
    final updatedLatest = state.latestPoems.map((p) {
      if (p.id != event.poemId) return p;
      return p.copyWith(
        isLiked: event.isLiked,
        likeCount: event.likeCount,
        isFavorited: event.isFavorited,
        bookmarkCount: event.bookmarkCount,
      );
    }).toList();
    final updatedMy = state.myPoems.map((p) {
      if (p.id != event.poemId) return p;
      return p.copyWith(
        isLiked: event.isLiked,
        likeCount: event.likeCount,
        isFavorited: event.isFavorited,
        bookmarkCount: event.bookmarkCount,
      );
    }).toList();
    emit(state.copyWith(latestPoems: updatedLatest, myPoems: updatedMy));
  }

  Future<void> _search(SearchRequested event, Emitter<HomeState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(isSearching: false, searchQuery: '', searchDuas: [], searchPoems: []));
      return;
    }

    emit(state.copyWith(searchQuery: event.query, isSearching: true, error: null));

    final duasResult = await _duaRepo.search(event.query);
    final poemsResult = await _poemRepo.search(event.query);

    emit(state.copyWith(
      isSearching: false,
      searchDuas: duasResult.isSuccess ? duasResult.data! : [],
      searchPoems: poemsResult.isSuccess ? poemsResult.data! : [],
      error: (!duasResult.isSuccess || !poemsResult.isSuccess) ? 'Search failed for some results' : null,
    ));
  }
}
