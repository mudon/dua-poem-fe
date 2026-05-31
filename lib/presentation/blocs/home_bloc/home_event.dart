abstract class HomeEvent {}

class FetchLatestDuas extends HomeEvent {
  final int limit;
  final int offset;
  FetchLatestDuas({this.limit = 20, this.offset = 0});
}

class FetchLatestPoems extends HomeEvent {
  final int limit;
  final int offset;
  FetchLatestPoems({this.limit = 20, this.offset = 0});
}

class FetchMoreDuas extends HomeEvent {
  final int limit;
  final int offset;
  FetchMoreDuas({required this.limit, required this.offset});
}

class FetchMorePoems extends HomeEvent {
  final int limit;
  final int offset;
  FetchMorePoems({required this.limit, required this.offset});
}

class ToggleHomeTab extends HomeEvent {
  final bool showDuas;
  ToggleHomeTab(this.showDuas);
}

class SearchRequested extends HomeEvent {
  final String query;
  SearchRequested(this.query);
}

class ClearSearch extends HomeEvent {}

class FetchMoreSearchResults extends HomeEvent {
  final String query;
  final bool showDuasTab;
  final int limit;
  FetchMoreSearchResults({required this.query, required this.showDuasTab, this.limit = 20});
}

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
  final int? views;
  final int? reportCount;
  UpdateDua({
    required this.duaId,
    this.isLiked,
    this.likeCount,
    this.isFavorited,
    this.bookmarkCount,
    this.views,
    this.reportCount,
  });
}

class UpdatePoem extends HomeEvent {
  final String poemId;
  final bool? isLiked;
  final int? likeCount;
  final bool? isFavorited;
  final int? bookmarkCount;
  final int? views;
  final int? reportCount;
  UpdatePoem({
    required this.poemId,
    this.isLiked,
    this.likeCount,
    this.isFavorited,
    this.bookmarkCount,
    this.views,
    this.reportCount,
  });
}
