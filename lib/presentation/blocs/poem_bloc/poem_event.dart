abstract class PoemEvent {}

class ToggleLike extends PoemEvent {
  final String poemId;
  final bool currentlyLiked;
  ToggleLike(this.poemId, this.currentlyLiked);
}

class ToggleBookmark extends PoemEvent {
  final String poemId;
  final bool currentlyFavorited;
  ToggleBookmark(this.poemId, this.currentlyFavorited);
}

class ReportPoem extends PoemEvent {
  final String poemId;
  final String reason;
  final String description;
  ReportPoem(this.poemId, this.reason, this.description);
}
