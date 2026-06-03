import 'package:flutter/material.dart';

class NotificationBell extends StatefulWidget {
  final int unreadCount;

  const NotificationBell({super.key, this.unreadCount = 3});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  OverlayEntry? _overlayEntry;
  final _key = GlobalKey();

  void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggle() {
    if (_overlayEntry != null) {
      _dismiss();
      return;
    }
    _show();
  }

  void _show() {
    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    const popupWidth = 340.0;
    final right = screenWidth - position.dx - box.size.width;
    final distFromRight = right < 0 ? 0.0 : right;

    _overlayEntry = OverlayEntry(
      builder: (_) {
        return GestureDetector(
          onTap: _dismiss,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: position.dy + box.size.height + 6,
                  right: distFromRight,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                    child: Container(
                      width: popupWidth,
                      constraints: const BoxConstraints(maxHeight: 420),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFF0EAE0)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Color(0xFF3C4F34),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _dismiss,
                                  child: const Icon(Icons.close, size: 18, color: Color(0xFFAB9F8E)),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shrinkWrap: true,
                              itemCount: _items.length,
                              separatorBuilder: (_, _) => const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Divider(height: 1, color: Color(0xFFF0EAE0)),
                              ),
                              itemBuilder: (_, i) => _NotificationItem(data: _items[i]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _toggle,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF5C5346)),
          if (widget.unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFD9534F),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationItemData {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final IconData icon;

  const _NotificationItemData({
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    required this.icon,
  });
}

const _items = [
  _NotificationItemData(
    title: 'New Like',
    body: 'Aisha liked your dua "Rabbana Atina"',
    time: '2m',
    icon: Icons.favorite,
  ),
  _NotificationItemData(
    title: 'Content Reported',
    body: 'Someone reported your poem "Patience"',
    time: '15m',
    icon: Icons.flag_outlined,
  ),
  _NotificationItemData(
    title: 'Report Resolved',
    body: 'Your report on "Dua for Forgiveness" was resolved',
    time: '1h',
    icon: Icons.check_circle_outline,
  ),
  _NotificationItemData(
    title: 'Fix Approved',
    body: 'Your fix for "Morning Dua" was approved',
    time: '3h',
    isRead: true,
    icon: Icons.edit_note,
  ),
  _NotificationItemData(
    title: 'New Like',
    body: 'Omar liked your poem "Light of Faith"',
    time: '5h',
    isRead: true,
    icon: Icons.favorite,
  ),
  _NotificationItemData(
    title: 'Revision Submitted',
    body: 'A fix was submitted for your dua "Evening Adhkar"',
    time: '1d',
    isRead: true,
    icon: Icons.pending_actions,
  ),
  _NotificationItemData(
    title: 'New Like',
    body: 'Fatima liked your dua "Forgiveness"',
    time: '2d',
    isRead: true,
    icon: Icons.favorite,
  ),
];

class _NotificationItem extends StatelessWidget {
  final _NotificationItemData data;

  const _NotificationItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: data.isRead
                  ? const Color(0xFFF1EEE7)
                  : const Color(0xFFDCE8D3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              size: 16,
              color: data.isRead
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
                  data.title,
                  style: TextStyle(
                    fontWeight: data.isRead ? FontWeight.w400 : FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF3C3730),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.body,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF7A6B5A)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            data.time,
            style: TextStyle(
              fontSize: 10,
              color: data.isRead
                  ? const Color(0xFFAB9F8E)
                  : const Color(0xFF7C9A6E),
              fontWeight: data.isRead ? FontWeight.w400 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
