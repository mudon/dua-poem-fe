import 'package:flutter/material.dart';

enum NotificationType {
  likeReceived('like_received'),
  reportCreated('report_created'),
  reportResolved('report_resolved'),
  reportDismissed('report_dismissed'),
  revisionSubmitted('revision_submitted'),
  revisionReviewed('revision_reviewed'),
  reportReopened('report_reopened'),
  badgeAwarded('badge_awarded'),
  badgeRevoked('badge_revoked');

  final String value;
  const NotificationType(this.value);

  IconData get icon {
    switch (this) {
      case NotificationType.likeReceived:
        return Icons.favorite;
      case NotificationType.reportCreated:
        return Icons.flag_outlined;
      case NotificationType.reportResolved:
        return Icons.check_circle_outline;
      case NotificationType.reportDismissed:
        return Icons.cancel_outlined;
      case NotificationType.revisionSubmitted:
        return Icons.pending_actions;
      case NotificationType.revisionReviewed:
        return Icons.edit_note;
      case NotificationType.reportReopened:
        return Icons.refresh;
      case NotificationType.badgeAwarded:
        return Icons.emoji_events;
      case NotificationType.badgeRevoked:
        return Icons.lock_outline;
    }
  }

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.likeReceived,
    );
  }
}
