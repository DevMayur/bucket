# Flutter Storage Bucket

A comprehensive Flutter library for interacting with storage buckets using API keys. This library provides easy-to-use methods for uploading, downloading, listing, and managing files in your storage buckets.

## Features

- ✅ **File Upload**: Upload files from file paths or bytes with progress tracking
- ✅ **File Download**: Download files to disk or memory with progress tracking
- ✅ **File Listing**: List files with pagination, search, and filtering
- ✅ **File Deletion**: Delete files by ID
- ✅ **File Utilities**: Helper functions for file operations and validation
- ✅ **Error Handling**: Comprehensive error handling with custom exceptions
- ✅ **Progress Tracking**: Upload and download progress callbacks
- ✅ **Type Safety**: Full Dart null safety support
- ✅ **Async/Await**: Modern async programming patterns

## Installation

Add this library to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_storage_bucket: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter_storage_bucket/flutter_storage_bucket.dart';

// Initialize the client
final credentials = ApiCredentials(
  apiKey: 'sk_your_api_key_here',
  apiSecret: 'your_api_secret_here',
  baseUrl: 'https://your-server.com',
);

final client = StorageBucketClient(credentials);

// Upload a file
final uploadResponse = await client.uploadFile(
  123, // bucket ID
  '/path/to/file.pdf',
);

if (uploadResponse.success) {
  print('File uploaded: ${uploadResponse.file?.fileName}');
}

// List files
final filesResponse = await client.listFiles(123);
for (final file in filesResponse.files) {
  print('${file.fileName} - ${file.humanReadableSize}');
}

// Don't forget to close the client
client.close();
```

## API Reference

### StorageBucketClient

The main client class for interacting with the storage bucket API.

#### Constructor

```dart
StorageBucketClient(ApiCredentials credentials)
```

#### Methods

##### Upload Operations

**uploadFile**
```dart
Future<UploadResponse> uploadFile(
  int bucketId,
  String filePath, {
  void Function(int sent, int total)? onUploadProgress,
})
```

Upload a file from a file path.

**uploadFileFromBytes**
```dart
Future<UploadResponse> uploadFileFromBytes(
  int bucketId,
  String fileName,
  Uint8List fileBytes, {
  String? mimeType,
  void Function(int sent, int total)? onUploadProgress,
})
```

Upload a file from bytes.

##### List Operations

**listFiles**
```dart
Future<FilesListResponse> listFiles(
  int bucketId, {
  int page = 1,
  int limit = 20,
  String? search,
  String? mimeTypeFilter,
})
```

List files in a bucket with pagination and filtering.

##### Download Operations

**downloadFile**
```dart
Future<Uint8List?> downloadFile(
  int fileId, {
  String? savePath,
  void Function(int received, int total)? onDownloadProgress,
})
```

Download a file by ID. Returns bytes if no save path is provided.

**downloadFileToDirectory**
```dart
Future<String> downloadFileToDirectory(
  BucketFile file,
  String saveDirectory, {
  void Function(int received, int total)? onDownloadProgress,
})
```

Download a file to a specific directory with the original filename.

##### Delete Operations

**deleteFile**
```dart
Future<DeleteResponse> deleteFile(int fileId)
```

Delete a file by its ID.

### Models

#### ApiCredentials

```dart
class ApiCredentials {
  final String apiKey;
  final String apiSecret;
  final String baseUrl;
  
  const ApiCredentials({
    required this.apiKey,
    required this.apiSecret,
    required this.baseUrl,
  });
}
```

#### BucketFile

```dart
class BucketFile {
  final int id;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final DateTime uploadedAt;
  final int bucketId;
  final String? bucketName;
  final String? projectName;
  final String? downloadUrl;
  
  // Utility getters
  String get humanReadableSize;
  bool get isImage;
  bool get isVideo;
  bool get isAudio;
  bool get isDocument;
}
```

#### UploadResponse

```dart
class UploadResponse {
  final bool success;
  final String message;
  final BucketFile? file;
}
```

#### FilesListResponse

```dart
class FilesListResponse {
  final bool success;
  final String message;
  final List<BucketFile> files;
  final Pagination pagination;
  final BucketInfo bucket;
}
```

#### DeleteResponse

```dart
class DeleteResponse {
  final bool success;
  final String message;
  final DeletedFileInfo? deletedFile;
}
```

### File Utilities

The `FileUtils` class provides helpful static methods for file operations:

```dart
// Get file information
String fileName = FileUtils.getFileName('/path/to/file.pdf');
String extension = FileUtils.getFileExtension('/path/to/file.pdf');
String? mimeType = FileUtils.getMimeType('/path/to/file.pdf');

