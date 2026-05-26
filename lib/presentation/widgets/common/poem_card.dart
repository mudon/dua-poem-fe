import 'package:flutter/material.dart';
import '../../../data/models/poem_model.dart';
import '../../../data/models/user_model.dart';
import '../../screens/poem_detail_screen.dart';
import '../../screens/user_detail_screen.dart';

class PoemCard extends StatefulWidget {
  final PoemModel poem;
  final UserModel currentUser;

  const PoemCard({super.key, required this.poem, required this.currentUser});

  @override
  State<PoemCard> createState() => _PoemCardState();
}

class _PoemCardState extends State<PoemCard> {
  late bool _isLiked;
  late int _likeCount;
  late bool _isBookmarked;
  late int _bookmarkCount;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.poem.likeCount;
    _isBookmarked = false;
    _bookmarkCount = widget.poem.bookmarkCount;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => PoemDetailScreen(poemId: widget.poem.id, currentUser: widget.currentUser),
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFEBE3D5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(widget.poem.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.poem.verified ? const Color(0xFFE2F0DA) : const Color(0xFFFFF1E0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          widget.poem.verified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: widget.poem.verified ? const Color(0xFF3F7849) : const Color(0xFFC47D2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFFD6B17E),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likeCount',
                        style: const TextStyle(color: Color(0xFFD6B17E), fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.poem.content != null)
              Text(
                '"${widget.poem.content!.length > 80 ? '${widget.poem.content!.substring(0, 80)}…' : widget.poem.content!}"',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF4C473F)),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PoemMetaChip(icon: Icons.person_outline, label: widget.poem.userName),
              ],
            ),
            if (widget.poem.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.poem.tags.map((t) => _PoemTagPill(label: t)).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFF0EAE0)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => UserDetailScreen(userName: widget.poem.userName, userId: widget.poem.userId),
                  )),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFDCE8D3),
                        child: Text(widget.poem.userAvatar, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A5B3E))),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.poem.userName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5C5346))),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.visibility, size: 12, color: Color(0xFF9A8C79)),
                              const SizedBox(width: 2),
                              Text(widget.poem.views, style: const TextStyle(fontSize: 10, color: Color(0xFF9A8C79))),
                              const Text(' views', style: TextStyle(fontSize: 10, color: Color(0xFF9A8C79))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleBookmark,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: const Color(0xFFAB9F8E),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text('$_bookmarkCount',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFAB9F8E))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report feature coming soon')),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_outlined, color: Color(0xFFAB9F8E), size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      _bookmarkCount += _isBookmarked ? 1 : -1;
    });
  }
}

class _PoemMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PoemMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF8F8575)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8F8575))),
        ],
      ),
    );
  }
}

class _PoemTagPill extends StatelessWidget {
  final String label;
  const _PoemTagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEE7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF5D6F4A)),
      ),
    );
  }
}
