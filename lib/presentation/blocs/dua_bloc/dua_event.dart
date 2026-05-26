abstract class DuaEvent {}

class ToggleLike extends DuaEvent {
  final int duaId;
  ToggleLike(this.duaId);
}

class ToggleBookmark extends DuaEvent {
  final int duaId;
  ToggleBookmark(this.duaId);
}

class ReportDua extends DuaEvent {
  final int duaId;
  final String reason;
  final String description;
  ReportDua(this.duaId, this.reason, this.description);
}
