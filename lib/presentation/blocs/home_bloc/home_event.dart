abstract class HomeEvent {}

class FetchLatestDuas extends HomeEvent {
  final int limit;
  FetchLatestDuas({this.limit = 20});
}

class FetchLatestPoems extends HomeEvent {
  final int limit;
  FetchLatestPoems({this.limit = 20});
}

class FetchMoreDuas extends HomeEvent {
  final int limit;
  final String cursor;
  FetchMoreDuas({required this.limit, required this.cursor});
}

class FetchMorePoems extends HomeEvent {
  final int limit;
  final String cursor;
  FetchMorePoems({required this.limit, required this.cursor});
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

class FetchMoreMyDuas extends HomeEvent {
  final String userId;
  final String cursor;
  FetchMoreMyDuas({required this.userId, required this.cursor});
}

class FetchMyPoems extends HomeEvent {
  final String userId;
  FetchMyPoems(this.userId);
}

class FetchMoreMyPoems extends HomeEvent {
  final String userId;
  final String cursor;
  FetchMoreMyPoems({required this.userId, required this.cursor});
}

class UpdateDua extends HomeEvent {
  final String duaId;
  final bool? isLiked;
  final int? likeCount;
  final bool? isFavorited;
  final int? bookmarkCount;
  final int? views;
  final int? reportCount;
  final String? title;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? description;
  final String? whenToRecite;
  final String? occasion;
  final int? repetitionCount;
  final String? updatedAt;
  UpdateDua({
    required this.duaId,
    this.isLiked,
    this.likeCount,
    this.isFavorited,
    this.bookmarkCount,
    this.views,
    this.reportCount,
    this.title,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.description,
    this.whenToRecite,
    this.occasion,
    this.repetitionCount,
    this.updatedAt,
  });
}

class RemoveDua extends HomeEvent {
  final String duaId;
  RemoveDua(this.duaId);
}

class RemovePoem extends HomeEvent {
  final String poemId;
  RemovePoem(this.poemId);
}

class UpdatePoem extends HomeEvent {
  final String poemId;
  final bool? isLiked;
  final int? likeCount;
  final bool? isFavorited;
  final int? bookmarkCount;
  final int? views;
  final int? reportCount;
  final String? title;
  final String? content;
  final String? transliteration;
  final String? translation;
  final String? description;
  final String? author;
  final String? updatedAt;
  UpdatePoem({
    required this.poemId,
    this.isLiked,
    this.likeCount,
    this.isFavorited,
    this.bookmarkCount,
    this.views,
    this.reportCount,
    this.title,
    this.content,
    this.transliteration,
    this.translation,
    this.description,
    this.author,
    this.updatedAt,
  });
}
