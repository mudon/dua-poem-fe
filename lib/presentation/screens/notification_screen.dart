import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/dependency_injection.dart';
import '../../core/constants/route_paths.dart';
import '../../core/themes/app_theme.dart';
import '../../core/enums/notification_type.dart';
import '../../data/models/notification_model.dart';
import '../blocs/notification_bloc/notification_bloc.dart';
import '../blocs/notification_bloc/notification_event.dart';
import '../blocs/notification_bloc/notification_state.dart';
import '../widgets/common/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _scrollController = ScrollController();
  final _notificationBloc = getIt<NotificationBloc>();

  @override
  void initState() {
    super.initState();
    _notificationBloc.add(LoadNotifications(refresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _notificationBloc.state;
      if (!state.isLoading && state.hasMore) {
        _notificationBloc.add(LoadNotifications());
      }
    }
  }

  void _onNotificationTap(NotificationModel n) {
    if (!n.isRead) {
      _notificationBloc.add(MarkAsRead(n.id));
    }

    String? duaId;
    String? poemId;
    if (n.data != null) {
      try {
        final parsed = jsonDecode(n.data!) as Map<String, dynamic>;
        duaId = parsed['duaId'] as String?;
        poemId = parsed['poemId'] as String?;
      } catch (_) {}
    }

    if (duaId != null) {
      context.push(RoutePaths.duaDetail(duaId));
    } else if (poemId != null) {
      context.push(RoutePaths.poemDetail(poemId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      bloc: _notificationBloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F0E8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF4F0E8),
            surfaceTintColor: const Color(0xFFF4F0E8),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF3C4F34),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.sage),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (state.unreadCount > 0)
                TextButton(
                  onPressed: state.isMarkingAllRead
                      ? null
                      : () => _notificationBloc.add(MarkAllRead()),
                  child: Text(
                    state.isMarkingAllRead ? '...' : 'Mark all read',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7C9A6E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(color: Color(0xFFAB9F8E), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.notifications.length + (state.isLoading ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        color: Color(0xFFF0EAE0),
        indent: 42,
      ),
      itemBuilder: (_, i) {
        if (i == state.notifications.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
          );
        }

        final n = state.notifications[i];
        final isReturnedFix = n.type == NotificationType.reportReopened;
        String? fixNavigatePath;
        if (isReturnedFix && n.data != null) {
          try {
            final parsed = jsonDecode(n.data!) as Map<String, dynamic>;
            final duaId = parsed['duaId'] as String?;
            final poemId = parsed['poemId'] as String?;
            if (duaId != null) fixNavigatePath = RoutePaths.duaDetail(duaId);
            if (poemId != null) fixNavigatePath = RoutePaths.poemDetail(poemId);
          } catch (_) {}
        }

        return NotificationTile(
          notification: n,
          onTap: () => _onNotificationTap(n),
          actionLabel: fixNavigatePath != null ? 'Submit Fix' : null,
          onActionTap: fixNavigatePath != null
              ? () => context.push(fixNavigatePath!)
              : null,
        );
      },
    );
  }
}
