import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/models/signalr/badge_awarded_model.dart';
import '../../../data/models/signalr/badge_revoked_model.dart';
import '../../../data/services/signalr_service.dart';

class BadgeAwardPopup extends StatefulWidget {
  final Widget child;
  const BadgeAwardPopup({super.key, required this.child});
  @override
  State<BadgeAwardPopup> createState() => _BadgeAwardPopupState();
}

class _BadgeAwardPopupState extends State<BadgeAwardPopup> with SingleTickerProviderStateMixin {
  StreamSubscription<BadgeAwardedModel>? _awardSub;
  StreamSubscription<BadgeRevokedModel>? _revokeSub;
  OverlayEntry? _overlay;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _awardSub = getIt<SignalRService>().onBadgeAwarded.listen((b) => _onBadge(b.name));
    _revokeSub = getIt<SignalRService>().onBadgeRevoked.listen((b) => _onBadge(b.name, isAward: false));
  }

  void _onBadge(String name, {bool isAward = true}) {
    _dismissTimer?.cancel();
    _overlay?.remove();
    _overlay = null;

    _overlay = OverlayEntry(builder: (_) => _BadgeToast(name: name, isAward: isAward));
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
    _awardSub?.cancel();
    _revokeSub?.cancel();
    _dismissTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _BadgeToast extends StatefulWidget {
  final String name;
  final bool isAward;
  const _BadgeToast({required this.name, required this.isAward});
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
    final isAward = widget.isAward;
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
                    gradient: LinearGradient(
                      colors: isAward
                          ? [const Color(0xFF3A7D44), const Color(0xFF2D6A3B)]
                          : [const Color(0xFFC25A3F), const Color(0xFFA1442C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isAward ? const Color(0xFF2D6A3B) : const Color(0xFFA1442C)).withValues(alpha: 0.3),
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
                        child: Icon(
                          isAward ? Icons.emoji_events : Icons.lock_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAward ? 'New Badge Earned!' : 'Badge Lost',
                              style: const TextStyle(
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
                        child: Icon(
                          isAward ? Icons.star : Icons.block,
                          color: isAward ? const Color(0xFFFFD700) : Colors.white70,
                          size: 18,
                        ),
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
