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
}
