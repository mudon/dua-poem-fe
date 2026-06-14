import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  final FlutterSecureStorage? _native;
  SharedPreferences? _web;

  SecureStorageService() : _native = kIsWeb ? null : const FlutterSecureStorage();

  Future<void> init() async {
    if (kIsWeb) {
      _web = await SharedPreferences.getInstance();
    }
  }

  Future<String?> read({required String key}) async {
    if (kIsWeb) return _web?.getString(key);
    return _native?.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      await _web?.setString(key, value);
    } else {
      await _native?.write(key: key, value: value);
    }
  }

  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      await _web?.remove(key);
    } else {
      await _native?.delete(key: key);
    }
  }
}
