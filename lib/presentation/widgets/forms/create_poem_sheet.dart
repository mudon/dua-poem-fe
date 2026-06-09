import 'package:flutter/material.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/errors/error_helper.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/tag_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/poem_service.dart';
import '../../../data/services/tag_service.dart';
import '../../blocs/poem_bloc/poem_bloc.dart';
import '../../blocs/poem_bloc/poem_event.dart';

class CreatePoemSheet extends StatefulWidget {
  final VoidCallback? onCreated;
  final VoidCallback? onBack;

  const CreatePoemSheet({super.key, this.onCreated, this.onBack});

  @override
  State<CreatePoemSheet> createState() => _CreatePoemSheetState();
}

class _CreatePoemSheetState extends State<CreatePoemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _transliterationCtrl = TextEditingController();
  final _translationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  CategoryModel? _selectedCategory;
  final Set<int> _selectedTagIds = {};
  List<CategoryModel> _categories = [];
  List<TagModel> _tags = [];
  bool _loadingCategories = true;
  bool _loadingTags = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loadingCategories = false; _loadingTags = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.userMessage), backgroundColor: Colors.red[400] ?? Colors.red));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'transliteration': _transliterationCtrl.text.trim().isEmpty ? null : _transliterationCtrl.text.trim(),
        'translation': _translationCtrl.text.trim().isEmpty ? null : _translationCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        'author': _authorCtrl.text.trim().isEmpty ? null : _authorCtrl.text.trim(),
      };
      if (_selectedCategory != null) data['categoryId'] = _selectedCategory!.id;
      if (_selectedTagIds.isNotEmpty) data['tagIds'] = _selectedTagIds.toList();
      await getIt<PoemService>().createPoem(data);
      getIt<PoemBloc>().add(PoemCreated());
      if (mounted) {
        widget.onCreated?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poem published')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.userMessage), backgroundColor: Colors.red[400] ?? Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
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
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    _buildSection('Title *', _titleCtrl, required: true),
                    _buildSection('Content *', _contentCtrl, required: true, maxLines: 6),
                    _buildSection('Transliteration', _transliterationCtrl),
                    _buildSection('Translation', _translationCtrl, maxLines: 3),
                    _buildSection('Description', _descriptionCtrl, maxLines: 3),
                    _buildSection('Author', _authorCtrl),
                    _buildCategoryDropdown(),
                    _buildTagsSection(),
                  ],
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
          if (widget.onBack != null)
            IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.earthBrown), onPressed: widget.onBack)
          else
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.warmGray, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          const Expanded(child: Text('New Poem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.earthBrown))),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.earthBrown), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _buildSection(String label, TextEditingController ctrl, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppTheme.softCream,
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
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

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
        child: _submitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Create Poem', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _transliterationCtrl.dispose();
    _translationCtrl.dispose();
    _descriptionCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }
}
