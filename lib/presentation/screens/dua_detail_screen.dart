import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/report_model.dart';
import '../../core/themes/app_theme.dart';
import '../../data/repositories/dua_repository.dart';
import '../../data/services/signalr_service.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_event.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../../app/dependency_injection.dart';

class DuaDetailScreen extends StatefulWidget {
  final String duaId;
  final UserModel currentUser;

  const DuaDetailScreen({super.key, required this.duaId, required this.currentUser});

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

  Future<void> _loadReports() async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getReports(widget.duaId);
    if (!mounted) return;
    final reports = <ReportModel>[];
    int pending = 0;
    if (result.isSuccess && result.data != null) {
      for (final r in result.data!) {
        final report = ReportModel.fromJson(r as Map<String, dynamic>);
        reports.add(report);
        if (report.status != 'resolved' && report.status != 'dismissed') {
          pending++;
        }
      }
    }
    setState(() {
      _reports = reports;
      _pendingCount = pending;
    });
  }

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
      for (final r in reportsResult.data!) {
        final report = ReportModel.fromJson(r as Map<String, dynamic>);
        if (report.status == 'pending') {
          pendingReports.add(report);
        }
      }
    }
    if (pendingReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending reports to fix')),
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
            const SnackBar(content: Text('Revision submitted — reports updated')),
          );
        },
      ),
    );
  }

  void _showReportsPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportListSheet(
        reports: _reports,
        itemTitle: _dua!.title,
      ),
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
                ? const Center(child: Text('Dua not found'))
                : BlocProvider.value(
                    value: getIt<DuaBloc>(),
                        child: BlocListener<DuaBloc, DuaState>(
                          listener: (context, state) {
                            if (state.error != null) {
                              setState(() {
                                if (state.actionType == 'like') {
                                  _isLiked = !_isLiked;
                                  _likeCount += _isLiked ? 1 : -1;
                                } else if (state.actionType == 'bookmark') {
                                  _isBookmarked = !_isBookmarked;
                                  _bookmarkCount += _isBookmarked ? 1 : -1;
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error!)),
                              );
                            }
                            final count = state.likeCounts[widget.duaId];
                            if (count != null && count != _likeCount) {
                              setState(() => _likeCount = count);
                            }
                            if (state.actionType == 'content_updated' && state.lastToggledDuaId == widget.duaId) {
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
                                    updatedAt: update.updatedAt,
                                  );
                                });
                                _loadReports();
                              }
                            }
                          },
                      child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back, color: AppTheme.sage, size: 20),
                                SizedBox(width: 8),
                                Text('Back', style: TextStyle(color: AppTheme.sage, fontWeight: FontWeight.w500, fontSize: 15)),
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
                                Text(_dua!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _dua!.verified ? const Color(0xFFE2F0DA) : const Color(0xFFFFF1E0),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    _dua!.verified ? '✓ Verified' : '⏳ Pending Review',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: _dua!.verified ? const Color(0xFF3F7849) : const Color(0xFFC47D2E),
                                    ),
                                  ),
                                ),
                                if (_dua!.arabicText != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F5EE),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _dua!.arabicText!,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(fontSize: 20, fontFamily: 'serif'),
                                    ),
                                  ),
                                ],
                                if (_dua!.transliteration != null) ...[
                                  const SizedBox(height: 12),
                                  _DetailField(label: 'Transliteration', value: _dua!.transliteration!),
                                ],
                                if (_dua!.translation.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _DetailField(label: 'Translation', value: _dua!.translation),
                                ],
                                const SizedBox(height: 12),
                                _DetailField(label: 'Category', value: _dua!.category),
                                if (_dua!.tags.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Text('Tags', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: _dua!.tags.map((t) => _TagPill(label: t)).toList(),
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
                                        getIt<DuaBloc>().add(ToggleLike(_dua!.id, wasLiked, currentCount));
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: const Color(0xFFD6B17E),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 6),
                                          Text('$_likeCount',
                                            style: const TextStyle(color: Color(0xFFD6B17E), fontWeight: FontWeight.w500, fontSize: 14)),
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
                                          _bookmarkCount += _isBookmarked ? 1 : -1;
                                        });
                                        getIt<DuaBloc>().add(ToggleBookmark(_dua!.id, wasBookmarked, currentCount));
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                            color: const Color(0xFFAB9F8E),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 6),
                                          Text('$_bookmarkCount',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFAB9F8E))),
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
                                        final reasons = ['wrong_arabic_text', 'wrong_transliteration', 'wrong_translation', 'wrong_source', 'inappropriate_content', 'duplicate_dua', 'other'];
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) => _DetailReportSheet(
                                            title: _dua!.title,
                                            reasons: reasons,
                                            onSubmit: (reason, desc) {
                                              getIt<DuaBloc>().add(ReportDua(_dua!.id, reason, desc));
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Report submitted')),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      onLongPress: () => _showReportsPopup(context),
                                      icon: const Icon(Icons.flag_outlined, size: 16),
                                      label: const Text('Report this content', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFEF1EC),
                                        foregroundColor: const Color(0xFFC25A3F),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                if (_dua!.userId == widget.currentUser.id) ...[
                                  const SizedBox(height: 10),
                                  Badge(
                                    label: Text('$_pendingCount', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                    isLabelVisible: _pendingCount > 0,
                                    backgroundColor: const Color(0xFFC25A3F),
                                    textColor: Colors.white,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showFixSheet(context),
                                        icon: const Icon(Icons.edit_outlined, size: 16),
                                        label: const Text('Fix & Update', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE8F0E2),
                                          foregroundColor: const Color(0xFF3F7849),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}

class _ReportListSheet extends StatelessWidget {
  final List<ReportModel> reports;
  final String itemTitle;

  const _ReportListSheet({required this.reports, required this.itemTitle});

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
        const SnackBar(content: Text('Select at least one report to fix')),
      );
      return;
    }
    setState(() => _submitting = true);
    final data = <String, dynamic>{
      'reportIds': _selectedReportIds.toList(),
    };
    if (_titleCtrl.text != widget.initialTitle) data['title'] = _titleCtrl.text;
    if (_arabicCtrl.text != widget.initialArabicText) data['arabicText'] = _arabicCtrl.text;
    if (_transliterationCtrl.text != widget.initialTransliteration) data['transliteration'] = _transliterationCtrl.text;
    if (_translationCtrl.text != widget.initialTranslation) data['translation'] = _translationCtrl.text;

    final repo = getIt<DuaRepository>();
    final result = await repo.createRevision(widget.duaId, data);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.isSuccess) {
      widget.onSubmit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to submit revision')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                    const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF7C9A6E)),
                    const SizedBox(width: 8),
                    const Text('Fix & Update', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                  const Text('Reports to fix', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF9A8C79))),
                  const SizedBox(height: 6),
                  ...widget.pendingReports.map((r) {
                    final label = r.reason.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                              color: isSelected ? AppTheme.sage : const Color(0xFFAB9F8E),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text('Updated content', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF9A8C79))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _translationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Translation',
                      filled: true,
                      fillColor: Color(0xFFF7F3ED),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3F7849)))
                    : const Text('Submit Fix', style: TextStyle(fontWeight: FontWeight.w600)),
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
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF3C3730))),
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
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF5D6F4A)),
      ),
    );
  }
}

class _DetailReportSheet extends StatefulWidget {
  final String title;
  final List<String> reasons;
  final Function(String reason, String description) onSubmit;

  const _DetailReportSheet({required this.title, required this.reasons, required this.onSubmit});

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
                    Text('Report: ${widget.title}',
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
