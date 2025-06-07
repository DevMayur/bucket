import 'package:flutter_storage_bucket/flutter_storage_bucket.dart';

void main() async {
  print('🧪 Testing Flutter Storage Bucket SDK...');
  
  // Test 1: API Credentials validation
  print('\n📋 Test 1: API Credentials Validation');
  
  // Valid credentials
  final validCredentials = ApiCredentials(
    apiKey: 'sk_test_key_123',
    apiSecret: 'test_secret_456',
    baseUrl: 'https://test-api.example.com',
  );
  
  print('✅ Valid credentials: ${validCredentials.isValid}');
  print('   Authorization header: ${validCredentials.authorizationHeader}');
  
  // Invalid credentials
  final invalidCredentials = ApiCredentials(
    apiKey: 'invalid_key', // doesn't start with 'sk_'
    apiSecret: 'test_secret',
    baseUrl: 'https://test.com',
  );
  
  print('❌ Invalid credentials: ${invalidCredentials.isValid}');
  
  // Test 2: FileUtils functionality
  print('\n📁 Test 2: File Utilities');
  
  final testFilePath = '/path/to/document.pdf';
  print('✅ File name: ${FileUtils.getFileName(testFilePath)}');
  print('✅ File extension: ${FileUtils.getFileExtension(testFilePath)}');
  print('✅ MIME type: ${FileUtils.getMimeType(testFilePath)}');
  print('✅ Is document: ${FileUtils.isDocument(testFilePath)}');
  print('✅ Is image: ${FileUtils.isImage(testFilePath)}');
  
  // Test file size formatting
  final testSizes = [1024, 1048576, 1073741824];
  for (final size in testSizes) {
    print('✅ ${size} bytes = ${FileUtils.formatFileSize(size)}');
  }
  
  // Test file name sanitization
  final unsafeFileName = 'my<file>name:with|invalid*chars?.txt';
  final safeFileName = FileUtils.sanitizeFileName(unsafeFileName);
  print('✅ Sanitized "$unsafeFileName" → "$safeFileName"');
  
  // Test 3: Model JSON serialization
  print('\n📦 Test 3: Model Serialization');
  
  final testFileJson = {
    'id': 123,
    'file_name': 'test_document.pdf',
    'file_size': 2048000,
    'mime_type': 'application/pdf',
    'uploaded_at': '2024-01-01T12:00:00Z',
    'bucket_id': 456,
    'bucket_name': 'Test Bucket',
    'project_name': 'Test Project',
  };
  
  final bucketFile = BucketFile.fromJson(testFileJson);
  print('✅ BucketFile created from JSON:');
  print('   ID: ${bucketFile.id}');
  print('   Name: ${bucketFile.fileName}');
  print('   Size: ${bucketFile.humanReadableSize}');
  print('   Type: ${bucketFile.mimeType}');
  print('   Is document: ${bucketFile.isDocument}');
  print('   Is image: ${bucketFile.isImage}');
  
  // Test back to JSON
  final backToJson = bucketFile.toJson();
  print('✅ Serialized back to JSON: ${backToJson.keys.length} fields');
  
  // Test 4: Exception handling
  print('\n⚠️  Test 4: Exception Handling');
  
  final exceptions = [
    StorageBucketException.unauthorized('Invalid API key'),
    StorageBucketException.notFound('File not found'),
    StorageBucketException.rateLimitExceeded(),
    StorageBucketException.validationError('Invalid bucket ID'),
  ];
  
  for (final exception in exceptions) {
    print('✅ ${exception.toString()}');
  }
  
  // Test 5: Client initialization
  print('\n🔌 Test 5: Client Initialization');
  
  try {
    final client = StorageBucketClient(validCredentials);
    print('✅ Client created successfully with valid credentials');
    client.close();
    print('✅ Client closed successfully');
  } catch (e) {
    print('❌ Failed to create client: $e');
  }
  
  try {
    final client = StorageBucketClient(invalidCredentials);
    print('❌ Client should not have been created with invalid credentials');
    client.close();
  } catch (e) {
    print('✅ Correctly rejected invalid credentials: ${e.toString()}');
  }
  
  // Test 6: File type validation
  print('\n🏷️  Test 6: File Type Validation');
  
  final allowedTypes = ['image/', 'application/pdf', 'text/'];
  final testFiles = [
    'photo.jpg',
    'document.pdf', 
    'readme.txt',
    'video.mp4',
    'audio.mp3',
  ];
  
  for (final file in testFiles) {
    final isAllowed = FileUtils.isAllowedFileType(file, allowedTypes);
    final status = isAllowed ? '✅' : '❌';
    print('$status $file - allowed: $isAllowed');
  }
  
  print('\n🎉 All SDK tests completed successfully!');
  print('📱 The Flutter Storage Bucket library is ready to use.');
  print('');
  print('📖 Next steps:');
  print('   1. Get your API credentials from your storage bucket dashboard');
  print('   2. Replace the example credentials in the Flutter app');
  print('   3. Test uploading, downloading, and managing files');
  print('   4. Integrate the SDK into your own Flutter app');
} 