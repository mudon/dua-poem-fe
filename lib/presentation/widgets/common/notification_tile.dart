import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.actionLabel,
    this.onActionTap,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
                notification.type.icon,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          notification.isRead ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF3C3730),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (notification.body != null)
                    Text(
                      notification.body!,
                      style:
                          const TextStyle(fontSize: 11, color: Color(0xFF7A6B5A)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (actionLabel != null && onActionTap != null) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onActionTap,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              _timeAgo(notification.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: notification.isRead
                    ? const Color(0xFFAB9F8E)
                    : const Color(0xFF7C9A6E),
                fontWeight:
                    notification.isRead ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
