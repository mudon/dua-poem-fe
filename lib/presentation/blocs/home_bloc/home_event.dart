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

class FetchMyDuas extends HomeEvent {
  final String userId;
  FetchMyDuas(this.userId);
}

class FetchMyPoems extends HomeEvent {
  final String userId;
  FetchMyPoems(this.userId);
}

class UpdateDua extends HomeEvent {
  final String duaId;
  final bool? isLiked;
  final int? likeCount;
  final bool? isFavorited;
  final int? bookmarkCount;
  UpdateDua({
    required this.duaId,
    this.isLiked,
    this.likeCount,
    this.isFavorited,
    this.bookmarkCount,
  });
}

class UpdatePoem extends HomeEvent {
  final String poemId;
  final bool? isLiked;
  final int? likeCount;
  final bool? isFavorited;
  final int? bookmarkCount;
  UpdatePoem({
    required this.poemId,
    this.isLiked,
    this.likeCount,
    this.isFavorited,
    this.bookmarkCount,
  });
}
