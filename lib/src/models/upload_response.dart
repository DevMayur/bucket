import 'bucket_file.dart';

/// Response model for file upload operations
class UploadResponse {
  const UploadResponse({
    required this.success,
    required this.message,
    this.file,
  });

  /// Creates an UploadResponse from JSON data
  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      file: json['data'] != null ? BucketFile.fromJson(json['data']) : null,
    );
  }

  /// Whether the upload was successful
  final bool success;
  
  /// Response message
  final String message;
  
  /// The uploaded file data (if successful)
  final BucketFile? file;

  /// Converts the UploadResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (file != null) 'data': file!.toJson(),
    };
  }

  @override
  String toString() {
    return 'UploadResponse(success: $success, message: $message, file: $file)';
  }
} 