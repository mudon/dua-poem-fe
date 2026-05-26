import '../models/dua_model.dart';

class DuaService {
  Future<List<DuaModel>> getLatestDuas() async {
    return _mockDuas;
  }

  Future<List<DuaModel>> getUserDuas(int userId) async {
    return _mockDuas;
  }

  Future<DuaModel> getDuaDetail(int id) async {
    return _mockDuas.first;
  }

  Future<void> toggleBookmark(int duaId) async {}

  Future<void> toggleLike(int duaId) async {}

  Future<void> reportDua(int duaId, String reason, String description) async {}
}

final _mockDuas = [
  DuaModel(
    id: 1,
    title: 'Dua for Peace',
    verified: true,
    arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
    transliteration: 'Rabbana atina fid-dunya hasanah',
    translation: 'Our Lord, give us in this world good',
    category: 'General',
    tags: ['peace', 'blessings'],
    userId: 1,
    userName: 'Zahra Amin',
    userAvatar: 'ZA',
    views: '1.2k',
    bookmarkCount: 45,
    likeCount: 120,
    reportCount: 0,
  ),
  DuaModel(
    id: 2,
    title: 'Morning Dua',
    verified: false,
    arabicText: 'اللَّهُمَّ بِكَ أَصْبَحْنَا',
    translation: 'O Allah, with You we have reached the morning',
    category: 'Morning',
    tags: ['morning', 'protection'],
    userId: 2,
    userName: 'Omar Hasan',
    userAvatar: 'OH',
    views: '890',
    bookmarkCount: 23,
    likeCount: 67,
    reportCount: 0,
  ),
  DuaModel(
    id: 3,
    title: 'Dua for Knowledge',
    verified: true,
    arabicText: 'رَبِّ زِدْنِي عِلْمًا',
    transliteration: 'Rabbi zidni ilma',
    translation: 'My Lord, increase me in knowledge',
    category: 'Knowledge',
    tags: ['knowledge', 'study'],
    userId: 1,
    userName: 'Zahra Amin',
    userAvatar: 'ZA',
    views: '2.1k',
    bookmarkCount: 89,
    likeCount: 210,
    reportCount: 0,
  ),
];
