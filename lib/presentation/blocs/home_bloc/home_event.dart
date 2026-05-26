abstract class HomeEvent {}

class FetchLatestDuas extends HomeEvent {}

class FetchLatestPoems extends HomeEvent {}

class ToggleHomeTab extends HomeEvent {
  final bool showDuas;
  ToggleHomeTab(this.showDuas);
}
