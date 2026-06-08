import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/models/signalr/badge_awarded_model.dart';
import '../../../data/services/signalr_service.dart';


class BadgeAwardPopup extends StatefulWidget {
  final Widget child;
  const BadgeAwardPopup({super.key, required this.child});
  @override
  State<BadgeAwardPopup> createState() => _BadgeAwardPopupState();
}

class _BadgeAwardPopupState extends State<BadgeAwardPopup> with SingleTickerProviderStateMixin {
  StreamSubscription<BadgeAwardedModel>? _sub;
  OverlayEntry? _overlay;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _sub = getIt<SignalRService>().onBadgeAwarded.listen(_onBadgeAwarded);
  }

  void _onBadgeAwarded(BadgeAwardedModel badge) {
    _dismissTimer?.cancel();
    _overlay?.remove();
    _overlay = null;

    _overlay = OverlayEntry(builder: (_) => _BadgeToast(slug: badge.slug, name: badge.name));
    Overlay.of(context).insert(_overlay!);
    HapticFeedback.mediumImpact();

    _dismissTimer = Timer(const Duration(seconds: 4), _removeOverlay);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _dismissTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _BadgeToast extends StatefulWidget {
  final String slug;
  final String name;
  const _BadgeToast({required this.slug, required this.name});
  @override
  State<_BadgeToast> createState() => _BadgeToastState();
}

class _BadgeToastState extends State<_BadgeToast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 100;
    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: bottom,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A7D44), Color(0xFF2D6A3B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D6A3B).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'New Badge Earned!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
