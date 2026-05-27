import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../core/themes/app_theme.dart';
import '../../data/repositories/dua_repository.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_event.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDua();
  }

  Future<void> _loadDua() async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getDuaDetail(widget.duaId);
    if (mounted) {
      setState(() {
        _dua = result.data;
        _loading = false;
      });
    }
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
                : BlocProvider(
                    create: (_) => getIt<DuaBloc>(),
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
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final reasons = ['wrong_translation', 'inappropriate', 'duplicate', 'spam', 'other'];
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                        builder: (ctx) => _DetailReportSheet(
                          title: _dua!.title,
                          reasons: reasons,
                          onSubmit: (reason, desc) {
                                            context.read<DuaBloc>().add(ReportDua(_dua!.id, reason, desc));
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Report submitted')),
                                            );
                                          },
                                        ),
                                      );
                                    },
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
