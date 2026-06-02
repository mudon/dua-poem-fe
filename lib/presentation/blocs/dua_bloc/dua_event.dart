abstract class DuaEvent {}

class ToggleLike extends DuaEvent {
  final String duaId;
  final bool currentlyLiked;
  final int currentCount;
  ToggleLike(this.duaId, this.currentlyLiked, this.currentCount);
}

class ToggleBookmark extends DuaEvent {
  final String duaId;
  final bool currentlyFavorited;
  final int currentCount;
  ToggleBookmark(this.duaId, this.currentlyFavorited, this.currentCount);
}

class RecordView extends DuaEvent {
  final String duaId;
  final int viewCount;
  RecordView(this.duaId, this.viewCount);
}

class ReportDua extends DuaEvent {
  final String duaId;
  final String reason;
  final String description;
  ReportDua(this.duaId, this.reason, this.description);
}

class SignalRLikeCountUpdated extends DuaEvent {
  final String duaId;
  final int likesCount;
  SignalRLikeCountUpdated(this.duaId, this.likesCount);
}
