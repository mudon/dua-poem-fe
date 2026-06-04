import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_core/signalr_core.dart';
import '../../core/constants/api_config.dart';
import '../models/signalr/likes_update_model.dart';
import '../models/signalr/favorites_update_model.dart';
import '../models/signalr/views_update_model.dart';
import '../models/signalr/reports_update_model.dart';
import '../models/signalr/notification_update_model.dart';

class SignalRService {
  HubConnection? _duaHubConnection;
  HubConnection? _poemHubConnection;
  HubConnection? _duaFavHubConnection;
  HubConnection? _poemFavHubConnection;
  HubConnection? _duaViewHubConnection;
  HubConnection? _poemViewHubConnection;
  HubConnection? _duaReportHubConnection;
  HubConnection? _poemReportHubConnection;
  HubConnection? _notificationHubConnection;
  final _likesController = StreamController<LikesUpdateModel>.broadcast();
  final _favoritesController = StreamController<FavoritesUpdateModel>.broadcast();
  final _viewsController = StreamController<ViewsUpdateModel>.broadcast();
  final _reportsController = StreamController<ReportsUpdateModel>.broadcast();
  final _notificationController = StreamController<NotificationUpdateModel>.broadcast();
  bool _isConnected = false;
  Future<void>? _connectFuture;

  Stream<LikesUpdateModel> get onLikesCountUpdated => _likesController.stream;
  Stream<FavoritesUpdateModel> get onFavoritesCountUpdated => _favoritesController.stream;
  Stream<ViewsUpdateModel> get onViewsCountUpdated => _viewsController.stream;
  Stream<ReportsUpdateModel> get onReportsCountUpdated => _reportsController.stream;
  Stream<NotificationUpdateModel> get onNotificationReceived => _notificationController.stream;

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
      await _connectHub('/hubs/dua-views', token);
      await _connectHub('/hubs/poem-views', token);
      await _connectHub('/hubs/dua-reports', token);
      await _connectHub('/hubs/poem-reports', token);
      try {
        await _connectHub('/hubs/notifications', token);
      } catch (e) {
        print('[SignalR] Failed to connect /hubs/notifications: $e');
      }
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

    connection.on('ViewsCountUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _viewsController.add(ViewsUpdateModel.fromJson(data));
    });

    connection.on('ReportsCountUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _reportsController.add(ReportsUpdateModel.fromJson(data));
    });

    connection.on('NotificationReceived', (args) {
      if (args == null || args.isEmpty) {
        print('[SignalR] NotificationReceived called with empty args');
        return;
      }
      final data = args[0] as Map<String, dynamic>;
      print('[SignalR] NotificationReceived: type=${data['type']}, title=${data['title']}');
      _notificationController.add(NotificationUpdateModel.fromJson(data));
    });

    connection.onclose((Exception? error) {
      print('[SignalR] Connection closed for $hubPath: $error');
      if (hubPath.contains('dua-likes')) _duaHubConnection = null;
      if (hubPath.contains('poem-likes')) _poemHubConnection = null;
      if (hubPath.contains('dua-favorites')) _duaFavHubConnection = null;
      if (hubPath.contains('poem-favorites')) _poemFavHubConnection = null;
      if (hubPath.contains('dua-views')) _duaViewHubConnection = null;
      if (hubPath.contains('poem-views')) _poemViewHubConnection = null;
      if (hubPath.contains('dua-reports')) _duaReportHubConnection = null;
      if (hubPath.contains('poem-reports')) _poemReportHubConnection = null;
      if (hubPath.contains('notifications')) _notificationHubConnection = null;
    });

    await connection.start();
    print('[SignalR] Connected to $hubPath');

    if (hubPath.contains('dua-likes')) _duaHubConnection = connection;
    if (hubPath.contains('poem-likes')) _poemHubConnection = connection;
    if (hubPath.contains('dua-favorites')) _duaFavHubConnection = connection;
    if (hubPath.contains('poem-favorites')) _poemFavHubConnection = connection;
    if (hubPath.contains('dua-views')) _duaViewHubConnection = connection;
    if (hubPath.contains('poem-views')) _poemViewHubConnection = connection;
    if (hubPath.contains('dua-reports')) _duaReportHubConnection = connection;
    if (hubPath.contains('poem-reports')) _poemReportHubConnection = connection;
    if (hubPath.contains('notifications')) _notificationHubConnection = connection;
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

  Future<void> joinDuaReportGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaReportHubConnection?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaReportGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaReportGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaReportHubConnection?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaReportGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemReportGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemReportHubConnection?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemReportGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemReportGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemReportHubConnection?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemReportGroup failed for $poemId: $e');
    }
  }

  Future<void> joinDuaViewGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaViewHubConnection?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaViewGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaViewGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaViewHubConnection?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaViewGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemViewGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemViewHubConnection?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemViewGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemViewGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemViewHubConnection?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemViewGroup failed for $poemId: $e');
    }
  }

  Future<void> joinDuaFavoriteGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaFavHubConnection?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaFavoriteGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaFavoriteGroup(String duaId) async {
    await _connectFuture;
    try {
      await _duaFavHubConnection?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaFavoriteGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemFavoriteGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemFavHubConnection?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemFavoriteGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemFavoriteGroup(String poemId) async {
    await _connectFuture;
    try {
      await _poemFavHubConnection?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemFavoriteGroup failed for $poemId: $e');
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
    try {
      await _duaViewHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect dua views hub error: $e');
    }
    try {
      await _poemViewHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect poem views hub error: $e');
    }
    try {
      await _duaReportHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect dua report hub error: $e');
    }
    try {
      await _poemReportHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect poem report hub error: $e');
    }
    try {
      await _notificationHubConnection?.stop();
    } catch (e) {
      print('[SignalR] disconnect notification hub error: $e');
    }
    _duaHubConnection = null;
    _poemHubConnection = null;
    _duaFavHubConnection = null;
    _poemFavHubConnection = null;
    _duaViewHubConnection = null;
    _poemViewHubConnection = null;
    _duaReportHubConnection = null;
    _poemReportHubConnection = null;
    _notificationHubConnection = null;
  }

  void dispose() {
    disconnect();
    _likesController.close();
    _favoritesController.close();
    _viewsController.close();
    _reportsController.close();
    _notificationController.close();
  }
}
