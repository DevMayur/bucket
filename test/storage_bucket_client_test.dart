import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_storage_bucket/flutter_storage_bucket.dart';

void main() {
  group('ApiCredentials', () {
    test('should create valid credentials', () {
      final credentials = ApiCredentials(
        apiKey: 'sk_test_key',
        apiSecret: 'test_secret',
        baseUrl: 'https://test.com',
      );

      expect(credentials.isValid, isTrue);
      expect(credentials.authorizationHeader, equals('Bearer sk_test_key:test_secret'));
    });

    test('should validate API key format', () {
      final invalidCredentials = ApiCredentials(
        apiKey: 'invalid_key', // doesn't start with 'sk_'
        apiSecret: 'test_secret',
        baseUrl: 'https://test.com',
      );

      expect(invalidCredentials.isValid, isFalse);
    });

    test('should handle empty values', () {
      final emptyCredentials = ApiCredentials(
        apiKey: '',
        apiSecret: '',
        baseUrl: '',
      );

      expect(emptyCredentials.isValid, isFalse);
    });
  });

  group('FileUtils', () {
    test('should get file name from path', () {
      expect(FileUtils.getFileName('/path/to/file.pdf'), equals('file.pdf'));
      expect(FileUtils.getFileName('file.pdf'), equals('file.pdf'));
    });

    test('should get file extension', () {
      expect(FileUtils.getFileExtension('/path/to/file.pdf'), equals('.pdf'));
      expect(FileUtils.getFileExtension('image.jpg'), equals('.jpg'));
    });

    test('should get file name without extension', () {
      expect(FileUtils.getFileNameWithoutExtension('/path/to/file.pdf'), equals('file'));
    });

    test('should format file size correctly', () {
      expect(FileUtils.formatFileSize(1024), equals('1 KB'));
      expect(FileUtils.formatFileSize(1024 * 1024), equals('1 MB'));
      expect(FileUtils.formatFileSize(1536), equals('1.5 KB'));
    });

    test('should detect file types', () {
      expect(FileUtils.isImage('image.jpg'), isTrue);
      expect(FileUtils.isImage('document.pdf'), isFalse);
      
      expect(FileUtils.isDocument('document.pdf'), isTrue);
      expect(FileUtils.isDocument('image.jpg'), isFalse);
    });

    test('should sanitize file names', () {
      expect(
        FileUtils.sanitizeFileName('file<name>with:invalid|chars*.txt'),
        equals('file_name_with_invalid_chars_.txt'),
      );
      
      expect(FileUtils.sanitizeFileName(''), equals('unnamed_file'));
    });

    test('should validate allowed file types', () {
      final allowedTypes = ['image/', 'application/pdf'];
      
      expect(FileUtils.isAllowedFileType('image.jpg', allowedTypes), isTrue);
      expect(FileUtils.isAllowedFileType('document.pdf', allowedTypes), isTrue);
      expect(FileUtils.isAllowedFileType('video.mp4', allowedTypes), isFalse);
    });
  });

  group('BucketFile', () {
    test('should create from JSON', () {
      final json = {
        'id': 123,
        'file_name': 'test.pdf',
        'file_size': 1024000,
        'mime_type': 'application/pdf',
        'uploaded_at': '2024-01-01T12:00:00Z',
        'bucket_id': 456,
        'bucket_name': 'Test Bucket',
        'project_name': 'Test Project',
      };

      final file = BucketFile.fromJson(json);

      expect(file.id, equals(123));
      expect(file.fileName, equals('test.pdf'));
      expect(file.fileSize, equals(1024000));
      expect(file.mimeType, equals('application/pdf'));
      expect(file.bucketId, equals(456));
      expect(file.bucketName, equals('Test Bucket'));
      expect(file.projectName, equals('Test Project'));
      expect(file.isDocument, isTrue);
      expect(file.isImage, isFalse);
    });

    test('should format file size correctly', () {
      final file = BucketFile(
        id: 1,
        fileName: 'test.pdf',
        fileSize: 1024 * 1024, // 1 MB
        mimeType: 'application/pdf',
        uploadedAt: DateTime.now(),
        bucketId: 1,
      );

      expect(file.humanReadableSize, equals('1 MB'));
    });
  });

  group('StorageBucketException', () {
    test('should create different exception types', () {
      final unauthorizedException = StorageBucketException.unauthorized();
      expect(unauthorizedException.statusCode, equals(401));
      expect(unauthorizedException.message, equals('Invalid API credentials'));

      final notFoundException = StorageBucketException.notFound('File not found');
      expect(notFoundException.statusCode, equals(404));
      expect(notFoundException.message, equals('File not found'));

      final validationException = StorageBucketException.validationError('Invalid input');
      expect(validationException.statusCode, equals(400));
      expect(validationException.message, equals('Invalid input'));
    });

    test('should format toString correctly', () {
      final exception = StorageBucketException.unauthorized('Custom message');
      expect(exception.toString(), equals('StorageBucketException (401): Custom message'));

      final networkException = StorageBucketException.networkError('Network error');
      expect(networkException.toString(), equals('StorageBucketException: Network error'));
    });
  });

  group('StorageBucketClient', () {
    test('should throw exception for invalid credentials', () {
      final invalidCredentials = ApiCredentials(
        apiKey: 'invalid',
        apiSecret: 'secret',
        baseUrl: 'https://test.com',
      );

      expect(
        () => StorageBucketClient(invalidCredentials),
        throwsA(isA<StorageBucketException>()),
      );
    });

    test('should create client with valid credentials', () {
      final validCredentials = ApiCredentials(
        apiKey: 'sk_test_key',
        apiSecret: 'test_secret',
        baseUrl: 'https://test.com',
      );

      expect(() => StorageBucketClient(validCredentials), returnsNormally);
    });
  });
} 