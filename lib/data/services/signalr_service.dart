import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/constants/app_config.dart';
import '../../core/enums/hub_route.dart';
import '../../core/constants/storage_keys.dart';
import '../models/signalr/likes_update_model.dart';
import '../models/signalr/favorites_update_model.dart';
import '../models/signalr/views_update_model.dart';
import '../models/signalr/reports_update_model.dart';
import '../models/signalr/notification_update_model.dart';
import '../models/signalr/leaderboard_update_model.dart';
import '../models/signalr/dua_content_update_model.dart';
import '../models/signalr/poem_content_update_model.dart';
import '../models/signalr/badge_awarded_model.dart';
import '../models/signalr/badge_revoked_model.dart';
import '../models/signalr/profile_update_model.dart';

class SignalRService {
  final Map<HubRoute, HubConnection> _connections = {};
  final _likesController = StreamController<LikesUpdateModel>.broadcast();
  final _favoritesController = StreamController<FavoritesUpdateModel>.broadcast();
  final _viewsController = StreamController<ViewsUpdateModel>.broadcast();
  final _reportsController = StreamController<ReportsUpdateModel>.broadcast();
  final _notificationController = StreamController<NotificationUpdateModel>.broadcast();
  final _leaderboardController = StreamController<List<LeaderboardUpdateModel>>.broadcast();
  final _duaContentController = StreamController<DuaContentUpdateModel>.broadcast();
  final _poemContentController = StreamController<PoemContentUpdateModel>.broadcast();
  final _badgeController = StreamController<BadgeAwardedModel>.broadcast();
  final _badgeRevokedController = StreamController<BadgeRevokedModel>.broadcast();
  final _profileController = StreamController<ProfileUpdateModel>.broadcast();
  final _duaDeletedController = StreamController<String>.broadcast();
  final _poemDeletedController = StreamController<String>.broadcast();
  final _duaCreatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _poemCreatedController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;
  Future<void>? _connectFuture;

  Stream<LikesUpdateModel> get onLikesCountUpdated => _likesController.stream;
  Stream<FavoritesUpdateModel> get onFavoritesCountUpdated => _favoritesController.stream;
  Stream<ViewsUpdateModel> get onViewsCountUpdated => _viewsController.stream;
  Stream<ReportsUpdateModel> get onReportsCountUpdated => _reportsController.stream;
  Stream<NotificationUpdateModel> get onNotificationReceived => _notificationController.stream;
  Stream<List<LeaderboardUpdateModel>> get onLeaderboardUpdated => _leaderboardController.stream;
  Stream<BadgeAwardedModel> get onBadgeAwarded => _badgeController.stream;
  Stream<BadgeRevokedModel> get onBadgeRevoked => _badgeRevokedController.stream;
  Stream<ProfileUpdateModel> get onProfileUpdated => _profileController.stream;
  Stream<DuaContentUpdateModel> get onDuaContentUpdated => _duaContentController.stream;
  Stream<PoemContentUpdateModel> get onPoemContentUpdated => _poemContentController.stream;
  Stream<String> get onDuaDeleted => _duaDeletedController.stream;

  void addNotification(NotificationUpdateModel update) {
    _notificationController.add(update);
  }
  Stream<String> get onPoemDeleted => _poemDeletedController.stream;
  Stream<Map<String, dynamic>> get onDuaCreated => _duaCreatedController.stream;
  Stream<Map<String, dynamic>> get onPoemCreated => _poemCreatedController.stream;

  String get _hubBaseUrl =>
      AppConfig.apiBaseUrl.replaceAll('/api', '');

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
    final storage = SecureStorageService();
    await storage.init();
    final token = await storage.read(key: StorageKeys.accessToken);
    if (token == null) {
      print('[SignalR] No access_token found in secure storage, skipping connection');
      return;
    }

    await Future.wait(
      HubRoute.values.map((route) => _connectHub(route, token).catchError((e) {
        print('[SignalR] Failed to connect ${route.path}: $e');
      })),
    );

