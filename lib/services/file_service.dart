import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/status_model.dart';

/// Service for handling file operations including saving, deleting, and managing status files.
class FileService {
  static const String saveDirectoryName = 'StatusSaver';

  /// Returns the app's dedicated save directory in Pictures folder.
  ///
  /// Creates the directory if it doesn't exist. Path: Pictures/StatusSaver/
  /// Throws exception if external storage is not available.
  Future<Directory> getSaveDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('External storage not available');
    }

    // Navigate up to find Pictures folder
    final picturesPath =
        '${directory.parent.parent.parent.parent.path}/Pictures/$saveDirectoryName';
    final saveDir = Directory(picturesPath);

    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    return saveDir;
  }

  /// Saves a status file to the app's dedicated folder.
  ///
  /// Process:
  /// 1. Verifies source file exists
  /// 2. Generates timestamp-based unique filename
  /// 3. Copies file to Pictures/StatusSaver directory
  ///
  /// Returns true on success, false on failure.
  Future<bool> saveStatus(StatusModel status) async {
    try {
      final file = File(status.path);
      if (!await file.exists()) {
        return false;
      }

      final saveDir = await getSaveDirectory();

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = status.extension;
      final fileName = 'status_$timestamp.$extension';
      final savePath = '${saveDir.path}/$fileName';

      // Copy file to save directory
      await file.copy(savePath);

      return true;
    } catch (e) {
      debugPrint('Error saving status: $e');
      return false;
    }
  }

  /// Get list of saved statuses from the app's save directory
  Future<List<StatusModel>> getSavedStatuses() async {
    final List<StatusModel> savedStatuses = [];

    try {
      final saveDir = await getSaveDirectory();

      if (!await saveDir.exists()) {
        return savedStatuses;
      }

      final files = saveDir.listSync();

      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          if (fileName.startsWith('.')) continue;

          final extension = fileName.split('.').last.toLowerCase();
          final stats = await file.stat();

          final status = StatusModel(
            path: file.path,
            type: StatusModel.getTypeFromExtension(extension),
            dateModified: stats.modified,
            size: stats.size,
            isSaved: true,
          );

          savedStatuses.add(status);
        }
      }

      savedStatuses.sort((a, b) => b.dateModified.compareTo(a.dateModified));
    } catch (e) {
      debugPrint('Error getting saved statuses: $e');
    }

    return savedStatuses;
  }

  /// Delete a saved status file
  Future<bool> deleteStatus(StatusModel status) async {
    try {
      final file = File(status.path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting status: $e');
      return false;
    }
  }

  /// Check if a status is already saved by comparing file sizes
  Future<bool> isStatusSaved(StatusModel status) async {
    try {
      final savedStatuses = await getSavedStatuses();
      final originalFileName = status.fileName;

      return savedStatuses.any(
        (saved) =>
            saved.fileName.contains(originalFileName) ||
            saved.size == status.size,
      );
    } catch (e) {
      return false;
    }
  }
}

/// Debug print utility
void debugPrint(String message) {
  assert(() {
    // ignore: avoid_print
    print(message);
    return true;
  }());
}
