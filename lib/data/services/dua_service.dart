import '../models/dua_model.dart';

class DuaService {
  final _reportCounts = <int, int>{};

  int getReportCount(int duaId) => _reportCounts[duaId] ?? 0;

  void addReport(int duaId, String reason, String description) {
    _reportCounts[duaId] = (_reportCounts[duaId] ?? 0) + 1;
  }

  Future<List<DuaModel>> getLatestDuas() async {
    return _mockDuas;
  }

  Future<List<DuaModel>> getUserDuas(int userId) async {
    return _mockDuas.where((d) => d.userId == userId).toList();
  }

  Future<DuaModel> getDuaDetail(int id) async {
    return _mockDuas.firstWhere((d) => d.id == id, orElse: () => _mockDuas.first);
  }

  Future<void> toggleBookmark(int duaId) async {}

  Future<void> toggleLike(int duaId) async {}

  Future<void> reportDua(int duaId, String reason, String description) async {}
}

final _mockDuas = [
  DuaModel(
    id: 1,
    title: 'Dua for Peace of Heart',
    verified: true,
    arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
    transliteration: 'Rabbana atina fid-dunya hasanah',
    translation: 'Our Lord, give us good in this world and protect us from the punishment of the Fire.',
    category: 'Peace',
    tags: ['Tranquility', 'Blessings'],
    userId: 1,
    userName: 'Aisha Mahmoud',
    userAvatar: 'AM',
    views: '3.2k',
    bookmarkCount: 45,
    likeCount: 120,
    reportCount: 0,
  ),
  DuaModel(
    id: 2,
    title: 'Dua for Parents',
    verified: true,
    arabicText: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
    translation: 'My Lord, have mercy on them as they raised me when I was young.',
    category: 'Family',
    tags: ['Mercy', 'Parents'],
    userId: 2,
    userName: 'Omar Farooq',
    userAvatar: 'OF',
    views: '1.8k',
    bookmarkCount: 23,
    likeCount: 67,
    reportCount: 0,
  ),
  DuaModel(
    id: 3,
    title: 'My Daily Gratitude Dua',
    verified: false,
    arabicText: 'الْحَمْدُ لِلَّهِ عَلَى كُلِّ حَالٍ',
    translation: 'All praise is for Allah in every circumstance.',
    category: 'Gratitude',
    tags: ['Thankfulness'],
    userId: 3,
    userName: 'You',
    userAvatar: 'ME',
    views: '234',
    bookmarkCount: 89,
    likeCount: 210,
    reportCount: 0,
  ),
  DuaModel(
    id: 4,
    title: 'Dua for Exams',
    verified: true,
    arabicText: 'رَبِّ اشْرَحْ لِي صَدْرِي',
    transliteration: 'Rabbi ishrah li sadri',
    translation: 'My Lord, expand my chest for me and ease my task.',
    category: 'Knowledge',
    tags: ['Success', 'Study'],
    userId: 3,
    userName: 'You',
    userAvatar: 'ME',
    views: '0',
    bookmarkCount: 12,
    likeCount: 34,
    reportCount: 0,
  ),
];
