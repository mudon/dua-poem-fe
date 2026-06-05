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

class ClearReturnedReports extends PoemEvent {}
