import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/notification_model.dart';
import '../../blocs/auth_bloc/auth_bloc.dart';
import '../../blocs/auth_bloc/auth_state.dart';
import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../blocs/notification_bloc/notification_event.dart';
import '../../blocs/notification_bloc/notification_state.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  OverlayEntry? _overlayEntry;
  final _key = GlobalKey();

  void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggle() {
    if (_overlayEntry != null) {
      _dismiss();
      return;
    }
    _show();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'like_received':
        return Icons.favorite;
      case 'report_created':
        return Icons.flag_outlined;
      case 'report_resolved':
        return Icons.check_circle_outline;
      case 'report_dismissed':
        return Icons.cancel_outlined;
      case 'revision_submitted':
        return Icons.pending_actions;
      case 'revision_reviewed':
        return Icons.edit_note;
      case 'report_reopened':
        return Icons.refresh;
      case 'badge_awarded':
        return Icons.emoji_events;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return GestureDetector(
          key: _key,
          onTap: _toggle,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF5C5346)),
              if (state.unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9534F),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _show() {
    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    const popupWidth = 340.0;
    final right = screenWidth - position.dx - box.size.width;
    final distFromRight = right < 0 ? 0.0 : right;

    _overlayEntry = OverlayEntry(
      builder: (_) {
        return GestureDetector(
          onTap: _dismiss,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: position.dy + box.size.height + 6,
                  right: distFromRight,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                    child: BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        final items = state.notifications.take(10).toList();
                        return Container(
                          width: popupWidth,
                          constraints: const BoxConstraints(maxHeight: 420),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFFF0EAE0)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Notifications',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color(0xFF3C4F34),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (state.unreadCount > 0)
                                          GestureDetector(
                                            onTap: () {
                                              getIt<NotificationBloc>().add(MarkAllRead());
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 12),
                                              child: Text(
                                                state.isMarkingAllRead ? '...' : 'Mark all read',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF7C9A6E),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        GestureDetector(
                                          onTap: _dismiss,
                                          child: const Icon(Icons.close, size: 18, color: Color(0xFFAB9F8E)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (items.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'No notifications yet',
                                    style: TextStyle(color: Color(0xFFAB9F8E), fontSize: 13),
                                  ),
                                )
                              else
                                Flexible(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shrinkWrap: true,
                                    itemCount: items.length,
                                    separatorBuilder: (_, _) => const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Divider(height: 1, color: Color(0xFFF0EAE0)),
                                    ),
                    itemBuilder: (_, i) {
                      final n = items[i];
                      final isReturnedFix = n.type == 'report_reopened';
                      String? fixNavigatePath;
                      if (isReturnedFix && n.data != null) {
                        try {
                          final parsed = jsonDecode(n.data!) as Map<String, dynamic>;
                          final duaId = parsed['duaId'] as String?;
                          final poemId = parsed['poemId'] as String?;
                          if (duaId != null) fixNavigatePath = '/dua/$duaId';
                          if (poemId != null) fixNavigatePath = '/poem/$poemId';
                        } catch (_) {}
                      }
                      return _NotificationItem(
                        notification: n,
                        icon: _iconForType(n.type),
                        timeAgo: _timeAgo(n.createdAt),
                        onTap: () {
                          if (!n.isRead) getIt<NotificationBloc>().add(MarkAsRead(n.id));
                          final authState = context.read<AuthBloc>().state;
                          if (authState is! Authenticated) return;
                          _dismiss();
                          final user = authState.user;
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
                            context.push('/dua/$duaId', extra: user);
                          } else if (poemId != null) {
                            context.push('/poem/$poemId', extra: user);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const _ContentNotFoundScreen()));
                          }
                        },
                        actionLabel: fixNavigatePath != null ? 'Submit Fix' : null,
                        onActionTap: fixNavigatePath != null
                            ? () {
                                final authState = context.read<AuthBloc>().state;
                                if (authState is! Authenticated) return;
                                _dismiss();
                                context.push(fixNavigatePath!, extra: authState.user);
                              }
                            : null,
                      );
                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final IconData icon;
  final String timeAgo;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _NotificationItem({
    required this.notification,
    required this.icon,
    required this.timeAgo,
    this.onTap,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? const Color(0xFFF1EEE7)
                    : const Color(0xFFDCE8D3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 16,
                color: notification.isRead
                    ? const Color(0xFFAB9F8E)
                    : const Color(0xFF4A5B3E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF3C3730),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (notification.body != null)
                      Text(
                        notification.body!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF7A6B5A)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  if (actionLabel != null && onActionTap != null) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onActionTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6A817).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B6F0E),
                          ),
                        ),
                      ),
                    ),
                  ],
                  ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 10,
                color: notification.isRead
                    ? const Color(0xFFAB9F8E)
                    : const Color(0xFF7C9A6E),
                fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentNotFoundScreen extends StatelessWidget {
  const _ContentNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: AppTheme.sage, size: 20),
                    SizedBox(width: 8),
                    Text('Back', style: TextStyle(color: AppTheme.sage, fontWeight: FontWeight.w500, fontSize: 15)),
                  ],
                ),
              ),
            ),
            const Expanded(child: Center(child: Text('Content not found'))),
          ],
        ),
      ),
    );
  }
}
