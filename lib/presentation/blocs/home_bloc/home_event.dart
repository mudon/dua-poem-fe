abstract class HomeEvent {}

class FetchLatestDuas extends HomeEvent {}

class FetchLatestPoems extends HomeEvent {}

class ToggleHomeTab extends HomeEvent {
  final bool showDuas;
  ToggleHomeTab(this.showDuas);
}

class SearchRequested extends HomeEvent {
  final String query;
  SearchRequested(this.query);
}

class ClearSearch extends HomeEvent {}
