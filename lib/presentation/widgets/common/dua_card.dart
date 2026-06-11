import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/dua_model.dart';
import '../../../data/models/user_model.dart';
import 'avatar_with_badge.dart';
import '../../blocs/dua_bloc/dua_bloc.dart';
import '../../blocs/dua_bloc/dua_event.dart';
import '../../blocs/dua_bloc/dua_state.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/models/report_model.dart';
import '../../../data/repositories/dua_repository.dart';
import 'report_status_sheet.dart';

class DuaCard extends StatefulWidget {
  final DuaModel dua;
  final UserModel currentUser;

  const DuaCard({super.key, required this.dua, required this.currentUser});

  @override
  State<DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<DuaCard> {
  late bool _isLiked;
  late int _likeCount;
  late bool _isBookmarked;
  late int _bookmarkCount;
  late int _activeReportCount;
  late int _viewCount;
  late bool _needsFix;

  @override
  void initState() {
    super.initState();
    final blocState = context.read<DuaBloc>().state;
    _isLiked = blocState.likedStates[widget.dua.id] ?? widget.dua.isLiked;
    _likeCount = blocState.likeCounts[widget.dua.id] ?? widget.dua.likeCount;
    _isBookmarked = blocState.favoritedStates[widget.dua.id] ?? widget.dua.isFavorited;
    _bookmarkCount = blocState.bookmarkCounts[widget.dua.id] ?? widget.dua.bookmarkCount;
    _viewCount = blocState.viewCounts[widget.dua.id] ?? widget.dua.views;
    _activeReportCount = blocState.reportCounts[widget.dua.id] ?? widget.dua.activeReportCount;
    _needsFix = widget.currentUser.id == widget.dua.userId && blocState.returnedReportIds.contains(widget.dua.id);
  }

  @override
  void didUpdateWidget(DuaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dua.id != widget.dua.id ||
        oldWidget.dua.title != widget.dua.title ||
        oldWidget.dua.arabicText != widget.dua.arabicText ||
        oldWidget.dua.translation != widget.dua.translation ||
        oldWidget.dua.likeCount != widget.dua.likeCount ||
        oldWidget.dua.isLiked != widget.dua.isLiked ||
        oldWidget.dua.bookmarkCount != widget.dua.bookmarkCount ||
        oldWidget.dua.isFavorited != widget.dua.isFavorited) {
      final blocState = context.read<DuaBloc>().state;
      _isLiked = blocState.likedStates[widget.dua.id] ?? widget.dua.isLiked;
      _likeCount = blocState.likeCounts[widget.dua.id] ?? widget.dua.likeCount;
      _isBookmarked = blocState.favoritedStates[widget.dua.id] ?? widget.dua.isFavorited;
      _bookmarkCount = blocState.bookmarkCounts[widget.dua.id] ?? widget.dua.bookmarkCount;
      _viewCount = blocState.viewCounts[widget.dua.id] ?? widget.dua.views;
      _activeReportCount = blocState.reportCounts[widget.dua.id] ?? widget.dua.activeReportCount;
      _needsFix = widget.currentUser.id == widget.dua.userId && blocState.returnedReportIds.contains(widget.dua.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DuaBloc, DuaState>(
      listener: (context, state) {
        if (state.actionType == 'signalr_like') {
          final count = state.likeCounts[widget.dua.id];
          if (count != null) {
            setState(() => _likeCount = count);
          }
        } else if (state.actionType == 'signalr_bookmark') {
          final count = state.bookmarkCounts[widget.dua.id];
          if (count != null) {
            setState(() => _bookmarkCount = count);
          }
        } else if (state.actionType == 'like') {
          if (state.error != null) {
            setState(() => _isLiked = !_isLiked);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          } else {
            final liked = state.likedStates[widget.dua.id];
            final count = state.likeCounts[widget.dua.id];
            if (liked != null && count != null) {
              setState(() {
                _isLiked = liked;
                _likeCount = count;
              });
            }
          }
        } else if (state.actionType == 'bookmark') {
          if (state.error != null) {
            setState(() => _isBookmarked = !_isBookmarked);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          } else {
            final fav = state.favoritedStates[widget.dua.id];
            final count = state.bookmarkCounts[widget.dua.id];
            if (fav != null && count != null) {
              setState(() {
                _isBookmarked = fav;
                _bookmarkCount = count;
              });
            }
          }
        } else if (state.actionType == 'signalr_view') {
          final count = state.viewCounts[widget.dua.id];
          if (count != null) {
            setState(() => _viewCount = count);
          }
        } else if (state.actionType == 'view') {
          final count = state.viewCounts[widget.dua.id];
          if (count != null) {
            setState(() => _viewCount = count);
          }
        } else if (state.actionType == 'signalr_report') {
          final count = state.reportCounts[widget.dua.id];
          if (count != null) {
            setState(() => _activeReportCount = count);
          }
        } else if (state.actionType == 'signalr_report_returned') {
          if (state.lastToggledDuaId == widget.dua.id && widget.currentUser.id == widget.dua.userId) {
            setState(() => _needsFix = true);
          }
        } else if (state.actionType == 'report') {
          if (state.lastToggledDuaId != widget.dua.id) return;
          final count = state.reportCounts[widget.dua.id];
          if (count != null) {
            setState(() => _activeReportCount = count);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Report failed: ${state.error}')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted')),
            );
          }
        } else if (state.actionType == 'content_updated') {
          if (state.lastToggledDuaId != widget.dua.id) return;
          setState(() {});
        }
      },
      child: GestureDetector(
      onTap: () => context.push('/dua/${widget.dua.id}', extra: widget.currentUser),
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
                        child: Text(widget.dua.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.dua.verified ? const Color(0xFFE2F0DA) : const Color(0xFFFFF1E0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          widget.dua.verified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: widget.dua.verified ? const Color(0xFF3F7849) : const Color(0xFFC47D2E),
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
            if (widget.dua.arabicText != null) ...[
              const SizedBox(height: 8),
              Text(widget.dua.arabicText!, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 18, fontFamily: 'serif', color: Color(0xFF2F3E2C))),
            ],
            if (widget.dua.transliteration != null) ...[
              const SizedBox(height: 4),
              Text(widget.dua.transliteration!, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Color(0xFF7A6B5A))),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFFA8C39B), width: 3)),
              ),
              child: Text(widget.dua.translation, style: const TextStyle(fontSize: 13, color: Color(0xFF4C473F))),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MetaChip(icon: Icons.category_outlined, label: widget.dua.category),
              ],
            ),
            if (widget.dua.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.dua.tags.map((t) => _TagPill(label: t)).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFF0EAE0)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.push('/user/${widget.dua.userId}', extra: widget.dua.userName),
                  child: Row(
                    children: [
                      AvatarWithBadge(
                        avatarType: widget.dua.createdByAvatarType,
                        avatarValue: widget.dua.createdByAvatarValue,
                        name: widget.dua.userName,
                        showBadge: widget.dua.createdBySelectedBadgeSlug != null,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.dua.userName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5C5346))),
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
                      onTap: () => _showReportsPopup(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              const Icon(Icons.flag_outlined, color: Color(0xFFAB9F8E), size: 18),
                              if (_needsFix)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE6A817),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
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

  Future<void> _showReportsPopup(BuildContext context) async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getReports(widget.dua.id);
    if (!mounted) return;
    final reports = result.data?.data ?? <ReportModel>[];
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportStatusSheet(reports: reports),
    );
  }

  void _toggleLike() {
    final wasLiked = _isLiked;
    setState(() => _isLiked = !wasLiked);
    context.read<DuaBloc>().add(ToggleLike(widget.dua.id, wasLiked, _likeCount));
  }

  void _toggleBookmark() {
    final wasBookmarked = _isBookmarked;
    setState(() => _isBookmarked = !wasBookmarked);
    context.read<DuaBloc>().add(ToggleBookmark(widget.dua.id, wasBookmarked, _bookmarkCount));
  }

}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

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

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

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


