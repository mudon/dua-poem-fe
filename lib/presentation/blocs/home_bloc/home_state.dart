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
  final List<DuaModel> myDuas;
  final bool myDuasLoading;
  final List<PoemModel> myPoems;
  final bool myPoemsLoading;
  final int duaOffset;
  final int poemOffset;
  final bool hasMoreDuas;
  final bool hasMorePoems;
  final bool loadingMoreDuas;
  final bool loadingMorePoems;

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
    this.myDuas = const [],
    this.myDuasLoading = false,
    this.myPoems = const [],
    this.myPoemsLoading = false,
    this.duaOffset = 0,
    this.poemOffset = 0,
    this.hasMoreDuas = true,
    this.hasMorePoems = true,
    this.loadingMoreDuas = false,
    this.loadingMorePoems = false,
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
    List<DuaModel>? myDuas,
    bool? myDuasLoading,
    List<PoemModel>? myPoems,
    bool? myPoemsLoading,
    int? duaOffset,
    int? poemOffset,
    bool? hasMoreDuas,
    bool? hasMorePoems,
    bool? loadingMoreDuas,
    bool? loadingMorePoems,
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
      myDuas: myDuas ?? this.myDuas,
      myDuasLoading: myDuasLoading ?? this.myDuasLoading,
      myPoems: myPoems ?? this.myPoems,
      myPoemsLoading: myPoemsLoading ?? this.myPoemsLoading,
      duaOffset: duaOffset ?? this.duaOffset,
      poemOffset: poemOffset ?? this.poemOffset,
      hasMoreDuas: hasMoreDuas ?? this.hasMoreDuas,
      hasMorePoems: hasMorePoems ?? this.hasMorePoems,
      loadingMoreDuas: loadingMoreDuas ?? this.loadingMoreDuas,
      loadingMorePoems: loadingMorePoems ?? this.loadingMorePoems,
    );
  }
}
