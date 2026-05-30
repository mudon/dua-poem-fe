import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/poem_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../blocs/poem_bloc/poem_bloc.dart';
import '../../blocs/poem_bloc/poem_event.dart';
import '../../blocs/poem_bloc/poem_state.dart';

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
  late int _reportCount;
  late int _viewCount;

  @override
  void initState() {
    super.initState();
    final blocState = context.read<PoemBloc>().state;
    _isLiked = blocState.likedStates[widget.poem.id] ?? widget.poem.isLiked;
    _likeCount = blocState.likeCounts[widget.poem.id] ?? widget.poem.likeCount;
    _isBookmarked = blocState.favoritedStates[widget.poem.id] ?? widget.poem.isFavorited;
    _bookmarkCount = blocState.bookmarkCounts[widget.poem.id] ?? widget.poem.bookmarkCount;
    _reportCount = blocState.reportCounts[widget.poem.id] ?? widget.poem.reportCount;
      _viewCount = blocState.viewCounts[widget.poem.id] ?? widget.poem.views;
  }

  @override
  void didUpdateWidget(PoemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poem.id != widget.poem.id ||
        oldWidget.poem.likeCount != widget.poem.likeCount ||
        oldWidget.poem.isLiked != widget.poem.isLiked ||
        oldWidget.poem.bookmarkCount != widget.poem.bookmarkCount ||
        oldWidget.poem.isFavorited != widget.poem.isFavorited) {
      final blocState = context.read<PoemBloc>().state;
      _isLiked = blocState.likedStates[widget.poem.id] ?? widget.poem.isLiked;
      _isBookmarked = blocState.favoritedStates[widget.poem.id] ?? widget.poem.isFavorited;
      _reportCount = blocState.reportCounts[widget.poem.id] ?? widget.poem.reportCount;
    _viewCount = blocState.viewCounts[widget.poem.id] ?? widget.poem.views;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PoemBloc, PoemState>(
      listener: (context, state) {
        if (state.actionType == 'like') {
          if (state.error != null) {
            setState(() {
              _isLiked = !_isLiked;
              _likeCount += _isLiked ? 1 : -1;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          } else {
            final liked = state.likedStates[widget.poem.id];
            final count = state.likeCounts[widget.poem.id];
            if (liked != null && count != null) {
              setState(() {
                _isLiked = liked;
                _likeCount = count;
              });
            }
          }
        } else if (state.actionType == 'bookmark') {
          if (state.error != null) {
            setState(() {
              _isBookmarked = !_isBookmarked;
              _bookmarkCount += _isBookmarked ? 1 : -1;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          } else {
            final fav = state.favoritedStates[widget.poem.id];
            final count = state.bookmarkCounts[widget.poem.id];
            if (fav != null && count != null) {
              setState(() {
                _isBookmarked = fav;
                _bookmarkCount = count;
              });
            }
          }
        } else if (state.actionType == 'view') {
          final count = state.viewCounts[widget.poem.id];
          if (count != null) {
            setState(() => _viewCount = count);
          }
        } else if (state.actionType == 'report') {
          if (state.lastToggledPoemId != widget.poem.id) return;
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Report failed: ${state.error}')),
            );
          } else {
            final count = state.reportCounts[widget.poem.id];
            if (count != null) setState(() => _reportCount = count);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted')),
            );
          }
        }
      },
      child: GestureDetector(
      onTap: () => context.push('/poem/${widget.poem.id}', extra: widget.currentUser),
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
                  onTap: () => context.push('/user/${widget.poem.userId}', extra: widget.poem.userName),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFDCE8D3),
                        child: Text(
                          widget.poem.userAvatar.isNotEmpty
                              ? widget.poem.userAvatar
                              : '?',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A5B3E)),
                        ),
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
                              Text(_viewCount.toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF9A8C79))),
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
                      onTap: _showReportPopout,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_outlined, color: Color(0xFFAB9F8E), size: 18),
                          if (_reportCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '$_reportCount',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
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
      ),
    );
  }

  void _toggleLike() {
    final wasLiked = _isLiked;
    final currentCount = _likeCount;
    setState(() {
      _isLiked = !wasLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    context.read<PoemBloc>().add(ToggleLike(widget.poem.id, wasLiked, currentCount));
  }

  void _toggleBookmark() {
    final wasBookmarked = _isBookmarked;
    final currentCount = _bookmarkCount;
    setState(() {
      _isBookmarked = !wasBookmarked;
      _bookmarkCount += _isBookmarked ? 1 : -1;
    });
    context.read<PoemBloc>().add(ToggleBookmark(widget.poem.id, wasBookmarked, currentCount));
  }

  void _showReportPopout() {
    final reasons = ['wrong_transliteration', 'wrong_translation', 'wrong_author', 'inappropriate_content', 'duplicate_poem', 'copyright_violation', 'other'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PoemReportBottomSheet(
        reasons: reasons,
        onSubmit: (reason, description) {
          Navigator.pop(ctx);
          context.read<PoemBloc>().add(ReportPoem(widget.poem.id, reason, description));
        },
      ),
    );
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

class _PoemReportBottomSheet extends StatefulWidget {
  final List<String> reasons;
  final Function(String reason, String description) onSubmit;

  const _PoemReportBottomSheet({required this.reasons, required this.onSubmit});

  @override
  State<_PoemReportBottomSheet> createState() => _PoemReportBottomSheetState();
}

class _PoemReportBottomSheetState extends State<_PoemReportBottomSheet> {
  final _descCtrl = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEFAF2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(bottom: BorderSide(color: Color(0xFFEFE8DE))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18, color: Color(0xFF7C9A6E)),
                    SizedBox(width: 8),
                    Text('Report poem', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Color(0xFFA18E76)),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: List.generate(widget.reasons.length, (i) {
                  final r = widget.reasons[i];
                  final label = r.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
                  final isSelected = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? AppTheme.sage : const Color(0xFFAB9F8E),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(label, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                filled: true,
                fillColor: Color(0xFFF7F3ED),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              maxLines: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onSubmit(widget.reasons[_selectedIndex], _descCtrl.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF1EC),
                  foregroundColor: const Color(0xFFC25A3F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}