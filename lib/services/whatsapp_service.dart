import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/status_model.dart';

enum WhatsAppType { whatsapp, whatsappBusiness }

class WhatsAppService {
  // Status directory paths for WhatsApp
  static const List<String> whatsappPaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
  ];

  // Status directory paths for WhatsApp Business
  static const List<String> whatsappBusinessPaths = [
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
  ];

  // Supported file extensions
  static const List<String> supportedExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', // Images
    'mp4', 'mkv', 'avi', 'webm', '3gp', // Videos
  ];

  /// Returns the first valid status directory for the specified WhatsApp type.
  ///
  /// Iterates through known paths for WhatsApp or WhatsApp Business and returns
  /// the first directory that exists on the device. Returns null if no valid
  /// directory is found (WhatsApp not installed or status folder doesn't exist).
  Future<Directory?> getStatusDirectory(WhatsAppType type) async {
    final paths = type == WhatsAppType.whatsapp
        ? whatsappPaths
        : whatsappBusinessPaths;

    for (final path in paths) {
      final directory = Directory(path);
      if (await directory.exists()) {
        return directory;
      }
    }
    return null;
  }

  /// Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled(WhatsAppType type) async {
    final directory = await getStatusDirectory(type);
    return directory != null;
  }

  /// Fetches all status files from the specified WhatsApp type directory.
  ///
  /// Algorithm:
  /// 1. Locates the status directory for the given WhatsApp type
  /// 2. Filters files by supported extensions (images/videos)
  /// 3. Excludes hidden files (.nomedia, etc.)
  /// 4. Creates StatusModel objects with file metadata
  /// 5. Sorts results by modification date (newest first)
  ///
  /// Returns an empty list if directory doesn't exist or access is denied.
  Future<List<StatusModel>> fetchStatuses(WhatsAppType type) async {
    final List<StatusModel> statuses = [];

    try {
      final directory = await getStatusDirectory(type);
      if (directory == null) {
        return statuses;
      }

      final files = directory.listSync();

      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;

          // Skip .nomedia files and hidden files
          if (fileName.startsWith('.')) continue;

          // Get file extension
          final extension = fileName.split('.').last.toLowerCase();

          // Check if file extension is supported
          if (!supportedExtensions.contains(extension)) continue;

          // Get file stats
          final stats = await file.stat();

          // Create status model
          final status = StatusModel(
            path: file.path,
            type: StatusModel.getTypeFromExtension(extension),
            dateModified: stats.modified,
            size: stats.size,
          );

          statuses.add(status);
        }
      }

      // Sort by date modified (newest first)
      statuses.sort((a, b) => b.dateModified.compareTo(a.dateModified));
    } catch (e) {
      debugPrint('Error fetching statuses: $e');
    }

    return statuses;
  }

  /// Get count of available statuses
  Future<int> getStatusCount(WhatsAppType type) async {
    final statuses = await fetchStatuses(type);
    return statuses.length;
  }

  /// Get image statuses only
  Future<List<StatusModel>> fetchImageStatuses(WhatsAppType type) async {
    final statuses = await fetchStatuses(type);
    return statuses.where((s) => s.isImage).toList();
  }

  /// Get video statuses only
  Future<List<StatusModel>> fetchVideoStatuses(WhatsAppType type) async {
    final statuses = await fetchStatuses(type);
    return statuses.where((s) => s.isVideo).toList();
  }
}
