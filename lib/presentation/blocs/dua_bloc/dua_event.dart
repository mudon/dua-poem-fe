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

class SignalRFavoritesCountUpdated extends DuaEvent {
  final String duaId;
  final int favoritesCount;
  SignalRFavoritesCountUpdated(this.duaId, this.favoritesCount);
}

class SignalRViewsCountUpdated extends DuaEvent {
  final String duaId;
  final int viewsCount;
  SignalRViewsCountUpdated(this.duaId, this.viewsCount);
}

class SignalRReportsCountUpdated extends DuaEvent {
  final String duaId;
  final int reportsCount;
  SignalRReportsCountUpdated(this.duaId, this.reportsCount);
}

class SignalRReportReturned extends DuaEvent {
  final String duaId;
  SignalRReportReturned(this.duaId);
}

class ClearReturnedReports extends DuaEvent {}

class SignalRDuaContentUpdated extends DuaEvent {
  final String duaId;
  final String title;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? description;
  final String? whenToRecite;
  final String? occasion;
  final int repetitionCount;
  final String updatedAt;
  SignalRDuaContentUpdated({
    required this.duaId,
    required this.title,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.description,
    this.whenToRecite,
    this.occasion,
    required this.repetitionCount,
    required this.updatedAt,
  });
}
