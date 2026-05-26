class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    return _mockResponse(email, password);
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    return _mockResponse(email, password, name: name);
  }

  Future<void> logout() async {}

  Map<String, dynamic> _mockResponse(String email, String password, {String? name}) {
    return {
      'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': name ?? email.split('@').first,
        'email': email,
        'avatar': null,
        'bio': 'A user of nur·deen',
        'joinedDate': DateTime.now().toIso8601String().split('T').first,
      },
    };
  }
}
