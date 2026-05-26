class StoredUser {
  final int id;
  final String name;
  final String avatar;
  final String bio;
  final String joined;

  const StoredUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.joined,
  });
}

final userProfiles = {
  1: const StoredUser(
    id: 1,
    name: 'Aisha Mahmoud',
    avatar: 'AM',
    bio: 'Seeker of knowledge, lover of duas and poetry. Sharing blessings from the heart.',
    joined: 'Joined March 2024',
  ),
  2: const StoredUser(
    id: 2,
    name: 'Omar Farooq',
    avatar: 'OF',
    bio: 'Student of Islamic studies. Spreading authentic duas and reflections.',
    joined: 'Joined January 2024',
  ),
  3: const StoredUser(
    id: 3,
    name: 'You',
    avatar: 'ME',
    bio: 'Your personal account. Share your duas and poems.',
    joined: 'Joined today',
  ),
  4: const StoredUser(
    id: 4,
    name: 'Layla Akhtar',
    avatar: 'LA',
    bio: 'Poet and nature lover. Words that heal.',
    joined: 'Joined December 2023',
  ),
  5: const StoredUser(
    id: 5,
    name: 'Yusuf Mansur',
    avatar: 'YM',
    bio: 'Spiritual writer, exploring the depths of the soul.',
    joined: 'Joined February 2024',
  ),
};

StoredUser? findUser(int userId) => userProfiles[userId];

StoredUser? findUserByName(String userName) {
  return userProfiles.values.firstWhere(
    (u) => u.name == userName,
    orElse: () => userProfiles.values.first,
  );
}
