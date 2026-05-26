import '../models/poem_model.dart';

class PoemService {
  Future<List<PoemModel>> getLatestPoems() async {
    return _mockPoems;
  }

  Future<List<PoemModel>> getUserPoems(int userId) async {
    return _mockPoems.where((p) => p.userId == userId).toList();
  }

  Future<PoemModel> getPoemDetail(int id) async {
    return _mockPoems.firstWhere((p) => p.id == id, orElse: () => _mockPoems.first);
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
    content: 'In every breath a chance to turn,\nTo seek the light for which we yearn.\nThrough darkest nights and weary days,\nYour mercy meets us in a gaze.',
    translation: 'A poem about turning towards the Divine',
    category: 'Spiritual',
    tags: ['Seeking', 'Light'],
    userId: 4,
    userName: 'Layla Akhtar',
    userAvatar: 'LA',
    views: '3.4k',
    bookmarkCount: 67,
    likeCount: 189,
    reportCount: 0,
  ),
  PoemModel(
    id: 2,
    title: 'Waves of Mercy',
    verified: false,
    content: 'Like waves upon the endless shore,\nHis mercy flows forevermore.\nEach rising tide a fresh embrace,\nA sign of everlasting grace.',
    translation: 'A poem about divine mercy',
    category: 'Mercy',
    tags: ['Mercy', 'Ocean'],
    userId: 5,
    userName: 'Yusuf Mansur',
    userAvatar: 'YM',
    views: '1.1k',
    bookmarkCount: 34,
    likeCount: 95,
    reportCount: 0,
  ),
  PoemModel(
    id: 3,
    title: 'My Sunrise Prayer',
    verified: true,
    content: 'Before the dawn breaks, I raise my hands,\nA silent plea across the lands.\nWith morning light my soul takes flight,\nSeeking refuge in Your might.',
    translation: 'A prayer poem at dawn',
    category: 'Faith',
    tags: ['Faith', 'Prayer'],
    userId: 3,
    userName: 'You',
    userAvatar: 'ME',
    views: '672',
    bookmarkCount: 15,
    likeCount: 42,
    reportCount: 0,
  ),
];
