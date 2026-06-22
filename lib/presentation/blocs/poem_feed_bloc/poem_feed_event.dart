import '../../../data/models/poem_model.dart';

abstract class PoemFeedEvent {}

class FetchLatestPoems extends PoemFeedEvent {
  final int limit;
  FetchLatestPoems({this.limit = 20});
}

class FetchOlderPoems extends PoemFeedEvent {}

class FetchLatterPoems extends PoemFeedEvent {}

class ResetPoems extends PoemFeedEvent {
  final int limit;
  ResetPoems({this.limit = 20});
}

class InsertPoemToFeed extends PoemFeedEvent {
  final PoemModel poem;
  InsertPoemToFeed(this.poem);
}

class RemovePoemFromFeed extends PoemFeedEvent {
  final String poemId;
  RemovePoemFromFeed(this.poemId);
}

class UpdatePoemInFeed extends PoemFeedEvent {
  final String poemId;
  final bool? isLiked;
  final int? likeCount;
  final bool? isFavorited;
  final int? bookmarkCount;
  final int? views;
  final int? reportCount;
  final String? title;
  final String? content;
  final String? transliteration;
  final String? translation;
  final String? description;
  final String? author;
  final String? updatedAt;
  UpdatePoemInFeed({
    required this.poemId,
    this.isLiked,
    this.likeCount,
    this.isFavorited,
    this.bookmarkCount,
    this.views,
    this.reportCount,
    this.title,
    this.content,
    this.transliteration,
    this.translation,
    this.description,
    this.author,
    this.updatedAt,
  });
}
