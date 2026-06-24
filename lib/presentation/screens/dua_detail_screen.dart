import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/action_type.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/report_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/tag_model.dart';
import '../../core/enums/report_status.dart';
import '../../core/enums/dua_report_reason.dart';
import '../../core/enums/badge_category.dart';
import '../../core/themes/app_theme.dart';
import '../../data/repositories/dua_repository.dart';
import '../../data/services/signalr_service.dart';
import '../../data/services/category_service.dart';
import '../../data/services/tag_service.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_event.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../../app/dependency_injection.dart';
import '../widgets/common/avatar_with_badge.dart';

class DuaDetailScreen extends StatefulWidget {
  final String duaId;
  final UserModel currentUser;

  const DuaDetailScreen({
    super.key,
    required this.duaId,
    required this.currentUser,
  });

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  DuaModel? _dua;
  bool _loading = true;
  late bool _isLiked;
  late int _likeCount;
  late bool _isBookmarked;
  late int _bookmarkCount;
  List<ReportModel> _reports = [];
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = 0;
    _isBookmarked = false;
    _bookmarkCount = 0;
    _loadDua();
    _loadReports();
    getIt<SignalRService>().joinDuaGroup(widget.duaId);
    getIt<SignalRService>().joinDuaReportGroup(widget.duaId);
  }

  @override
  void dispose() {
    getIt<SignalRService>().leaveDuaGroup(widget.duaId);
    getIt<SignalRService>().leaveDuaReportGroup(widget.duaId);
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getDuaDetail(widget.duaId);
    if (!mounted) return;
    setState(() {
      _dua = result.data;
      _isLiked = result.data?.isLiked ?? false;
      _likeCount = result.data?.likeCount ?? 0;
      _isBookmarked = result.data?.isFavorited ?? false;
      _bookmarkCount = result.data?.bookmarkCount ?? 0;
    });
  }

  Future<void> _loadReports() async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getReports(widget.duaId);
    if (!mounted) return;
    final reports = <ReportModel>[];
    int pending = 0;
    if (result.isSuccess && result.data != null) {
      for (final report in result.data!.data) {
        reports.add(report);
        if (report.status != ReportStatus.resolved && report.status != ReportStatus.dismissed) {
          pending++;
        }
      }
    }
    setState(() {
      _reports = reports;
      _pendingCount = pending;
    });
  }

  String _formatTimestamp(String iso) => formatTimestamp(iso);

  Future<void> _loadDua() async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getDuaDetail(widget.duaId);
    repo.recordView(widget.duaId);
    if (mounted) {
      setState(() {
        _dua = result.data;
        _isLiked = result.data?.isLiked ?? false;
        _likeCount = result.data?.likeCount ?? 0;
        _isBookmarked = result.data?.isFavorited ?? false;
        _bookmarkCount = result.data?.bookmarkCount ?? 0;
        _loading = false;
      });
    }
  }

  Future<void> _showFixSheet(BuildContext context) async {
    final repo = getIt<DuaRepository>();
    final reportsResult = await repo.getReports(widget.duaId);
    if (!context.mounted) return;
    final pendingReports = <ReportModel>[];
    if (reportsResult.isSuccess && reportsResult.data != null) {
      for (final report in reportsResult.data!.data) {
        if (report.status == ReportStatus.pending) {
          pendingReports.add(report);
        }
      }
    }
    if (pendingReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar('No pending reports to fix'),
      );
      return;
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DuaFixSheet(
        duaId: _dua!.id,
        initialTitle: _dua!.title,
        initialArabicText: _dua!.arabicText ?? '',
        initialTransliteration: _dua!.transliteration ?? '',
        initialTranslation: _dua!.translation,
        pendingReports: pendingReports,
        onSubmit: () {
          _loadReports();
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.successSnackBar('Revision submitted — reports updated'),
          );
        },
      ),
    );
  }

  Future<void> _deleteDua() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Dua'),
        content: const Text(
          'Are you sure you want to delete this dua? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC25A3F),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      getIt<DuaBloc>().add(DeleteDua(_dua!.id));
    }
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DuaEditSheet(
        duaId: _dua!.id,
        initialTitle: _dua!.title,
        initialArabicText: _dua!.arabicText ?? '',
        initialTransliteration: _dua!.transliteration ?? '',
        initialTranslation: _dua!.translation,
        initialDescription: _dua!.description ?? '',
        initialWhenToRecite: _dua!.whenToRecite ?? '',
        initialOccasion: _dua!.occasion ?? '',
        initialRepetitionCount: _dua!.repetitionCount ?? 1,
        initialCategoryId: _dua!.categoryId,
        initialTags: _dua!.tags,
      ),
    );
  }

  void _showReportsPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _ReportListSheet(reports: _reports, itemTitle: _dua!.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _dua == null
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: AppTheme.sage,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: AppTheme.sage,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: Center(child: Text('Dua not found'))),
                ],
              )
            : BlocProvider.value(
                value: getIt<DuaBloc>(),
                child: BlocListener<DuaBloc, DuaState>(
                  listener: (context, state) {
                    if (state.error != null && state.lastToggledDuaId == widget.duaId) {
                      final wasAction = state.actionType;
                      setState(() {
                        if (wasAction == ActionType.like) {
                          _isLiked = !_isLiked;
                          _likeCount += _isLiked ? 1 : -1;
                        } else if (wasAction == ActionType.bookmark) {
                          _isBookmarked = !_isBookmarked;
                          _bookmarkCount += _isBookmarked ? 1 : -1;
                        }
                      });
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(AppTheme.errorSnackBar(state.error!));
                    }
                    final count = state.likeCounts[widget.duaId];
                    if (count != null && count != _likeCount) {
                      setState(() => _likeCount = count);
                    }
                    if (state.actionType == ActionType.signalrReport) {
                      final c = state.reportCounts[widget.duaId];
                      if (c != null) {
                        setState(() => _pendingCount = c);
                      }
                    }
                    if (state.actionType == ActionType.report && state.lastToggledDuaId == widget.duaId) {
                      if (state.error != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(AppTheme.errorSnackBar(state.error!));
                      } else {
                        _loadReports();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(AppTheme.successSnackBar('Report submitted'));
                      }
                    }
                    if (state.actionType == ActionType.contentUpdated &&
                        state.lastToggledDuaId == widget.duaId) {
                      final update = state.contentUpdates[widget.duaId];
                      if (update != null && _dua != null) {
                        setState(() {
                          _dua = _dua!.copyWith(
                            title: update.title,
                            arabicText: update.arabicText,
                            transliteration: update.transliteration,
                            translation: update.translation,
                            description: update.description,
                            whenToRecite: update.whenToRecite,
                            occasion: update.occasion,
                            repetitionCount: update.repetitionCount,
                            category: update.category,
                            categoryId: update.categoryId,
                            tags: update.tags,
                            updatedAt: update.updatedAt,
                          );
                        });
                        _loadReports();
                      }
                    }
                    if (state.actionType == ActionType.deleted &&
                        state.lastToggledDuaId == widget.duaId) {
                      if (context.mounted) context.pop();
                    }
                    if (state.actionType == ActionType.deleteError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        AppTheme.errorSnackBar(state.error ?? 'Failed to delete'),
                      );
                    }
                  },
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: AppTheme.sage,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: AppTheme.sage,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_dua!.userName.isNotEmpty) ...[
                                Row(
                                  children: [
                                    AvatarWithBadge(
                                      avatarType: _dua!.createdByAvatarType,
                                      avatarValue: _dua!.createdByAvatarValue,
                                      name: _dua!.userName,
                                      showBadge: _dua!.createdBySelectedBadgeSlug != null,
                                      badgeColor: _dua!.createdByBadges.firstWhere(
                                        (b) => b['slug'] == _dua!.createdBySelectedBadgeSlug,
                                        orElse: () => <String, String?>{},
                                      )['color'],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _dua!.userName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3C3730),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_dua!.createdByBadges.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 28,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _dua!.createdByBadges.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 6),
                                      itemBuilder: (context, index) {
                                        final badge =
                                            _dua!.createdByBadges[index];
                                        final badgeHex = badge['color'];
                                        final badgeColor = badgeHex != null
                                            ? Color(int.parse(
                                                badgeHex.replaceFirst(
                                                    '#', '0xFF')))
                                            : BadgeCategory.fromSlugPrefix(
                                                    badge['slug']!)
                                                .color;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeColor
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: badgeColor
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                BadgeCategory.fromSlugPrefix(
                                                        badge['slug']!)
                                                    .icon,
                                                size: 12,
                                                color: badgeColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                badge['name']!,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: badgeColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                              ],
                              Text(
                                _dua!.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F5EE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _dua!.arabicText ?? '',
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                              if (_dua!.transliteration != null && _dua!.transliteration!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Transliteration',
                                  value: _dua!.transliteration!,
                                ),
                              ],
                              if (_dua!.translation.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Translation',
                                  value: _dua!.translation,
                                ),
                              ],
                              if (_dua!.category.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Category',
                                  value: _dua!.category,
                                ),
                              ],
                              if (_dua!.tags.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  'Tags',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9A8C79),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: _dua!.tags
                                      .map((t) => _TagPill(label: t))
                                      .toList(),
                                 ),
                                ],
                              if (_dua!.description != null && _dua!.description!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Description',
                                  value: _dua!.description!,
                                ),
                              ],
                              if (_dua!.whenToRecite != null && _dua!.whenToRecite!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'When to Recite',
                                  value: _dua!.whenToRecite!,
                                ),
                              ],
                              if (_dua!.occasion != null && _dua!.occasion!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Occasion',
                                  value: _dua!.occasion!,
                                ),
                              ],
                              if (_dua!.repetitionCount != null) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Repetition Count',
                                  value: _dua!.repetitionCount.toString(),
                                ),
                              ],
                              if (_dua!.createdAt != null) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Created At',
                                  value: _formatTimestamp(_dua!.createdAt!),
                                ),
                              ],
                              if (_dua!.updatedAt != null) ...[
                                const SizedBox(height: 12),
                                _DetailField(
                                  label: 'Updated At',
                                  value: _formatTimestamp(_dua!.updatedAt!),
                                ),
                              ],
                              const SizedBox(height: 16),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        final wasLiked = _isLiked;
                                        final currentCount = _likeCount;
                                        setState(() {
                                          _isLiked = !_isLiked;
                                          _likeCount += _isLiked ? 1 : -1;
                                        });
                                        getIt<DuaBloc>().add(
                                          ToggleLike(
                                            _dua!.id,
                                            wasLiked,
                                            currentCount,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: const Color(0xFFD6B17E),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$_likeCount',
                                            style: const TextStyle(
                                              color: Color(0xFFD6B17E),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 24),
                                  GestureDetector(
                                    onTap: () {
                                      final wasBookmarked = _isBookmarked;
                                      final currentCount = _bookmarkCount;
                                      setState(() {
                                        _isBookmarked = !_isBookmarked;
                                        _bookmarkCount += _isBookmarked
                                            ? 1
                                            : -1;
                                      });
                                      getIt<DuaBloc>().add(
                                        ToggleBookmark(
                                          _dua!.id,
                                          wasBookmarked,
                                          currentCount,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: const Color(0xFFAB9F8E),
                                          size: 22,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$_bookmarkCount',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFAB9F8E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final reasons = DuaReportReason.values;
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => _DetailReportSheet(
                                        title: _dua!.title,
                                        reasons: reasons,
                                        onSubmit: (DuaReportReason reason, desc) {
                                          getIt<DuaBloc>().add(
                                            ReportDua(_dua!.id, reason.value, desc),
                                          );
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                    );
                                  },
                                  onLongPress: () => _showReportsPopup(context),
                                  icon: const Icon(
                                    Icons.flag_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Report this content',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFEF1EC),
                                    foregroundColor: const Color(0xFFC25A3F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (_dua!.userId == widget.currentUser.id) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _showEditSheet,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE8F0E2),
                                      foregroundColor: const Color(0xFF3F7849),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _deleteDua,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFEF1EC),
                                      foregroundColor: const Color(0xFFC25A3F),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Badge(
                                  label: Text(
                                    '$_pendingCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  isLabelVisible: _pendingCount > 0,
                                  backgroundColor: const Color(0xFFC25A3F),
                                  textColor: Colors.white,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showFixSheet(context),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Fix & Update',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE8F0E2,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF3F7849,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            40,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ReportListSheet extends StatelessWidget {
  final List<ReportModel> reports;
  final String itemTitle;

  const _ReportListSheet({required this.reports, required this.itemTitle});



  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
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
                    const Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: Color(0xFF7C9A6E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reports.length == 1
                          ? '1 Report'
                          : '${reports.length} Reports',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
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
                ? const Center(
                    child: Text(
                      'No reports yet',
                      style: TextStyle(color: Color(0xFF9A8C79)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 16, color: Color(0xFFEFE8DE)),
                    itemBuilder: (context, index) {
                      final r = reports[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.reason.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: r.status.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  r.status.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: r.status.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (r.description != null &&
                              r.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              r.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B6152),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (r.createdAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              formatTimestamp(r.createdAt!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFAB9F8E),
                              ),
                            ),
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

class _DuaFixSheet extends StatefulWidget {
  final String duaId;
  final String initialTitle;
  final String initialArabicText;
  final String initialTransliteration;
  final String initialTranslation;
  final List<ReportModel> pendingReports;
  final VoidCallback onSubmit;

  const _DuaFixSheet({
    required this.duaId,
    required this.initialTitle,
    required this.initialArabicText,
    required this.initialTransliteration,
    required this.initialTranslation,
    required this.pendingReports,
    required this.onSubmit,
  });

  @override
  State<_DuaFixSheet> createState() => _DuaFixSheetState();
}

class _DuaFixSheetState extends State<_DuaFixSheet> {
  final _titleCtrl = TextEditingController();
  final _arabicCtrl = TextEditingController();
  final _transliterationCtrl = TextEditingController();
  final _translationCtrl = TextEditingController();
  final Set<String> _selectedReportIds = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.initialTitle;
    _arabicCtrl.text = widget.initialArabicText;
    _transliterationCtrl.text = widget.initialTransliteration;
    _translationCtrl.text = widget.initialTranslation;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _arabicCtrl.dispose();
    _transliterationCtrl.dispose();
    _translationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar('Select at least one report to fix'),
      );
      return;
    }
    setState(() => _submitting = true);
    final data = <String, dynamic>{'reportIds': _selectedReportIds.toList()};
    if (_titleCtrl.text != widget.initialTitle) data['title'] = _titleCtrl.text;
    if (_arabicCtrl.text != widget.initialArabicText)
      data['arabicText'] = _arabicCtrl.text;
    if (_transliterationCtrl.text != widget.initialTransliteration)
      data['transliteration'] = _transliterationCtrl.text;
    if (_translationCtrl.text != widget.initialTranslation)
      data['translation'] = _translationCtrl.text;

    final repo = getIt<DuaRepository>();
    final result = await repo.createRevision(widget.duaId, data);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.isSuccess) {
      widget.onSubmit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(result.error ?? 'Failed to submit revision'),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
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
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF7C9A6E),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Fix & Update',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reports to fix',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF9A8C79),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...widget.pendingReports.map((r) {
                    final label = r.reason
                        .replaceAll('_', ' ')
                        .split(' ')
                        .map(
                          (w) => w.isNotEmpty
                              ? '${w[0].toUpperCase()}${w.substring(1)}'
                              : '',
                        )
                        .join(' ');
                    final isSelected = _selectedReportIds.contains(r.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedReportIds.remove(r.id);
                          } else {
                            _selectedReportIds.add(r.id);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: isSelected
                                  ? AppTheme.sage
                                  : const Color(0xFFAB9F8E),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Updated content',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF9A8C79),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _arabicCtrl,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'Arabic Text',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _transliterationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Transliteration',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _translationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Translation',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F0E2),
                  foregroundColor: const Color(0xFF3F7849),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3F7849),
                        ),
                      )
                    : const Text(
                        'Submit Fix',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaEditSheet extends StatefulWidget {
  final String duaId;
  final String initialTitle;
  final String initialArabicText;
  final String initialTransliteration;
  final String initialTranslation;
  final String initialDescription;
  final String initialWhenToRecite;
  final String initialOccasion;
  final int initialRepetitionCount;
  final int? initialCategoryId;
  final List<String> initialTags;

  const _DuaEditSheet({
    required this.duaId,
    required this.initialTitle,
    required this.initialArabicText,
    required this.initialTransliteration,
    required this.initialTranslation,
    required this.initialDescription,
    required this.initialWhenToRecite,
    required this.initialOccasion,
    required this.initialRepetitionCount,
    this.initialCategoryId,
    required this.initialTags,
  });

  @override
  State<_DuaEditSheet> createState() => _DuaEditSheetState();
}

class _DuaEditSheetState extends State<_DuaEditSheet> {
  final _titleCtrl = TextEditingController();
  final _arabicCtrl = TextEditingController();
  final _transliterationCtrl = TextEditingController();
  final _translationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _whenToReciteCtrl = TextEditingController();
  final _occasionCtrl = TextEditingController();
  late int _repetitionCount;
  final _repetitionCtrl = TextEditingController();
  CategoryModel? _selectedCategory;
  Set<int> _selectedTagIds = {};
  List<CategoryModel> _categories = [];
  List<TagModel> _tags = [];
  bool _loadingCategories = true;
  bool _loadingTags = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.initialTitle;
    _arabicCtrl.text = widget.initialArabicText;
    _transliterationCtrl.text = widget.initialTransliteration;
    _translationCtrl.text = widget.initialTranslation;
    _descriptionCtrl.text = widget.initialDescription;
    _whenToReciteCtrl.text = widget.initialWhenToRecite;
    _occasionCtrl.text = widget.initialOccasion;
    _repetitionCount = widget.initialRepetitionCount;
    _repetitionCtrl.text = widget.initialRepetitionCount.toString();
    _loadData();
  }

  Future<void> _loadData() async {
    final catService = getIt<CategoryService>();
    final tagService = getIt<TagService>();
    try {
      final cats = await catService.getAll();
      final tags = await tagService.getAll();
      if (mounted) {
        setState(() {
          _categories = cats;
          _tags = tags;
          _loadingCategories = false;
          _loadingTags = false;
          if (widget.initialCategoryId != null) {
            _selectedCategory = cats.cast<CategoryModel?>().firstWhere(
              (c) => c!.id == widget.initialCategoryId,
              orElse: () => null,
            );
          }
          _selectedTagIds = tags
              .where((t) => widget.initialTags.contains(t.name))
              .map((t) => t.id)
              .toSet();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingCategories = false;
          _loadingTags = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _arabicCtrl.dispose();
    _transliterationCtrl.dispose();
    _translationCtrl.dispose();
    _descriptionCtrl.dispose();
    _whenToReciteCtrl.dispose();
    _occasionCtrl.dispose();
    _repetitionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppTheme.errorSnackBar('Title is required'));
      return;
    }
    setState(() => _saving = true);
    getIt<DuaBloc>().add(
      UpdateDua(
        duaId: widget.duaId,
        title: _titleCtrl.text,
        arabicText: _arabicCtrl.text,
        transliteration: _transliterationCtrl.text,
        translation: _translationCtrl.text,
        description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        whenToRecite: _whenToReciteCtrl.text.isEmpty ? null : _whenToReciteCtrl.text,
        occasion: _occasionCtrl.text.isEmpty ? null : _occasionCtrl.text,
        repetitionCount: _repetitionCount,
        categoryId: _selectedCategory?.id,
        tagIds: _selectedTagIds.toList(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
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
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF7C9A6E),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Dua',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _arabicCtrl,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'Arabic Text',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _transliterationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Transliteration',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _translationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Translation',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _whenToReciteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'When to Recite',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _occasionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Occasion',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Repetition Count',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3C3730),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.sage),
                        onPressed: () {
                          if (_repetitionCount > 1) {
                            setState(() => _repetitionCount--);
                            _repetitionCtrl.text = _repetitionCount.toString();
                          }
                        },
                      ),
                      SizedBox(
                        width: 72,
                        child: TextField(
                          controller: _repetitionCtrl,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            filled: true,
                            fillColor: Color(0xFFF7F3ED),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.sage),
                        onPressed: () {
                          setState(() => _repetitionCount++);
                          _repetitionCtrl.text = _repetitionCount.toString();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: _loadingCategories
                        ? [DropdownMenuItem(value: null, child: const Text('Loading...'))]
                        : _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9A8C79),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _loadingTags
                      ? const Text('Loading...', style: TextStyle(color: Color(0xFF9A8C79)))
                      : Wrap(
                          spacing: 6,
                          children: _tags.map((t) {
                            final isSelected = _selectedTagIds.contains(t.id);
                            return FilterChip(
                              label: Text(t.name, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              onSelected: (sel) {
                                setState(() {
                                  if (sel) {
                                    _selectedTagIds.add(t.id);
                                  } else {
                                    _selectedTagIds.remove(t.id);
                                  }
                                });
                              },
                              backgroundColor: const Color(0xFFF1EEE7),
                              selectedColor: const Color(0xFF5D6F4A).withValues(alpha: 0.12),
                              checkmarkColor: const Color(0xFF5D6F4A),
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F0E2),
                  foregroundColor: const Color(0xFF3F7849),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3F7849),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  const _DetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8C79),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Color(0xFF3C3730)),
        ),
      ],
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
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5D6F4A),
        ),
      ),
    );
  }
}

class _DetailReportSheet extends StatefulWidget {
  final String title;
  final List<DuaReportReason> reasons;
  final Function(DuaReportReason reason, String description) onSubmit;

  const _DetailReportSheet({
    required this.title,
    required this.reasons,
    required this.onSubmit,
  });

  @override
  State<_DetailReportSheet> createState() => _DetailReportSheetState();
}

class _DetailReportSheetState extends State<_DetailReportSheet> {
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
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
                    const Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: Color(0xFF7C9A6E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Report: ${widget.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
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
                  final isSelected = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? AppTheme.sage
                                : const Color(0xFFAB9F8E),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(r.displayName, style: const TextStyle(fontSize: 14)),
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
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onSubmit(
                  widget.reasons[_selectedIndex],
                  _descCtrl.text,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF1EC),
                  foregroundColor: const Color(0xFFC25A3F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Submit Report',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatTimestamp(String iso) {
  try {
    final dt = DateTime.parse(iso);
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  } catch (_) {
    return iso;
  }
}
