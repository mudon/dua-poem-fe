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

class ReportPoem extends PoemEvent {
  final String poemId;
  final String reason;
  final String description;
  ReportPoem(this.poemId, this.reason, this.description);
}
