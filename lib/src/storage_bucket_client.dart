import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import 'models/api_credentials.dart';
import 'models/bucket_file.dart';
import 'models/upload_response.dart';
import 'models/files_list_response.dart';
import 'models/delete_response.dart';
import 'exceptions/storage_bucket_exception.dart';
import 'utils/file_utils.dart';

/// Main client for interacting with storage bucket API
class StorageBucketClient {
  /// Creates a new StorageBucketClient with the given credentials
  StorageBucketClient(this.credentials) {
    if (!credentials.isValid) {
      throw StorageBucketException.validationError('Invalid API credentials');
    }

    _dio = Dio(BaseOptions(
      baseUrl: '${credentials.baseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Authorization': credentials.authorizationHeader,
        'Accept': 'application/json',
        // Add CORS-friendly headers
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, DELETE, PUT, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept, Authorization',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add CORS preflight handling for web
        if (options.method.toUpperCase() == 'OPTIONS') {
          handler.next(options);
          return;
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Enhanced CORS error detection
        if (error.type == DioExceptionType.connectionError ||
            error.message?.contains('CORS') == true ||
            error.message?.contains('Cross-Origin') == true ||
            error.message?.contains('Access-Control') == true) {
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: StorageBucketException(
              'CORS Error: The server does not allow cross-origin requests from this domain. '
              'Please configure CORS headers on your storage bucket server or use a native app instead of web.',
              statusCode: 0,
              originalError: error.error,
            ),
          ));
          return;
        }
        handler.next(_handleDioError(error));
      },
    ));
  }

  /// API credentials
  final ApiCredentials credentials;
  
  /// Dio instance for HTTP requests
  late final Dio _dio;

  /// Tests the connection to the API server
  /// 
  /// This method performs a simple ping to check if the server is reachable
  /// and properly configured for CORS (when running on web)
  Future<bool> testConnection() async {
    try {
      // Try a simple GET request to the files endpoint with minimal parameters
      await _dio.get(
        '/files.php',
        queryParameters: {
          'bucket_id': '1',
          'limit': '1',
        },
        options: Options(
          validateStatus: (status) {
            // Accept any status code for connection test
            return status != null && status < 500;
          },
        ),
      );
      
      // If we get here, the connection works (regardless of auth)
      return true;
    } on DioException catch (e) {
      if (e.error is StorageBucketException) {
        final sbException = e.error as StorageBucketException;
        if (sbException.message.contains('CORS')) {
          rethrow; // Re-throw CORS errors
        }
      }
      
      // For connection test, some errors are acceptable (like 401, 403)
      // We just want to know if we can reach the server
      if (e.response?.statusCode != null) {
        return true; // Server is reachable
      }
      
      throw StorageBucketException.networkError(
        'Cannot connect to server: ${e.message}'
      );
    } catch (e) {
      throw StorageBucketException.networkError(
        'Connection test failed: $e'
      );
    }
  }

  /// Uploads a file to the specified bucket
  /// 
  /// [bucketId] - ID of the target bucket
  /// [filePath] - Path to the file to upload
  /// [onUploadProgress] - Optional callback for upload progress
  Future<UploadResponse> uploadFile(
    int bucketId,
    String filePath, {
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    try {
      // Validate file exists
      if (!FileUtils.fileExists(filePath)) {
        throw StorageBucketException.validationError('File does not exist: $filePath');
      }

      final fileName = FileUtils.getFileName(filePath);
      final mimeType = FileUtils.getMimeType(filePath);

      final formData = FormData.fromMap({
        'bucket_id': bucketId.toString(),
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
        ),
      });

      final response = await _dio.post(
        '/upload.php',
        data: formData,
        onSendProgress: onUploadProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return UploadResponse.fromJson(response.data);
    } catch (e) {
      if (e is StorageBucketException) rethrow;
      throw StorageBucketException.networkError('Upload failed: $e');
    }
  }

  /// Uploads a file from bytes
  /// 
  /// [bucketId] - ID of the target bucket
  /// [fileName] - Name for the uploaded file
  /// [fileBytes] - File content as bytes
  /// [mimeType] - MIME type of the file (optional)
  /// [onUploadProgress] - Optional callback for upload progress
  Future<UploadResponse> uploadFileFromBytes(
    int bucketId,
    String fileName,
    Uint8List fileBytes, {
    String? mimeType,
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    try {
      final sanitizedFileName = FileUtils.sanitizeFileName(fileName);
      final detectedMimeType = mimeType ?? FileUtils.getMimeType(fileName);

      final formData = FormData.fromMap({
        'bucket_id': bucketId.toString(),
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: sanitizedFileName,
          contentType: detectedMimeType != null ? DioMediaType.parse(detectedMimeType) : null,
        ),
      });

      final response = await _dio.post(
        '/upload.php',
        data: formData,
        onSendProgress: onUploadProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return UploadResponse.fromJson(response.data);
    } catch (e) {
      if (e is StorageBucketException) rethrow;
      throw StorageBucketException.networkError('Upload failed: $e');
    }
  }

  /// Lists files in a bucket with pagination and filtering options
  /// 
  /// [bucketId] - ID of the bucket to list files from
  /// [page] - Page number (default: 1)
  /// [limit] - Number of files per page (default: 20, max: 100)
  /// [search] - Search query for file names (optional)
  /// [mimeTypeFilter] - Filter by MIME type prefix (optional, e.g. 'image/')
  Future<FilesListResponse> listFiles(
    int bucketId, {
    int page = 1,
    int limit = 20,
    String? search,
    String? mimeTypeFilter,
  }) async {
    try {
      if (limit > 100) {
        throw StorageBucketException.validationError('Limit cannot exceed 100');
      }

      final queryParams = <String, dynamic>{
        'bucket_id': bucketId.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (mimeTypeFilter != null && mimeTypeFilter.isNotEmpty) {
        queryParams['mime_type'] = mimeTypeFilter;
      }

      final response = await _dio.get(
        '/files.php',
        queryParameters: queryParams,
      );

      return FilesListResponse.fromJson(response.data);
    } catch (e) {
      if (e is StorageBucketException) rethrow;
      throw StorageBucketException.networkError('Failed to list files: $e');
    }
  }

  /// Downloads a file by its ID
  /// 
  /// [fileId] - ID of the file to download
  /// [savePath] - Path where to save the downloaded file (optional)
  /// [onDownloadProgress] - Optional callback for download progress
  /// 
  /// Returns the file bytes if no save path is provided, otherwise saves to the specified path
  Future<Uint8List?> downloadFile(
    int fileId, {
    String? savePath,
    void Function(int received, int total)? onDownloadProgress,
  }) async {
    try {
      final response = await _dio.get(
        '/download.php',
        queryParameters: {'file_id': fileId.toString()},
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onDownloadProgress,
      );

      final bytes = Uint8List.fromList(response.data);

      if (savePath != null) {
        final file = File(savePath);
        await file.writeAsBytes(bytes);
        return null;
      }

      return bytes;
    } catch (e) {
      if (e is StorageBucketException) rethrow;
      throw StorageBucketException.networkError('Download failed: $e');
    }
  }

  /// Downloads a file and saves it to the specified directory with the original filename
  /// 
  /// [file] - BucketFile object containing file information
  /// [saveDirectory] - Directory where to save the file
  /// [onDownloadProgress] - Optional callback for download progress
  /// 
  /// Returns the full path of the saved file
  Future<String> downloadFileToDirectory(
    BucketFile file,
    String saveDirectory, {
    void Function(int received, int total)? onDownloadProgress,
  }) async {
    final directory = Directory(saveDirectory);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final savePath = path.join(saveDirectory, file.fileName);
    await downloadFile(
      file.id,
      savePath: savePath,
      onDownloadProgress: onDownloadProgress,
    );

    return savePath;
  }

  /// Deletes a file by its ID
  /// 
  /// [fileId] - ID of the file to delete
  Future<DeleteResponse> deleteFile(int fileId) async {
    try {
      final response = await _dio.delete(
        '/delete.php',
        queryParameters: {'file_id': fileId.toString()},
      );

      return DeleteResponse.fromJson(response.data);
    } catch (e) {
      if (e is StorageBucketException) rethrow;
      throw StorageBucketException.networkError('Delete failed: $e');
    }
  }

  /// Gets file information by ID (same as downloading but only returns metadata)
  /// 
  /// [fileId] - ID of the file
  Future<BucketFile> getFileInfo(int fileId) async {
    try {
      // We can get file info by trying to download with head request
      final response = await _dio.head('/download.php?file_id=$fileId');
      
      // Extract file info from headers if available
      final contentDisposition = response.headers.value('content-disposition');
      
      if (contentDisposition != null) {
        // Check if we can extract filename, but don't assign to unused variable
        RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
      }

      // Since we can't get complete file info from HEAD request alone,
      // we need to implement this properly by extending the API or using a different approach
      throw const StorageBucketException('getFileInfo requires additional API endpoint implementation');
    } catch (e) {
      if (e is StorageBucketException) rethrow;
      throw StorageBucketException.networkError('Failed to get file info: $e');
    }
  }

  /// Handles Dio errors and converts them to StorageBucketExceptions
  DioException _handleDioError(DioException error) {
    final response = error.response;
    
    if (response != null) {
      final statusCode = response.statusCode;
      String message = 'Request failed';
      
      // Try to extract error message from response
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        message = data['message'] ?? message;
      }

      switch (statusCode) {
        case 400:
          throw StorageBucketException.validationError(message);
        case 401:
          throw StorageBucketException.unauthorized(message);
        case 403:
          throw StorageBucketException.forbidden(message);
        case 404:
          throw StorageBucketException.notFound(message);
        case 429:
          throw StorageBucketException.rateLimitExceeded(message);
        case 500:
        case 502:
        case 503:
        case 504:
          throw StorageBucketException.serverError(message);
        default:
          throw StorageBucketException(message, statusCode: statusCode);
      }
    }

    throw StorageBucketException.networkError(error.message ?? 'Unknown network error');
  }

  /// Closes the client and releases resources
  void close() {
    _dio.close();
  }
} 