abstract class DuaEvent {}

class ToggleLike extends DuaEvent {
  final String duaId;
  final bool currentlyLiked;
  ToggleLike(this.duaId, this.currentlyLiked);
}

class ToggleBookmark extends DuaEvent {
  final String duaId;
  final bool currentlyFavorited;
  ToggleBookmark(this.duaId, this.currentlyFavorited);
}

class ReportDua extends DuaEvent {
  final String duaId;
  final String reason;
  final String description;
  ReportDua(this.duaId, this.reason, this.description);
}
