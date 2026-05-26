import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class AuthErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const AuthErrorWidget({super.key, required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: AppTheme.errorRed, width: 4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: AppTheme.errorRed))),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, size: 16, color: AppTheme.errorRed),
          ),
        ],
      ),
    );
  }
}
