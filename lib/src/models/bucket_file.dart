/// Represents a file stored in a storage bucket
class BucketFile {
  /// Unique ID of the file
  final int id;
  
  /// Name of the file
  final String fileName;
  
  /// Size of the file in bytes
  final int fileSize;
  
  /// MIME type of the file
  final String mimeType;
  
  /// When the file was uploaded
  final DateTime uploadedAt;
  
  /// ID of the bucket containing this file
  final int bucketId;
  
  /// Name of the bucket (optional)
  final String? bucketName;
  
  /// Name of the project (optional)
  final String? projectName;
  
  /// Download URL for the file (optional)
  final String? downloadUrl;

  const BucketFile({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
    required this.bucketId,
    this.bucketName,
    this.projectName,
    this.downloadUrl,
  });

  /// Creates a BucketFile from JSON data
  factory BucketFile.fromJson(Map<String, dynamic> json) {
    return BucketFile(
      id: json['id'] as int,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      mimeType: json['mime_type'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      bucketId: json['bucket_id'] as int,
      bucketName: json['bucket_name'] as String?,
      projectName: json['project_name'] as String?,
      downloadUrl: json['download_url'] as String?,
    );
  }

  /// Converts the BucketFile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'uploaded_at': uploadedAt.toIso8601String(),
      'bucket_id': bucketId,
      if (bucketName != null) 'bucket_name': bucketName,
      if (projectName != null) 'project_name': projectName,
      if (downloadUrl != null) 'download_url': downloadUrl,
    };
  }

  /// Returns the file size in a human-readable format
  String get humanReadableSize {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = fileSize.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(size == size.toInt() ? 0 : 1)} ${units[unitIndex]}';
  }

  /// Returns true if the file is an image
  bool get isImage => mimeType.startsWith('image/');
  
  /// Returns true if the file is a video
  bool get isVideo => mimeType.startsWith('video/');
  
  /// Returns true if the file is audio
  bool get isAudio => mimeType.startsWith('audio/');
  
  /// Returns true if the file is a document
  bool get isDocument => mimeType.startsWith('application/') || mimeType.startsWith('text/');

  @override
  String toString() {
    return 'BucketFile(id: $id, fileName: $fileName, fileSize: $humanReadableSize, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BucketFile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 