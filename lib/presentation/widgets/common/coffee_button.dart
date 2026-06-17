import 'package:flutter/material.dart';
import '../../screens/buy_coffee_screen.dart';
import '../../../core/themes/app_theme.dart';

class CoffeeButton extends StatelessWidget {
  const CoffeeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BuyCoffeeScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.sage, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.75),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.coffee, size: 16, color: AppTheme.sage),
            SizedBox(width: 5),
            Text(
              'Beli Saya Kopi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.sage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
