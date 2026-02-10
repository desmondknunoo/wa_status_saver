import 'dart:io';
import 'package:flutter/material.dart';
import '../models/status_model.dart';
import '../screens/status_viewer_screen.dart';

class StatusGrid extends StatelessWidget {
  final List<StatusModel> statuses;
  final bool isSavedView;

  const StatusGrid({
    super.key,
    required this.statuses,
    this.isSavedView = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        return StatusGridItem(
          status: statuses[index],
          onTap: () => _openStatusViewer(context, index),
          isSavedView: isSavedView,
        );
      },
    );
  }

  void _openStatusViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StatusViewerScreen(
              statuses: statuses,
              initialIndex: initialIndex,
              isSavedView: isSavedView,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class StatusGridItem extends StatelessWidget {
  final StatusModel status;
  final VoidCallback onTap;
  final bool isSavedView;

  const StatusGridItem({
    super.key,
    required this.status,
    required this.onTap,
    this.isSavedView = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildThumbnail(),
              _buildGradientOverlay(),
              _buildInfoOverlay(),
              if (status.isVideo) _buildVideoIndicator(),
              if (isSavedView) _buildSavedBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (status.isImage) {
      return Image.file(
        File(status.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
      );
    } else {
      // For videos, show placeholder with gradient
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF25D366).withValues(alpha: 0.3),
              const Color(0xFF128C7E).withValues(alpha: 0.5),
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.videocam_rounded, size: 48, color: Colors.white54),
        ),
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            status.timeAgoFormatted,
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.formattedSize,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      ),
    );
  }
}
