import '../../../data/models/dua_model.dart';
import '../../../data/models/poem_model.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final List<DuaModel> latestDuas;
  final List<PoemModel> latestPoems;
  final bool showDuasTab;
  final bool isSearching;
  final String searchQuery;
  final List<DuaModel> searchDuas;
  final List<PoemModel> searchPoems;

  HomeState({
    this.isLoading = false,
    this.error,
    this.latestDuas = const [],
    this.latestPoems = const [],
    this.showDuasTab = true,
    this.isSearching = false,
    this.searchQuery = '',
    this.searchDuas = const [],
    this.searchPoems = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<DuaModel>? latestDuas,
    List<PoemModel>? latestPoems,
    bool? showDuasTab,
    bool? isSearching,
    String? searchQuery,
    List<DuaModel>? searchDuas,
    List<PoemModel>? searchPoems,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      latestDuas: latestDuas ?? this.latestDuas,
      latestPoems: latestPoems ?? this.latestPoems,
      showDuasTab: showDuasTab ?? this.showDuasTab,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchDuas: searchDuas ?? this.searchDuas,
      searchPoems: searchPoems ?? this.searchPoems,
    );
  }
}
