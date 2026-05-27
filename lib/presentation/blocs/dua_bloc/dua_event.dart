abstract class DuaEvent {}

class ToggleLike extends DuaEvent {
  final String duaId;
  ToggleLike(this.duaId);
}

class ToggleBookmark extends DuaEvent {
  final String duaId;
  ToggleBookmark(this.duaId);
}

class ReportDua extends DuaEvent {
  final String duaId;
  final String reason;
  final String description;
  ReportDua(this.duaId, this.reason, this.description);
}