// File type checking
bool isImage = FileUtils.isImage('/path/to/image.jpg');
bool isVideo = FileUtils.isVideo('/path/to/video.mp4');
bool isDocument = FileUtils.isDocument('/path/to/doc.pdf');

// File validation
bool exists = await FileUtils.fileExists('/path/to/file.pdf');
int size = await FileUtils.getFileSize('/path/to/file.pdf');
String formattedSize = FileUtils.formatFileSize(1024000); // "1.0 MB"

// File name sanitization
String safe = FileUtils.sanitizeFileName('unsafe<file>name.txt');

// File type validation
List<String> allowed = ['image/', 'application/pdf'];
bool isAllowed = FileUtils.isAllowedFileType('/path/to/file.pdf', allowed);
```

### Exception Handling

The library uses custom exceptions for better error handling:

```dart
try {
  await client.uploadFile(123, '/path/to/file.pdf');
} catch (e) {
  if (e is StorageBucketException) {
    print('Error: ${e.message}');
    print('Status code: ${e.statusCode}');
    
    // Handle specific error types
    switch (e.statusCode) {
      case 401:
        print('Authentication failed');
        break;
      case 403:
        print('Insufficient permissions');
        break;
      case 404:
        print('File or bucket not found');
        break;
      case 429:
        print('Rate limit exceeded');
        break;
    }
  }
}
```

## Examples

### Basic Upload and Download

```dart
import 'package:flutter_storage_bucket/flutter_storage_bucket.dart';

final client = StorageBucketClient(ApiCredentials(
  apiKey: 'sk_your_key',
  apiSecret: 'your_secret',
  baseUrl: 'https://your-server.com',
));

// Upload with progress tracking
final uploadResponse = await client.uploadFile(
  123,
  '/path/to/document.pdf',
  onUploadProgress: (sent, total) {
    print('Progress: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);

if (uploadResponse.success && uploadResponse.file != null) {
  final file = uploadResponse.file!;
  
  // Download the file
  await client.downloadFile(
    file.id,
    savePath: '/downloads/${file.fileName}',
    onDownloadProgress: (received, total) {
      print('Download: ${(received / total * 100).toStringAsFixed(1)}%');
    },
  );
}

client.close();
```

### Listing and Filtering Files

```dart
// List all images in a bucket
final response = await client.listFiles(
  123,
  mimeTypeFilter: 'image/',
  limit: 50,
);

for (final file in response.files) {
  if (file.isImage) {
    print('Image: ${file.fileName} (${file.humanReadableSize})');
  }
}

// Search for specific files
final searchResponse = await client.listFiles(
  123,
  search: 'report',
  page: 1,
  limit: 10,
);

print('Found ${searchResponse.pagination.totalCount} files matching "report"');
```

### Batch Operations

```dart
// Upload multiple files
final filePaths = ['/path/file1.pdf', '/path/file2.jpg', '/path/file3.txt'];

for (final filePath in filePaths) {
  try {
    final response = await client.uploadFile(123, filePath);
    if (response.success) {
      print('Uploaded: ${response.file?.fileName}');
    }
  } catch (e) {
    print('Failed to upload $filePath: $e');
  }
}

// Download all files in a bucket
final filesResponse = await client.listFiles(123, limit: 100);
for (final file in filesResponse.files) {
  await client.downloadFileToDirectory(file, '/downloads');
  print('Downloaded: ${file.fileName}');
}
```

## Error Handling

The library provides comprehensive error handling with specific exception types:

- `StorageBucketException.unauthorized()` - Invalid API credentials (401)
- `StorageBucketException.forbidden()` - Insufficient permissions (403)
- `StorageBucketException.notFound()` - Resource not found (404)
- `StorageBucketException.rateLimitExceeded()` - Rate limit exceeded (429)
- `StorageBucketException.serverError()` - Server error (5xx)
- `StorageBucketException.networkError()` - Network connectivity issues
- `StorageBucketException.validationError()` - Invalid parameters (400)

## Rate Limits

The API has the following rate limits:
- 1,000 requests per hour per API key
- 10,000 requests per day per API key

When rate limits are exceeded, a `StorageBucketException` with status code 429 will be thrown.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This library is released under the MIT License. See LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Check the API documentation
- Review the example code

## API Compatibility

This library is compatible with the Storage Bucket API v1. For API documentation, see the server's API documentation at `/api/v1/docs`. 