import '../../../data/models/dua_model.dart';
import '../../../data/models/poem_model.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final List<DuaModel> latestDuas;
  final List<PoemModel> latestPoems;
  final bool showDuasTab;

  HomeState({
    this.isLoading = false,
    this.error,
    this.latestDuas = const [],
    this.latestPoems = const [],
    this.showDuasTab = true,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<DuaModel>? latestDuas,
    List<PoemModel>? latestPoems,
    bool? showDuasTab,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      latestDuas: latestDuas ?? this.latestDuas,
      latestPoems: latestPoems ?? this.latestPoems,
      showDuasTab: showDuasTab ?? this.showDuasTab,
    );
  }
}
