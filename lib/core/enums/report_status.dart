import 'package:flutter/material.dart';

enum ReportStatus {
  pending,
  fixSubmitted,
  resolved,
  dismissed;

  String get value {
    if (this == ReportStatus.fixSubmitted) return 'fix_submitted';
    return name;
  }

  String get displayName {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  Color get color {
    switch (this) {
      case ReportStatus.pending:
        return const Color(0xFFD68B2E);
      case ReportStatus.fixSubmitted:
        return const Color(0xFF4A7BBF);
      case ReportStatus.resolved:
        return const Color(0xFF3F7849);
      case ReportStatus.dismissed:
        return const Color(0xFF9A8C79);
    }
  }

  static ReportStatus fromValue(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportStatus.pending,
    );
  }
}