    _isConnected = true;
  }

  Future<void> _connectHub(HubRoute route, String token) async {
    final httpOptions = HttpConnectionOptions(
      transport: HttpTransportType.WebSockets,
      accessTokenFactory: () async => token,
      skipNegotiation: true,
    );
    final connection = HubConnectionBuilder()
        .withUrl(
          '$_hubBaseUrl${route.path}',
          options: httpOptions,
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

    connection.on('LeaderboardUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as List<dynamic>;
      final entries = data.map((e) => LeaderboardUpdateModel.fromJson(e as Map<String, dynamic>)).toList();
      _leaderboardController.add(entries);
    });

    connection.on('DuaContentUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _duaContentController.add(DuaContentUpdateModel.fromJson(data));
    });

    connection.on('PoemContentUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _poemContentController.add(PoemContentUpdateModel.fromJson(data));
    });

    connection.on('DuaDeleted', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      final duaId = data['duaId'].toString();
      _duaDeletedController.add(duaId);
    });

    connection.on('BadgeAwarded', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _badgeController.add(BadgeAwardedModel.fromJson(data));
    });

    connection.on('BadgeRevoked', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _badgeRevokedController.add(BadgeRevokedModel.fromJson(data));
    });

    connection.on('PoemDeleted', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      final poemId = data['poemId'].toString();
      _poemDeletedController.add(poemId);
    });

    connection.on('ProfileUpdated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      print('[SignalR] ProfileUpdated: userId=${data['userId']}');
      _profileController.add(ProfileUpdateModel.fromJson(data));
    });

    connection.on('DuaCreated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _duaCreatedController.add(data);
    });

    connection.on('PoemCreated', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _poemCreatedController.add(data);
    });

    connection.onclose(({Exception? error}) {
      print('[SignalR] Connection closed for ${route.path}: $error');
      _connections.remove(route);
    });

    await connection.start();
    print('[SignalR] Connected to ${route.path}');

    _connections[route] = connection;
  }

  Future<void> joinDuaGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaLikes]?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaLikes]?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemLikes]?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemLikes]?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemGroup failed for $poemId: $e');
    }
  }

  Future<void> joinDuaReportGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaReports]?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaReportGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaReportGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaReports]?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaReportGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemReportGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemReports]?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemReportGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemReportGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemReports]?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemReportGroup failed for $poemId: $e');
    }
  }

  Future<void> joinDuaViewGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaViews]?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaViewGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaViewGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaViews]?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaViewGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemViewGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemViews]?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemViewGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemViewGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemViews]?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemViewGroup failed for $poemId: $e');
    }
  }

  Future<void> joinDuaFavoriteGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaFavorites]?.invoke('JoinDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] joinDuaFavoriteGroup failed for $duaId: $e');
    }
  }

  Future<void> leaveDuaFavoriteGroup(String duaId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.duaFavorites]?.invoke('LeaveDuaGroup', args: [duaId]);
    } catch (e) {
      print('[SignalR] leaveDuaFavoriteGroup failed for $duaId: $e');
    }
  }

  Future<void> joinPoemFavoriteGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemFavorites]?.invoke('JoinPoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] joinPoemFavoriteGroup failed for $poemId: $e');
    }
  }

  Future<void> leavePoemFavoriteGroup(String poemId) async {
    await _connectFuture;
    try {
      await _connections[HubRoute.poemFavorites]?.invoke('LeavePoemGroup', args: [poemId]);
    } catch (e) {
      print('[SignalR] leavePoemFavoriteGroup failed for $poemId: $e');
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _connectFuture = null;
    final connections = _connections.entries.toList();
    for (final entry in connections) {
      try {
        await entry.value.stop();
      } catch (e) {
        print('[SignalR] disconnect ${entry.key.path} error: $e');
      }
    }
    _connections.clear();
  }

  void dispose() {
    disconnect();
    _likesController.close();
    _favoritesController.close();
    _viewsController.close();
    _reportsController.close();
    _notificationController.close();
    _leaderboardController.close();
    _badgeController.close();
    _badgeRevokedController.close();
    _profileController.close();
    _duaContentController.close();
    _poemContentController.close();
    _duaDeletedController.close();
    _poemDeletedController.close();
    _duaCreatedController.close();
    _poemCreatedController.close();
  }
}
