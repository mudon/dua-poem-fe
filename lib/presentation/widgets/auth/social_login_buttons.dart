import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/themes/app_theme.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;

  const SocialLoginButtons({super.key, required this.onGoogleTap});

  @override
  Widget build(BuildContext context) {
    return _socialButton(FontAwesomeIcons.google, 'Google', onGoogleTap);
  }

  Widget _socialButton(dynamic icon, String label, VoidCallback onTap) {
    return OutlinedButton(
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
    );
  }
}
