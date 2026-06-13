enum HubRoute {
  duaLikes,
  poemLikes,
  duaFavorites,
  poemFavorites,
  duaViews,
  poemViews,
  duaReports,
  poemReports,
  notifications,
  leaderboard,
  badges,
  profile;

  String get path => switch (this) {
    HubRoute.duaLikes => '/hubs/dua-likes',
    HubRoute.poemLikes => '/hubs/poem-likes',
    HubRoute.duaFavorites => '/hubs/dua-favorites',
    HubRoute.poemFavorites => '/hubs/poem-favorites',
    HubRoute.duaViews => '/hubs/dua-views',
    HubRoute.poemViews => '/hubs/poem-views',
    HubRoute.duaReports => '/hubs/dua-reports',
    HubRoute.poemReports => '/hubs/poem-reports',
    HubRoute.notifications => '/hubs/notifications',
    HubRoute.leaderboard => '/hubs/leaderboard',
    HubRoute.badges => '/hubs/badges',
    HubRoute.profile => '/hubs/profile',
  };
}
