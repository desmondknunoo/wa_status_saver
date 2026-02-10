import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/status_provider.dart';
import '../widgets/status_grid.dart';
import '../widgets/empty_state.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Saved Statuses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF128C7E), Color(0xFF075E54)],
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (provider.savedStatuses.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded),
                      tooltip: 'Clear all',
                      onPressed: () => _showClearAllDialog(context, provider),
                    ),
                ],
              ),
            ];
          },
          body: _buildBody(context, provider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StatusProvider provider) {
    if (provider.savedStatuses.isEmpty) {
      return const EmptyState(
        icon: Icons.download_done_rounded,
        title: 'No Saved Statuses',
        subtitle:
            'Statuses you save will appear here.\nTap on a status and hit the save button.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshAllStatuses(),
      color: const Color(0xFF25D366),
      child: Column(
        children: [
          _buildStatsCard(context, provider),
          Expanded(
            child: StatusGrid(
              statuses: provider.savedStatuses,
              isSavedView: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, StatusProvider provider) {
    final imageCount = provider.savedStatuses.where((s) => s.isImage).length;
    final videoCount = provider.savedStatuses.where((s) => s.isVideo).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF25D366).withValues(alpha: 0.2),
            const Color(0xFF128C7E).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF25D366).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, Icons.image_rounded, 'Images', imageCount),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          _buildStatItem(context, Icons.videocam_rounded, 'Videos', videoCount),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            context,
            Icons.folder_rounded,
            'Total',
            provider.savedCount,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    int count,
  ) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF25D366), size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showClearAllDialog(BuildContext context, StatusProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Clear All Saved'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all saved statuses? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              for (final status in provider.savedStatuses.toList()) {
                await provider.deleteStatus(status);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All saved statuses deleted'),
                    backgroundColor: Color(0xFF25D366),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
