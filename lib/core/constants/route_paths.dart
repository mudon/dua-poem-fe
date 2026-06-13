class RoutePaths {
  RoutePaths._();

  static const home = '/home';
  static const auth = '/auth';
  static const myPosts = '/my-posts';
  static const leaderboard = '/leaderboard';
  static const profile = '/profile';
  static const favorites = '/favorites';
  static const admin = '/admin';
  static const adminRevision = '/admin/revision';

  static String duaDetail(String duaId) => '/dua/$duaId';
  static String poemDetail(String poemId) => '/poem/$poemId';
  static String userDetail(String userId) => '/user/$userId';
}
