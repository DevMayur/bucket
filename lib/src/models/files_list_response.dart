import 'bucket_file.dart';
import 'pagination.dart';

/// Information about a bucket
class BucketInfo {
  /// Bucket ID
  final int id;
  
  /// Bucket name
  final String name;
  
  /// Project name
  final String projectName;

  const BucketInfo({
    required this.id,
    required this.name,
    required this.projectName,
  });

  /// Creates a BucketInfo from JSON data
  factory BucketInfo.fromJson(Map<String, dynamic> json) {
    return BucketInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      projectName: json['project_name'] as String,
    );
  }

  /// Converts the BucketInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'project_name': projectName,
    };
  }

  @override
  String toString() {
    return 'BucketInfo(id: $id, name: $name, projectName: $projectName)';
  }
}

/// Response model for file listing operations
class FilesListResponse {
  /// Whether the request was successful
  final bool success;
  
  /// Response message
  final String message;
  
  /// List of files
  final List<BucketFile> files;
  
  /// Pagination information
  final Pagination pagination;
  
  /// Bucket information
  final BucketInfo bucket;

  const FilesListResponse({
    required this.success,
    required this.message,
    required this.files,
    required this.pagination,
    required this.bucket,
  });

  /// Creates a FilesListResponse from JSON data
  factory FilesListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return FilesListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      files: (data['files'] as List)
          .map((file) => BucketFile.fromJson(file))
          .toList(),
      pagination: Pagination.fromJson(data['pagination']),
      bucket: BucketInfo.fromJson(data['bucket']),
    );
  }

  /// Converts the FilesListResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'files': files.map((file) => file.toJson()).toList(),
        'pagination': pagination.toJson(),
        'bucket': bucket.toJson(),
      },
    };
  }

  @override
  String toString() {
    return 'FilesListResponse(success: $success, filesCount: ${files.length}, pagination: $pagination)';
  }
} 