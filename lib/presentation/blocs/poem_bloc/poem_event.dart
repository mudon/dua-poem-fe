abstract class PoemEvent {}

class ToggleLike extends PoemEvent {
  final String poemId;
  final bool currentlyLiked;
  final int currentCount;
  ToggleLike(this.poemId, this.currentlyLiked, this.currentCount);
}

class ToggleBookmark extends PoemEvent {
  final String poemId;
  final bool currentlyFavorited;
  final int currentCount;
  ToggleBookmark(this.poemId, this.currentlyFavorited, this.currentCount);
}

class RecordView extends PoemEvent {
  final String poemId;
  final int viewCount;
  RecordView(this.poemId, this.viewCount);
}

class ReportPoem extends PoemEvent {
  final String poemId;
  final String reason;
  final String description;
  ReportPoem(this.poemId, this.reason, this.description);
}

class SignalRLikeCountUpdated extends PoemEvent {
  final String poemId;
  final int likesCount;
  SignalRLikeCountUpdated(this.poemId, this.likesCount);
}

class SignalRFavoritesCountUpdated extends PoemEvent {
  final String poemId;
  final int favoritesCount;
  SignalRFavoritesCountUpdated(this.poemId, this.favoritesCount);
}

class SignalRViewsCountUpdated extends PoemEvent {
  final String poemId;
  final int viewsCount;
  SignalRViewsCountUpdated(this.poemId, this.viewsCount);
}

class SignalRReportsCountUpdated extends PoemEvent {
  final String poemId;
  final int reportsCount;
  SignalRReportsCountUpdated(this.poemId, this.reportsCount);
}

class SignalRReportReturned extends PoemEvent {
  final String poemId;
  SignalRReportReturned(this.poemId);
}

class UpdatePoem extends PoemEvent {
  final String poemId;
  final String title;
  final String? content;
  final String? transliteration;
  final String? translation;
  UpdatePoem({
    required this.poemId,
    required this.title,
    this.content,
    this.transliteration,
    this.translation,
  });
}

class DeletePoem extends PoemEvent {
  final String poemId;
  DeletePoem(this.poemId);
}

class PoemCreated extends PoemEvent {}

class ClearReturnedReports extends PoemEvent {}

class SignalRPoemDeleted extends PoemEvent {
  final String poemId;
  SignalRPoemDeleted(this.poemId);
}

class SignalRPoemContentUpdated extends PoemEvent {
  final String poemId;
  final String title;
  final String? content;
  final String? transliteration;
  final String? translation;
  final String? description;
  final String? author;
  final String updatedAt;
  SignalRPoemContentUpdated({
    required this.poemId,
    required this.title,
    this.content,
    this.transliteration,
    this.translation,
    this.description,
    this.author,
    required this.updatedAt,
  });
}
