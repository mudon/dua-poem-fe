import 'package:flutter/material.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/tag_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/dua_service.dart';
import '../../../data/services/tag_service.dart';

class CreateDuaSheet extends StatefulWidget {
  final VoidCallback? onCreated;

  const CreateDuaSheet({super.key, this.onCreated});

  @override
  State<CreateDuaSheet> createState() => _CreateDuaSheetState();
}

class _CreateDuaSheetState extends State<CreateDuaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _arabicCtrl = TextEditingController();
  final _transliterationCtrl = TextEditingController();
  final _translationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _whenToReciteCtrl = TextEditingController();
  final _occasionCtrl = TextEditingController();
  int _repetitionCount = 1;
  final _repetitionCtrl = TextEditingController(text: '1');
  CategoryModel? _selectedCategory;
  final Set<int> _selectedTagIds = {};
  List<CategoryModel> _categories = [];
  List<TagModel> _tags = [];
  bool _loadingCategories = true;
  bool _loadingTags = true;
  bool _submitting = false;

  final List<_SourceEntry> _sources = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _repetitionCtrl.addListener(_onRepetitionChanged);
  }

  void _onRepetitionChanged() {
    final v = int.tryParse(_repetitionCtrl.text);
    if (v != null && v >= 1) {
      _repetitionCount = v;
    }
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
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loadingCategories = false; _loadingTags = false; });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'arabicText': _arabicCtrl.text.trim(),
        'transliteration': _transliterationCtrl.text.trim().isEmpty ? null : _transliterationCtrl.text.trim(),
        'translation': _translationCtrl.text.trim().isEmpty ? null : _translationCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        'whenToRecite': _whenToReciteCtrl.text.trim().isEmpty ? null : _whenToReciteCtrl.text.trim(),
        'occasion': _occasionCtrl.text.trim().isEmpty ? null : _occasionCtrl.text.trim(),
        'repetitionCount': _repetitionCount,
      };
      if (_selectedCategory != null) data['categoryId'] = _selectedCategory!.id;
      if (_selectedTagIds.isNotEmpty) data['tagIds'] = _selectedTagIds.toList();
      if (_sources.isNotEmpty) {
        data['sources'] = _sources
            .where((s) => s.type.isNotEmpty)
            .map((s) => {
              'sourceType': s.type,
              'reference': s.reference.text.trim(),
              'details': s.details.text.trim(),
            })
            .toList();
      }
      await getIt<DuaService>().createDua(data);
      if (mounted) {
        widget.onCreated?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dua published')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F0E8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      _buildSection('Title *', _titleCtrl, required: true),
                      _buildSection('Arabic Text *', _arabicCtrl, required: true, maxLines: 4, textDirection: TextDirection.rtl),
                      _buildSection('Transliteration', _transliterationCtrl),
                      _buildSection('Translation', _translationCtrl, maxLines: 3),
                      _buildSection('Description', _descriptionCtrl, maxLines: 3),
                      _buildSection('When to Recite', _whenToReciteCtrl),
                      _buildSection('Occasion', _occasionCtrl),
                      _buildRepetitionCount(),
                      _buildCategoryDropdown(),
                      _buildTagsSection(),
                      _buildSourcesSection(),
                    ],
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.warmGray, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          const Expanded(child: Text('New Dua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.earthBrown))),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.earthBrown), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _buildSection(String label, TextEditingController ctrl, {bool required = false, int maxLines = 1, TextDirection textDirection = TextDirection.ltr}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        textDirection: textDirection,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppTheme.softCream,
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
      ),
    );
  }

  Widget _buildRepetitionCount() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Text('Repetition Count', style: TextStyle(fontSize: 15, color: AppTheme.earthBrown)),
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
            child: TextFormField(
              controller: _repetitionCtrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                filled: true,
                fillColor: AppTheme.softCream,
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
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<CategoryModel>(
            initialValue: _selectedCategory,
        decoration: const InputDecoration(labelText: 'Category', filled: true, fillColor: AppTheme.softCream),
        items: _loadingCategories
            ? [DropdownMenuItem(value: null, child: Text('Loading...', style: TextStyle(color: AppTheme.earthBrown.withValues(alpha: 0.6))))]
            : _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tags', style: TextStyle(fontSize: 15, color: AppTheme.earthBrown)),
          const SizedBox(height: 8),
          _loadingTags
              ? const Text('Loading...', style: TextStyle(color: AppTheme.earthBrown))
              : Wrap(
                  spacing: 8, runSpacing: 6,
                  children: _tags.map((t) => FilterChip(
                    label: Text(t.name),
                    selected: _selectedTagIds.contains(t.id),
                    selectedColor: AppTheme.sageMist,
                    checkmarkColor: AppTheme.sage,
                    onSelected: (sel) {
                      setState(() {
                        if (sel) { _selectedTagIds.add(t.id); } else { _selectedTagIds.remove(t.id); }
                      });
                    },
                  )).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Sources', style: TextStyle(fontSize: 15, color: AppTheme.earthBrown)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => _sources.add(_SourceEntry())),
              icon: const Icon(Icons.add, size: 18, color: AppTheme.sage),
              label: const Text('Add Source', style: TextStyle(color: AppTheme.sage)),
            ),
          ],
        ),
        ..._sources.asMap().entries.map((entry) => _buildSourceCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildSourceCard(int index, _SourceEntry entry) {
    return Card(
      color: AppTheme.softCream,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Source ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.earthBrown)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppTheme.errorRed),
                  onPressed: () => setState(() => _sources.removeAt(index)),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: entry.type.isEmpty ? null : entry.type,
              decoration: const InputDecoration(labelText: 'Type', isDense: true, filled: true, fillColor: AppTheme.softCream),
              items: ['quran', 'hadith', 'scholar', 'other'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => entry.type = v ?? '',
            ),
            const SizedBox(height: 8),
            TextFormField(controller: entry.reference, decoration: const InputDecoration(labelText: 'Reference', isDense: true, filled: true, fillColor: AppTheme.softCream)),
            const SizedBox(height: 8),
            TextFormField(controller: entry.details, decoration: const InputDecoration(labelText: 'Details', isDense: true, filled: true, fillColor: AppTheme.softCream)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
        child: _submitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Create Dua', style: TextStyle(fontSize: 16)),
      ),
    );
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
    for (final s in _sources) { s.reference.dispose(); s.details.dispose(); }
    super.dispose();
  }
}

class _SourceEntry {
  String type = '';
  final reference = TextEditingController();
  final details = TextEditingController();
}
