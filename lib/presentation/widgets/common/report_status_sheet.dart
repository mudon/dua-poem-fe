import 'package:flutter/material.dart';
import '../../../data/models/report_model.dart';

class ReportStatusSheet extends StatelessWidget {
  final List<ReportModel> reports;

  const ReportStatusSheet({super.key, required this.reports});

  static String _formatReason(String reason) {
    return reason.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFD68B2E);
      case 'fix_submitted': return const Color(0xFF4A7BBF);
      case 'resolved': return const Color(0xFF3F7849);
      case 'dismissed': return const Color(0xFF9A8C79);
      default: return const Color(0xFF9A8C79);
    }
  }

  static String _statusLabel(String status) {
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
