import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/poem_model.dart';
import '../../core/themes/app_theme.dart';
import '../../data/repositories/poem_repository.dart';
import '../../app/dependency_injection.dart';

class PoemDetailScreen extends StatefulWidget {
  final int poemId;
  final UserModel currentUser;

  const PoemDetailScreen({super.key, required this.poemId, required this.currentUser});

  @override
  State<PoemDetailScreen> createState() => _PoemDetailScreenState();
}

class _PoemDetailScreenState extends State<PoemDetailScreen> {
  PoemModel? _poem;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPoem();
  }

  Future<void> _loadPoem() async {
    final repo = getIt<PoemRepository>();
    final result = await repo.getPoemDetail(widget.poemId);
    if (mounted) {
      setState(() {
        _poem = result.data;
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
            : _poem == null
                ? const Center(child: Text('Poem not found'))
                : SingleChildScrollView(
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
                              Text(_poem!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _poem!.verified ? const Color(0xFFE2F0DA) : const Color(0xFFFFF1E0),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  _poem!.verified ? '✓ Verified' : '⏳ Pending Review',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _poem!.verified ? const Color(0xFF3F7849) : const Color(0xFFC47D2E),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DetailField(label: 'Author', value: _poem!.userName),
                              if (_poem!.content != null && _poem!.content!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                DetailField(label: 'Poem text', value: _poem!.content!),
                              ],
                              if (_poem!.translation.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                DetailField(label: 'Translation', value: _poem!.translation),
                              ],
                              if (_poem!.tags.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text('Tags', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: _poem!.tags.map((t) => _TagPill(label: t)).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class DetailField extends StatelessWidget {
  const DetailField({super.key, required this.label, required this.value});
  final String label;
  final String value;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF3C3730), height: 1.4)),
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
