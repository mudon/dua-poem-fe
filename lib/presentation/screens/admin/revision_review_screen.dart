import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../app/dependency_injection.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/services/admin_service.dart';

class RevisionReviewScreen extends StatefulWidget {
  final String revisionId;
  final String contentType;
  final String contentTitle;

  const RevisionReviewScreen({
    super.key,
    required this.revisionId,
    required this.contentType,
    required this.contentTitle,
  });

  @override
  State<RevisionReviewScreen> createState() => _RevisionReviewScreenState();
}

class _RevisionReviewScreenState extends State<RevisionReviewScreen> {
  final _adminRepo = AdminRepository(getIt<AdminService>());
  Map<String, dynamic>? _beforeContent;
  Map<String, dynamic>? _afterContent;
  List<dynamic>? _reportIds;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  final Map<String, String> _decisions = {};

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final result = await _adminRepo.getRevisionDetail(widget.revisionId, widget.contentType);
    if (result.isSuccess) {
      final data = result.data!;
      final before = jsonDecode(data['beforeContent'] as String? ?? '{}') as Map<String, dynamic>;
      final after = jsonDecode(data['afterContent'] as String? ?? '{}') as Map<String, dynamic>;
      final reports = data['reportIds'] as List? ?? [];

      setState(() {
        _beforeContent = before;
        _afterContent = after;
        _reportIds = reports;
        _isLoading = false;
        for (var reportId in reports) {
          _decisions[reportId.toString()] = '';
        }
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReview() async {
    final actions = <String, String>{};
    for (final entry in _decisions.entries) {
      if (entry.value.isNotEmpty) {
        actions[entry.key] = entry.value;
      }
    }

    if (actions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No decisions made yet')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await _adminRepo.reviewRevision(widget.revisionId, widget.contentType, actions);
    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted'), backgroundColor: Color(0xFF3F7849)),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Error'), backgroundColor: const Color(0xFFD9534F)),
        );
      }
    }
  }

  List<String> _getFieldKeys() {
    if (_beforeContent == null) return [];
    return _beforeContent!.keys.toList();
  }

  String _formatLabel(String key) {
    return key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _displayValue(String key, Map<String, dynamic>? content) {
    final val = content?[key];
    if (val == null) return '(empty)';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contentTitle),
        backgroundColor: const Color(0xFFFEFCF7),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFFFEFCF7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    // Diff header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: const Color(0xFFF5F0E8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('Before',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF9A8C79))),
                          ),
                          const Text('→',
                            style: TextStyle(color: Color(0xFFAB9F8E), fontSize: 16)),
                          Expanded(
                            child: Text('After',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF3F7849))),
                          ),
                        ],
                      ),
                    ),

                    // Diff content
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _getFieldKeys().map((key) {
                          final before = _displayValue(key, _beforeContent);
                          final after = _displayValue(key, _afterContent);
                          final isChanged = before != after;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatLabel(key),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isChanged ? const Color(0xFF3C3730) : const Color(0xFFAB9F8E),
                                  )),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isChanged ? const Color(0xFFFFF0F0) : const Color(0xFFF8F6F0),
                                          borderRadius: BorderRadius.circular(8),
                                          border: isChanged ? Border.all(color: const Color(0xFFFFD6D6)) : null,
                                        ),
                                        child: Text(before,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isChanged ? const Color(0xFFC9302C) : const Color(0xFF6B6152),
                                          )),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isChanged ? const Color(0xFFF0FFF0) : const Color(0xFFF8F6F0),
                                          borderRadius: BorderRadius.circular(8),
                                          border: isChanged ? Border.all(color: const Color(0xFFD6FFD6)) : null,
                                        ),
                                        child: Text(after,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isChanged ? const Color(0xFF2D6A2D) : const Color(0xFF6B6152),
                                          )),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Report decisions
                    if (_reportIds != null && _reportIds!.isNotEmpty)
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(color: Color(0xFFEFE8DE))),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Report Decisions',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 8),
                            ..._reportIds!.map((reportId) {
                              final id = reportId.toString();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text('Report ${id.substring(0, 8)}...',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF7A6B5A))),
                                    ),
                                    const SizedBox(width: 8),
                                    _DecisionButton(
                                      label: 'Resolve',
                                      isSelected: _decisions[id] == 'resolved',
                                      color: const Color(0xFF3F7849),
                                      onTap: () => setState(() {
                                        _decisions[id] = _decisions[id] == 'resolved' ? '' : 'resolved';
                                      }),
                                    ),
                                    const SizedBox(width: 6),
                                    _DecisionButton(
                                      label: 'Dismiss',
                                      isSelected: _decisions[id] == 'dismissed',
                                      color: const Color(0xFF9A8C79),
                                      onTap: () => setState(() {
                                        _decisions[id] = _decisions[id] == 'dismissed' ? '' : 'dismissed';
                                      }),
                                    ),
                                    const SizedBox(width: 6),
                                    _DecisionButton(
                                      label: 'Pending',
                                      isSelected: _decisions[id] == 'pending',
                                      color: const Color(0xFFD68B2E),
                                      onTap: () => setState(() {
                                        _decisions[id] = _decisions[id] == 'pending' ? '' : 'pending';
                                      }),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitReview,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A5B3E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DecisionButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFD6CFC0),
          ),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? color : const Color(0xFF9A8C79),
          )),
      ),
    );
  }
}
