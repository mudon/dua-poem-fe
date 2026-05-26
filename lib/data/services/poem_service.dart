import '../models/poem_model.dart';

class PoemService {
  Future<List<PoemModel>> getLatestPoems() async {
    return _mockPoems;
  }

  Future<List<PoemModel>> getUserPoems(int userId) async {
    return _mockPoems;
  }

  Future<PoemModel> getPoemDetail(int id) async {
    return _mockPoems.first;
  }

  Future<void> toggleBookmark(int poemId) async {}

  Future<void> toggleLike(int poemId) async {}

  Future<void> reportPoem(int poemId, String reason, String description) async {}
}

final _mockPoems = [
  PoemModel(
    id: 1,
    title: 'The Seeking Heart',
    verified: true,
    content: 'In every breath a chance to turn,\nTo seek the light for which we yearn.',
    translation: 'A poem about turning towards the Divine',
    category: 'Spiritual',
    tags: ['seeking', 'light'],
    userId: 1,
    userName: 'Zahra Amin',
    userAvatar: 'ZA',
    views: '3.4k',
    bookmarkCount: 67,
    likeCount: 189,
    reportCount: 0,
  ),
  PoemModel(
    id: 2,
    title: 'Waves of Mercy',
    verified: false,
    content: 'Like waves upon the endless shore,\nHis mercy flows forevermore.',
    translation: 'A poem about divine mercy',
    category: 'Mercy',
    tags: ['mercy', 'ocean'],
    userId: 2,
    userName: 'Omar Hasan',
    userAvatar: 'OH',
    views: '1.1k',
    bookmarkCount: 34,
    likeCount: 95,
    reportCount: 0,
  ),
];
