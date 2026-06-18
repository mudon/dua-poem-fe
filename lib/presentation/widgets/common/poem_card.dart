import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums/action_type.dart';
import '../../../core/constants/route_paths.dart';
import '../../../data/models/poem_model.dart';
import '../../../data/models/report_model.dart';
import '../../../data/models/user_model.dart';
import 'avatar_with_badge.dart';
import '../../../data/repositories/poem_repository.dart';
import '../../../core/enums/avatar_type.dart';
import '../../../core/themes/app_theme.dart';
import '../../blocs/poem_bloc/poem_bloc.dart';
import '../../blocs/poem_bloc/poem_event.dart';
import '../../blocs/poem_bloc/poem_state.dart';
import '../../../app/dependency_injection.dart';
import 'report_status_sheet.dart';

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
  late bool _needsFix;
  late String _title;
  late String? _content;
  late String _userName;
  late AvatarType? _avatarType;
  late String? _avatarValue;
  late String? _selectedBadgeSlug;

  @override
  void initState() {
    super.initState();
    final blocState = context.read<PoemBloc>().state;
    final contentUpdate = blocState.contentUpdates[widget.poem.id];
    _isLiked = blocState.likedStates[widget.poem.id] ?? widget.poem.isLiked;
    _likeCount = blocState.likeCounts[widget.poem.id] ?? widget.poem.likeCount;
    _isBookmarked = blocState.favoritedStates[widget.poem.id] ?? widget.poem.isFavorited;
    _bookmarkCount = blocState.bookmarkCounts[widget.poem.id] ?? widget.poem.bookmarkCount;
    _viewCount = blocState.viewCounts[widget.poem.id] ?? widget.poem.views;
    _activeReportCount = blocState.reportCounts[widget.poem.id] ?? widget.poem.activeReportCount;
    _needsFix = widget.currentUser.id == widget.poem.userId && blocState.returnedReportIds.contains(widget.poem.id);
    _title = contentUpdate?.title ?? widget.poem.title;
    _content = contentUpdate?.content ?? widget.poem.content;
    _userName = widget.poem.userName;
    _avatarType = widget.poem.createdByAvatarType;
    _avatarValue = widget.poem.createdByAvatarValue;
    _selectedBadgeSlug = widget.poem.createdBySelectedBadgeSlug;
  }

  @override
  void didUpdateWidget(PoemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poem.id != widget.poem.id ||
        oldWidget.poem.title != widget.poem.title ||
        oldWidget.poem.content != widget.poem.content ||
        oldWidget.poem.translation != widget.poem.translation ||
        oldWidget.poem.likeCount != widget.poem.likeCount ||
        oldWidget.poem.isLiked != widget.poem.isLiked ||
        oldWidget.poem.bookmarkCount != widget.poem.bookmarkCount ||
        oldWidget.poem.isFavorited != widget.poem.isFavorited ||
        oldWidget.poem.userName != widget.poem.userName ||
        oldWidget.poem.createdByAvatarType != widget.poem.createdByAvatarType ||
        oldWidget.poem.createdByAvatarValue != widget.poem.createdByAvatarValue ||
        oldWidget.poem.createdBySelectedBadgeSlug != widget.poem.createdBySelectedBadgeSlug) {
      final blocState = context.read<PoemBloc>().state;
      final contentUpdate = blocState.contentUpdates[widget.poem.id];
      _isLiked = blocState.likedStates[widget.poem.id] ?? widget.poem.isLiked;
      _likeCount = blocState.likeCounts[widget.poem.id] ?? widget.poem.likeCount;
      _isBookmarked = blocState.favoritedStates[widget.poem.id] ?? widget.poem.isFavorited;
      _bookmarkCount = blocState.bookmarkCounts[widget.poem.id] ?? widget.poem.bookmarkCount;
      _activeReportCount = blocState.reportCounts[widget.poem.id] ?? widget.poem.activeReportCount;
      _viewCount = blocState.viewCounts[widget.poem.id] ?? widget.poem.views;
      _needsFix = widget.currentUser.id == widget.poem.userId && blocState.returnedReportIds.contains(widget.poem.id);
      _title = contentUpdate?.title ?? widget.poem.title;
      _content = contentUpdate?.content ?? widget.poem.content;
      _userName = widget.poem.userName;
      _avatarType = widget.poem.createdByAvatarType;
      _avatarValue = widget.poem.createdByAvatarValue;
      _selectedBadgeSlug = widget.poem.createdBySelectedBadgeSlug;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PoemBloc, PoemState>(
      listener: (context, state) {
        if (state.actionType == ActionType.signalrLike) {
          final count = state.likeCounts[widget.poem.id];
          if (count != null) {
            setState(() => _likeCount = count);
          }
        } else if (state.actionType == ActionType.signalrBookmark) {
          final count = state.bookmarkCounts[widget.poem.id];
          if (count != null) {
            setState(() => _bookmarkCount = count);
          }
        } else if (state.actionType == ActionType.like) {
          if (state.error != null) {
            setState(() => _isLiked = !_isLiked);
            ScaffoldMessenger.of(context).showSnackBar(
              AppTheme.errorSnackBar(state.error!),
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
        } else if (state.actionType == ActionType.bookmark) {
          if (state.error != null) {
            setState(() => _isBookmarked = !_isBookmarked);
            ScaffoldMessenger.of(context).showSnackBar(
              AppTheme.errorSnackBar(state.error!),
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
        } else if (state.actionType == ActionType.signalrView) {
          final count = state.viewCounts[widget.poem.id];
          if (count != null) {
            setState(() => _viewCount = count);
          }
        } else if (state.actionType == ActionType.view) {
          final count = state.viewCounts[widget.poem.id];
          if (count != null) {
            setState(() => _viewCount = count);
          }
        } else if (state.actionType == ActionType.signalrReport) {
          final count = state.reportCounts[widget.poem.id];
          if (count != null) {
            setState(() => _activeReportCount = count);
          }
        } else if (state.actionType == ActionType.signalrReportReturned) {
          if (state.lastToggledPoemId == widget.poem.id && widget.currentUser.id == widget.poem.userId) {
            setState(() => _needsFix = true);
          }
        } else if (state.actionType == ActionType.report) {
          if (state.lastToggledPoemId != widget.poem.id) return;
          final count = state.reportCounts[widget.poem.id];
          if (count != null) {
            setState(() => _activeReportCount = count);
          }
        } else if (state.actionType == ActionType.contentUpdated) {
          if (state.lastToggledPoemId != widget.poem.id) return;
          final update = state.contentUpdates[widget.poem.id];
          if (update != null) {
            setState(() {
              _title = update.title;
              if (update.content != null) _content = update.content;
            });
          }
        } else if (state.actionType == ActionType.profileUpdate) {
          if (state.lastToggledPoemId != widget.poem.userId) return;
          final update = state.profileUpdates[widget.poem.userId];
          if (update != null) {
            setState(() {
              _userName = update.userName;
              _avatarType = update.avatarType;
              _avatarValue = update.avatarValue;
              _selectedBadgeSlug = update.selectedBadgeSlug;
            });
          }
        }
      },
      child: GestureDetector(
      onTap: () => context.push(RoutePaths.poemDetail(widget.poem.id), extra: widget.currentUser),
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
                        child: Text(_title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
            if (_content != null)
              Text(
                '"${_content!.length > 80 ? '${_content!.substring(0, 80)}…' : _content!}"',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF4C473F)),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PoemMetaChip(icon: Icons.person_outline, label: _userName),
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
                  onTap: () => context.push(RoutePaths.userDetail(widget.poem.userId), extra: _userName),
                  child: Row(
                    children: [
                      AvatarWithBadge(
                        avatarType: _avatarType,
                        avatarValue: _avatarValue,
                        name: _userName,
                        showBadge: _selectedBadgeSlug != null,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5C5346))),
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

  void _toggleLike() {
    final wasLiked = _isLiked;
    setState(() => _isLiked = !wasLiked);
    context.read<PoemBloc>().add(ToggleLike(widget.poem.id, wasLiked, _likeCount));
  }

  void _toggleBookmark() {
    final wasBookmarked = _isBookmarked;
    setState(() => _isBookmarked = !wasBookmarked);
    context.read<PoemBloc>().add(ToggleBookmark(widget.poem.id, wasBookmarked, _bookmarkCount));
  }

  Future<void> _showReportsPopup() async {
    final repo = getIt<PoemRepository>();
    final result = await repo.getReports(widget.poem.id);
    if (!mounted) return;
    final reports = result.data?.data ?? <ReportModel>[];
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportStatusSheet(reports: reports),
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

