import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/themes/app_theme.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  const SocialLoginButtons({super.key, required this.onGoogleTap, required this.onAppleTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(FontAwesomeIcons.google, 'Google', onGoogleTap),
        const SizedBox(width: 12),
        _socialButton(FontAwesomeIcons.apple, 'Apple', onAppleTap),
      ],
    );
  }

  Widget _socialButton(dynamic icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.warmGray),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 18, color: AppTheme.sage),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF4E473D))),
          ],
        ),
      ),
    );
  }
}
