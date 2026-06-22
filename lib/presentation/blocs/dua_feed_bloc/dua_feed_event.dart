import '../../../data/models/dua_model.dart';

abstract class DuaFeedEvent {}

class FetchLatestDuas extends DuaFeedEvent {
  final int limit;
  FetchLatestDuas({this.limit = 20});
}

class FetchOlderDuas extends DuaFeedEvent {}

class FetchLatterDuas extends DuaFeedEvent {}

class ResetDuas extends DuaFeedEvent {
  final int limit;
  ResetDuas({this.limit = 20});
}

class InsertDuaToFeed extends DuaFeedEvent {
  final DuaModel dua;
  InsertDuaToFeed(this.dua);
}

class RemoveDuaFromFeed extends DuaFeedEvent {
  final String duaId;
  RemoveDuaFromFeed(this.duaId);
}

class UpdateDuaInFeed extends DuaFeedEvent {
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
  UpdateDuaInFeed({
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
