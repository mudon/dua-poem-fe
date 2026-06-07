import '../../../data/models/dua_model.dart';
import '../../../data/models/poem_model.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final List<DuaModel> latestDuas;
  final List<PoemModel> latestPoems;
  final bool showDuasTab;
  final bool showMyPostsDuasTab;
  final bool isSearching;
  final bool isSearchLoading;
  final String searchQuery;
  final List<DuaModel> searchDuas;
  final List<PoemModel> searchPoems;
  final String? searchDuaCursor;
  final String? searchPoemCursor;
  final bool hasMoreSearchDuas;
  final bool hasMoreSearchPoems;
  final bool loadingMoreSearch;
  final List<DuaModel> myDuas;
  final bool myDuasLoading;
  final String? myDuasCursor;
  final bool hasMoreMyDuas;
  final bool loadingMoreMyDuas;
  final List<PoemModel> myPoems;
  final bool myPoemsLoading;
  final String? myPoemsCursor;
  final bool hasMoreMyPoems;
  final bool loadingMoreMyPoems;
  final String? duaCursor;
  final String? poemCursor;
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
    this.showMyPostsDuasTab = true,
    this.isSearching = false,
    this.isSearchLoading = false,
    this.searchQuery = '',
    this.searchDuas = const [],
    this.searchPoems = const [],
    this.searchDuaCursor,
    this.searchPoemCursor,
    this.hasMoreSearchDuas = true,
    this.hasMoreSearchPoems = true,
    this.loadingMoreSearch = false,
    this.myDuas = const [],
    this.myDuasLoading = false,
    this.myDuasCursor,
    this.hasMoreMyDuas = true,
    this.loadingMoreMyDuas = false,
    this.myPoems = const [],
    this.myPoemsLoading = false,
    this.myPoemsCursor,
    this.hasMoreMyPoems = true,
    this.loadingMoreMyPoems = false,
    this.duaCursor,
    this.poemCursor,
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
    bool? showMyPostsDuasTab,
    bool? isSearching,
    bool? isSearchLoading,
    String? searchQuery,
    List<DuaModel>? searchDuas,
    List<PoemModel>? searchPoems,
    String? searchDuaCursor,
    String? searchPoemCursor,
    bool? hasMoreSearchDuas,
    bool? hasMoreSearchPoems,
    bool? loadingMoreSearch,
    List<DuaModel>? myDuas,
    bool? myDuasLoading,
    String? myDuasCursor,
    bool? hasMoreMyDuas,
    bool? loadingMoreMyDuas,
    List<PoemModel>? myPoems,
    bool? myPoemsLoading,
    String? myPoemsCursor,
    bool? hasMoreMyPoems,
    bool? loadingMoreMyPoems,
    String? duaCursor,
    String? poemCursor,
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
      showMyPostsDuasTab: showMyPostsDuasTab ?? this.showMyPostsDuasTab,
      isSearching: isSearching ?? this.isSearching,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      searchDuas: searchDuas ?? this.searchDuas,
      searchPoems: searchPoems ?? this.searchPoems,
      searchDuaCursor: searchDuaCursor ?? this.searchDuaCursor,
      searchPoemCursor: searchPoemCursor ?? this.searchPoemCursor,
      hasMoreSearchDuas: hasMoreSearchDuas ?? this.hasMoreSearchDuas,
      hasMoreSearchPoems: hasMoreSearchPoems ?? this.hasMoreSearchPoems,
      loadingMoreSearch: loadingMoreSearch ?? this.loadingMoreSearch,
      myDuas: myDuas ?? this.myDuas,
      myDuasLoading: myDuasLoading ?? this.myDuasLoading,
      myDuasCursor: myDuasCursor ?? this.myDuasCursor,
      hasMoreMyDuas: hasMoreMyDuas ?? this.hasMoreMyDuas,
      loadingMoreMyDuas: loadingMoreMyDuas ?? this.loadingMoreMyDuas,
      myPoems: myPoems ?? this.myPoems,
      myPoemsLoading: myPoemsLoading ?? this.myPoemsLoading,
      myPoemsCursor: myPoemsCursor ?? this.myPoemsCursor,
      hasMoreMyPoems: hasMoreMyPoems ?? this.hasMoreMyPoems,
      loadingMoreMyPoems: loadingMoreMyPoems ?? this.loadingMoreMyPoems,
      duaCursor: duaCursor ?? this.duaCursor,
      poemCursor: poemCursor ?? this.poemCursor,
      hasMoreDuas: hasMoreDuas ?? this.hasMoreDuas,
      hasMorePoems: hasMorePoems ?? this.hasMorePoems,
      loadingMoreDuas: loadingMoreDuas ?? this.loadingMoreDuas,
      loadingMorePoems: loadingMorePoems ?? this.loadingMorePoems,
    );
  }
}
