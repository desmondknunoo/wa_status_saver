import 'dart:io';

enum StatusType { image, video }

class StatusModel {
  final String path;
  final StatusType type;
  final DateTime dateModified;
  final int size;
  final bool isSaved;
  final String? thumbnailPath;

  StatusModel({
    required this.path,
    required this.type,
    required this.dateModified,
    required this.size,
    this.isSaved = false,
    this.thumbnailPath,
  });

  String get fileName => path.split('/').last;

  String get extension => fileName.split('.').last.toLowerCase();

  bool get isImage => type == StatusType.image;

  bool get isVideo => type == StatusType.video;

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Duration get timeAgo => DateTime.now().difference(dateModified);

  String get timeAgoFormatted {
    final duration = timeAgo;
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  StatusModel copyWith({
    String? path,
    StatusType? type,
    DateTime? dateModified,
    int? size,
    bool? isSaved,
    String? thumbnailPath,
  }) {
    return StatusModel(
      path: path ?? this.path,
      type: type ?? this.type,
      dateModified: dateModified ?? this.dateModified,
      size: size ?? this.size,
      isSaved: isSaved ?? this.isSaved,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  File get file => File(path);

  static StatusType getTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return StatusType.image;
    } else if (['mp4', 'mkv', 'avi', 'webm', '3gp'].contains(ext)) {
      return StatusType.video;
    }
    return StatusType.image;
  }
}
