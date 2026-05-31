import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/poem_model.dart';
import '../../../data/models/report_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/poem_repository.dart';
import '../../../core/themes/app_theme.dart';
import '../../blocs/poem_bloc/poem_bloc.dart';
import '../../blocs/poem_bloc/poem_event.dart';
import '../../blocs/poem_bloc/poem_state.dart';
import '../../../app/dependency_injection.dart';

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
  late int _activeReportCount;
  late int _viewCount;

  @override
  void initState() {
    super.initState();
    final blocState = context.read<PoemBloc>().state;
    _isLiked = blocState.likedStates[widget.poem.id] ?? widget.poem.isLiked;
    _likeCount = blocState.likeCounts[widget.poem.id] ?? widget.poem.likeCount;
    _isBookmarked = blocState.favoritedStates[widget.poem.id] ?? widget.poem.isFavorited;
    _bookmarkCount = blocState.bookmarkCounts[widget.poem.id] ?? widget.poem.bookmarkCount;
    _activeReportCount = widget.poem.activeReportCount;
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
      _activeReportCount = widget.poem.activeReportCount;
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
            setState(() => _activeReportCount++);
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
                      onTap: _showReportsPopup,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_outlined, color: Color(0xFFAB9F8E), size: 18),
                          if (_activeReportCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '$_activeReportCount',
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

  void _showReportsPopup() async {
    final repo = getIt<PoemRepository>();
    final result = await repo.getReports(widget.poem.id);
    if (!mounted) return;
    final reports = <ReportModel>[];
    if (result.isSuccess && result.data != null) {
      for (final r in result.data!) {
        reports.add(ReportModel.fromJson(r as Map<String, dynamic>));
      }
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportStatusSheet(reports: reports),
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

class _ReportStatusSheet extends StatelessWidget {
  final List<ReportModel> reports;
  const _ReportStatusSheet({required this.reports});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'fix_submitted':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (reports.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No reports', style: TextStyle(color: Colors.grey))),
              )
            else
              ...reports.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(r.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            r.status.replaceAll('_', ' '),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor(r.status)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          r.reason.replaceAll('_', ' '),
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                    if (r.description != null && r.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        r.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B6358)),
                      ),
                    ],
                  ],
                ),
              )),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}