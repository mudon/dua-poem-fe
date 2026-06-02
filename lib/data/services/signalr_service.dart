import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_core/signalr_core.dart';
import '../../core/constants/api_config.dart';
import '../models/signalr/likes_update_model.dart';
import '../models/signalr/favorites_update_model.dart';

class SignalRService {
  HubConnection? _duaHubConnection;
  HubConnection? _poemHubConnection;
  HubConnection? _duaFavHubConnection;
  HubConnection? _poemFavHubConnection;
  final _likesController = StreamController<LikesUpdateModel>.broadcast();
  final _favoritesController = StreamController<FavoritesUpdateModel>.broadcast();
  bool _isConnected = false;
  Future<void>? _connectFuture;

  Stream<LikesUpdateModel> get onLikesCountUpdated => _likesController.stream;
  Stream<FavoritesUpdateModel> get onFavoritesCountUpdated => _favoritesController.stream;

  String get _hubBaseUrl =>
      ApiConfig.baseUrl.replaceAll('/api', '');

  Future<void> connect() async {
    if (_isConnected) {
      print('[SignalR] Already connected, skipping');
      return;
    }
    if (_connectFuture != null) {
      print('[SignalR] Connection already in progress, returning existing future');
      return _connectFuture!;
    }

    _connectFuture = _connectInternal();
    await _connectFuture;
  }

  Future<void> _connectInternal() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      print('[SignalR] No access_token found in secure storage, skipping connection');
      return;
    }

    try {
      await _connectHub('/hubs/dua-likes', token);
      await _connectHub('/hubs/poem-likes', token);
      await _connectHub('/hubs/dua-favorites', token);
      await _connectHub('/hubs/poem-favorites', token);
      _isConnected = true;
    } catch (e) {
      print('[SignalR] _connectInternal failed: $e');
    }
  }

  Future<void> _connectHub(String hubPath, String token) async {
    final connection = HubConnectionBuilder()
        .withUrl(
          '$_hubBaseUrl$hubPath',
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
            accessTokenFactory: () async => token,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect()
        .build();

    connection.on('LikesCountUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _likesController.add(LikesUpdateModel.fromJson(data));
    });

    connection.on('FavoritesCountUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _favoritesController.add(FavoritesUpdateModel.fromJson(data));
    });

    connection.onclose((Exception? error) {
      print('[SignalR] Connection closed for $hubPath: $error');
      if (hubPath.contains('dua-likes')) _duaHubConnection = null;
      if (hubPath.contains('poem-likes')) _poemHubConnection = null;
      if (hubPath.contains('dua-favorites')) _duaFavHubConnection = null;
      if (hubPath.contains('poem-favorites')) _poemFavHubConnection = null;
    });

    await connection.start();
    print('[SignalR] Connected to $hubPath');

    if (hubPath.contains('dua-likes')) _duaHubConnection = connection;
    if (hubPath.contains('poem-likes')) _poemHubConnection = connection;
    if (hubPath.contains('dua-favorites')) _duaFavHubConnection = connection;
    if (hubPath.contains('poem-favorites')) _poemFavHubConnection = connection;
  }

  Future<void> joinDuaGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaHubConnection?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaHubConnection?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemHubConnection?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemHubConnection?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemGroup failed for $poemId: $e');
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _connectFuture = null;
    try {
      await _duaHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect dua hub error: $e');
    }
    try {
      await _poemHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect poem hub error: $e');
    }
    try {
      await _duaFavHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect dua favorites hub error: $e');
    }
    try {
      await _poemFavHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect poem favorites hub error: $e');
    }
    _duaHubConnection = null;
    _poemHubConnection = null;
    _duaFavHubConnection = null;
    _poemFavHubConnection = null;
  }

  void dispose() {
    disconnect();
    _likesController.close();
    _favoritesController.close();
  }
}
