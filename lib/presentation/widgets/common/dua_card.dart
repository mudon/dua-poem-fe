import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/dua_model.dart';
import '../../../data/models/report_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/dua_repository.dart';
import '../../../core/themes/app_theme.dart';
import '../../blocs/dua_bloc/dua_bloc.dart';
import '../../blocs/dua_bloc/dua_event.dart';
import '../../blocs/dua_bloc/dua_state.dart';
import '../../../app/dependency_injection.dart';

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

  @override
  void initState() {
    super.initState();
    final blocState = context.read<DuaBloc>().state;
    _isLiked = blocState.likedStates[widget.dua.id] ?? widget.dua.isLiked;
    _likeCount = blocState.likeCounts[widget.dua.id] ?? widget.dua.likeCount;
    _isBookmarked = blocState.favoritedStates[widget.dua.id] ?? widget.dua.isFavorited;
    _bookmarkCount = blocState.bookmarkCounts[widget.dua.id] ?? widget.dua.bookmarkCount;
      _viewCount = blocState.viewCounts[widget.dua.id] ?? widget.dua.views;
    _activeReportCount = widget.dua.activeReportCount;
  }

  @override
  void didUpdateWidget(DuaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dua.id != widget.dua.id ||
        oldWidget.dua.likeCount != widget.dua.likeCount ||
        oldWidget.dua.isLiked != widget.dua.isLiked ||
        oldWidget.dua.bookmarkCount != widget.dua.bookmarkCount ||
        oldWidget.dua.isFavorited != widget.dua.isFavorited) {
      final blocState = context.read<DuaBloc>().state;
      _isLiked = blocState.likedStates[widget.dua.id] ?? widget.dua.isLiked;
      _isBookmarked = blocState.favoritedStates[widget.dua.id] ?? widget.dua.isFavorited;
      _viewCount = blocState.viewCounts[widget.dua.id] ?? widget.dua.views;
      _activeReportCount = widget.dua.activeReportCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DuaBloc, DuaState>(
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
            setState(() {
              _isBookmarked = !_isBookmarked;
              _bookmarkCount += _isBookmarked ? 1 : -1;
            });
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
        } else if (state.actionType == 'view') {
          final count = state.viewCounts[widget.dua.id];
          if (count != null) {
            setState(() => _viewCount = count);
          }
        } else if (state.actionType == 'report') {
          if (state.lastToggledDuaId != widget.dua.id) return;
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
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFDCE8D3),
                        child: Text(
                          widget.dua.userAvatar.isNotEmpty
                              ? widget.dua.userAvatar
                              : '?',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A5B3E)),
                        ),
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
                      onTap: _showReportPopout,
                      onLongPress: () => _showReportsPopup(context),
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

  Future<void> _showReportsPopup(BuildContext context) async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getReports(widget.dua.id);
    if (!mounted) return;
    final reports = <ReportModel>[];
    if (result.isSuccess && result.data != null) {
      for (final r in result.data!) {
        reports.add(ReportModel.fromJson(r as Map<String, dynamic>));
      }
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportStatusSheet(reports: reports),
    );
  }

  void _toggleLike() {
    final wasLiked = _isLiked;
    final currentCount = _likeCount;
    setState(() {
      _isLiked = !wasLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    context.read<DuaBloc>().add(ToggleLike(widget.dua.id, wasLiked, currentCount));
  }

  void _toggleBookmark() {
    final wasBookmarked = _isBookmarked;
    final currentCount = _bookmarkCount;
    setState(() {
      _isBookmarked = !wasBookmarked;
      _bookmarkCount += _isBookmarked ? 1 : -1;
    });
    context.read<DuaBloc>().add(ToggleBookmark(widget.dua.id, wasBookmarked, currentCount));
  }

  void _showReportPopout() {
    final reasons = ['wrong_arabic_text', 'wrong_transliteration', 'wrong_translation', 'wrong_source', 'inappropriate_content', 'duplicate_dua', 'other'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportBottomSheet(
        reasons: reasons,
        onSubmit: (reason, description) {
          Navigator.pop(ctx);
          context.read<DuaBloc>().add(ReportDua(widget.dua.id, reason, description));
        },
      ),
    );
  }
}

class _ReportStatusSheet extends StatelessWidget {
  final List<ReportModel> reports;

  const _ReportStatusSheet({required this.reports});

  String _formatReason(String reason) {
    return reason.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFD68B2E);
      case 'fix_submitted': return const Color(0xFF4A7BBF);
      case 'resolved': return const Color(0xFF3F7849);
      case 'dismissed': return const Color(0xFF9A8C79);
      default: return const Color(0xFF9A8C79);
    }
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
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
                Row(
                  children: [
                    const Icon(Icons.flag_outlined, size: 18, color: Color(0xFF7C9A6E)),
                    const SizedBox(width: 8),
                    Text(reports.length == 1 ? '1 Report' : '${reports.length} Reports',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
            child: reports.isEmpty
                ? const Center(child: Text('No reports yet', style: TextStyle(color: Color(0xFF9A8C79))))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    separatorBuilder: (_, _) => const Divider(height: 16, color: Color(0xFFEFE8DE)),
                    itemBuilder: (context, index) {
                      final r = reports[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_formatReason(r.reason),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _statusColor(r.status).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(_statusLabel(r.status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _statusColor(r.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (r.description != null && r.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(r.description!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF6B6152)),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (r.createdAt != null) ...[
                            const SizedBox(height: 4),
                            Text(r.createdAt!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFFAB9F8E))),
                          ],
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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

class _ReportBottomSheet extends StatefulWidget {
  final List<String> reasons;
  final Function(String reason, String description) onSubmit;

  const _ReportBottomSheet({required this.reasons, required this.onSubmit});

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
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
                    Text('Report content', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
