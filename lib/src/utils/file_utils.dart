import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

/// Utility class for file operations
class FileUtils {
  /// Gets the MIME type of a file
  static String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  /// Gets the file extension from a file path
  static String getFileExtension(String filePath) {
    return path.extension(filePath);
  }

  /// Gets the file name from a file path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Gets the file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Validates if a file exists
  static bool fileExists(String filePath) {
    final file = File(filePath);
    return file.existsSync();
  }

  /// Gets the file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// Formats file size in human-readable format
  static String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(size == size.toInt() ? 0 : 1)} ${units[unitIndex]}';
  }

  /// Validates if a file type is allowed based on MIME type
  static bool isAllowedFileType(String filePath, List<String> allowedMimeTypes) {
    final mimeType = getMimeType(filePath);
    if (mimeType == null) return false;
    
    return allowedMimeTypes.any(mimeType.startsWith);
  }

  /// Checks if a file is an image
  static bool isImage(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('image/') ?? false;
  }

  /// Checks if a file is a video
  static bool isVideo(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('video/') ?? false;
  }

  /// Checks if a file is an audio file
  static bool isAudio(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('audio/') ?? false;
  }

  /// Checks if a file is a document
  static bool isDocument(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('application/') ?? 
           mimeType?.startsWith('text/') ?? 
           false;
  }

  /// Sanitizes a file name by removing/replacing invalid characters
  static String sanitizeFileName(String fileName) {
    // Replace invalid characters with underscores
    const invalidChars = r'<>:"/\|?*';
    String sanitized = fileName;
    
    for (int i = 0; i < invalidChars.length; i++) {
      sanitized = sanitized.replaceAll(invalidChars[i], '_');
    }
    
    // Remove leading/trailing dots and spaces
    sanitized = sanitized.trim().replaceAll(RegExp(r'^\.+|\.+$'), '');
    
    // Ensure the name is not empty
    if (sanitized.isEmpty) {
      sanitized = 'unnamed_file';
    }
    
    return sanitized;
  }
} 