import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_strings.dart';

class AuthToggleButtons extends StatelessWidget {
  final bool isLoginMode;
  final Function(bool) onToggle;

  const AuthToggleButtons({super.key, required this.isLoginMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE8),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLoginMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: isLoginMode
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)]
                      : [],
                ),
                child: Center(
                  child: Text(
                    AppStrings.login,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isLoginMode ? AppTheme.sageDark : const Color(0xFF8B7F6C),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isLoginMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: !isLoginMode
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)]
                      : [],
                ),
                child: Center(
                  child: Text(
                    AppStrings.signup,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: !isLoginMode ? AppTheme.sageDark : const Color(0xFF8B7F6C),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
