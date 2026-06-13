import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/constants/route_paths.dart';
import '../../../core/enums/content_type.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/services/admin_service.dart';
import '../../blocs/admin_bloc/admin_bloc.dart';
import '../../blocs/admin_bloc/admin_event.dart';
import '../../blocs/admin_bloc/admin_state.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late final AdminBloc _adminBloc;

  @override
  void initState() {
    super.initState();
    _adminBloc = AdminBloc(AdminRepository(getIt<AdminService>()));
    _adminBloc.add(LoadPendingRevisions());
  }

  @override
  void dispose() {
    _adminBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _adminBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin — Pending Revisions'),
          backgroundColor: const Color(0xFFFEFCF7),
          surfaceTintColor: Colors.transparent,
        ),
        backgroundColor: const Color(0xFFFEFCF7),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state.reviewSuccess != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.reviewSuccess!), backgroundColor: const Color(0xFF3F7849)),
              );
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!), backgroundColor: const Color(0xFFD9534F)),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.revisions.isEmpty) {
              return const Center(
                child: Text(
                  'No pending revisions',
                  style: TextStyle(color: Color(0xFF9A8C79), fontSize: 15),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _adminBloc.add(LoadPendingRevisions()),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.revisions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final rev = state.revisions[i];
                  return _RevisionCard(
                    revision: rev,
                    onTap: () => context.push(
                      RoutePaths.adminRevision,
                      extra: {
                        'revisionId': rev.id,
                        'contentType': rev.contentType.value,
                        'contentTitle': rev.contentTitle,
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RevisionCard extends StatelessWidget {
  final dynamic revision;
  final VoidCallback onTap;

  const _RevisionCard({required this.revision, required this.onTap});

  String _formatReason(String reason) {
    return reason.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = revision.contentType == ContentType.dua ? 'Dua' : 'Poem';
    final typeColor = revision.contentType == ContentType.dua
        ? const Color(0xFF4A7BBF)
        : const Color(0xFF8B5BAE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEFE8DE)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(typeLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: typeColor)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(revision.contentTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFAB9F8E), size: 20),
              ],
            ),
            const SizedBox(height: 8),
            if (revision.submitterName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('by ${revision.submitterName}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7A6B5A))),
              ),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (revision.reports as List).map<Widget>((r) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD68B2E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(_formatReason(r.reason),
                    style: const TextStyle(fontSize: 11, color: Color(0xFFD68B2E), fontWeight: FontWeight.w500)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
