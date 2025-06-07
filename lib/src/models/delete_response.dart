/// Information about a deleted file
class DeletedFileInfo {
  /// ID of the deleted file
  final int fileId;
  
  /// Name of the deleted file
  final String fileName;
  
  /// Name of the bucket containing the file
  final String bucketName;

  const DeletedFileInfo({
    required this.fileId,
    required this.fileName,
    required this.bucketName,
  });

  /// Creates a DeletedFileInfo from JSON data
  factory DeletedFileInfo.fromJson(Map<String, dynamic> json) {
    return DeletedFileInfo(
      fileId: json['file_id'] as int,
      fileName: json['file_name'] as String,
      bucketName: json['bucket_name'] as String,
    );
  }

  /// Converts the DeletedFileInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      'file_name': fileName,
      'bucket_name': bucketName,
    };
  }

  @override
  String toString() {
    return 'DeletedFileInfo(fileId: $fileId, fileName: $fileName, bucketName: $bucketName)';
  }
}

/// Response model for file deletion operations
class DeleteResponse {
  /// Whether the deletion was successful
  final bool success;
  
  /// Response message
  final String message;
  
  /// Information about the deleted file (if successful)
  final DeletedFileInfo? deletedFile;

  const DeleteResponse({
    required this.success,
    required this.message,
    this.deletedFile,
  });

  /// Creates a DeleteResponse from JSON data
  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      deletedFile: json['data'] != null 
          ? DeletedFileInfo.fromJson(json['data']) 
          : null,
    );
  }

  /// Converts the DeleteResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (deletedFile != null) 'data': deletedFile!.toJson(),
    };
  }

  @override
  String toString() {
    return 'DeleteResponse(success: $success, message: $message, deletedFile: $deletedFile)';
  }
} 