import 'dart:io';
import 'package:flutter_storage_bucket/flutter_storage_bucket.dart';

void main() async {
  // Initialize the storage bucket client
  final credentials = ApiCredentials(
    apiKey: 'sk_your_api_key_here',
    apiSecret: 'your_api_secret_here',
    baseUrl: 'https://your-server.com',
  );

  final client = StorageBucketClient(credentials);

  try {
    // Example 1: Upload a file
    print('Uploading file...');
    final uploadResponse = await client.uploadFile(
      123, // bucket ID
      '/path/to/your/file.pdf',
      onUploadProgress: (sent, total) {
        final progress = (sent / total * 100).toStringAsFixed(1);
        print('Upload progress: $progress%');
      },
    );

    if (uploadResponse.success) {
      print('File uploaded successfully!');
      print('File ID: ${uploadResponse.file?.id}');
      print('File name: ${uploadResponse.file?.fileName}');
      print('File size: ${uploadResponse.file?.humanReadableSize}');
    }

    // Example 2: Upload from bytes
    print('\nUploading from bytes...');
    final fileBytes = await File('/path/to/your/image.jpg').readAsBytes();
    final bytesUploadResponse = await client.uploadFileFromBytes(
      123, // bucket ID
      'uploaded_image.jpg',
      fileBytes,
      mimeType: 'image/jpeg',
    );

    if (bytesUploadResponse.success) {
      print('File uploaded from bytes successfully!');
    }

    // Example 3: List files with pagination
    print('\nListing files...');
    final filesResponse = await client.listFiles(
      123, // bucket ID
      page: 1,
      limit: 10,
      search: 'pdf', // search for PDF files
      mimeTypeFilter: 'application/', // filter by document types
    );

    if (filesResponse.success) {
      print('Found ${filesResponse.files.length} files');
      print('Total files: ${filesResponse.pagination.totalCount}');
      print('Current page: ${filesResponse.pagination.currentPage}/${filesResponse.pagination.totalPages}');
      
      for (final file in filesResponse.files) {
        print('- ${file.fileName} (${file.humanReadableSize}) - ${file.mimeType}');
        print('  Uploaded: ${file.uploadedAt}');
        print('  ID: ${file.id}');
      }
    }

    // Example 4: Download a file
    if (filesResponse.files.isNotEmpty) {
      final firstFile = filesResponse.files.first;
      print('\nDownloading file: ${firstFile.fileName}');
      
      // Download to bytes
      final fileBytes = await client.downloadFile(
        firstFile.id,
        onDownloadProgress: (received, total) {
          final progress = (received / total * 100).toStringAsFixed(1);
          print('Download progress: $progress%');
        },
      );

      if (fileBytes != null) {
        print('Downloaded ${fileBytes.length} bytes');
      }

      // Download to directory
      final savedPath = await client.downloadFileToDirectory(
        firstFile,
        '/path/to/downloads',
      );
      print('File saved to: $savedPath');
    }

    // Example 5: Delete a file
    if (filesResponse.files.isNotEmpty) {
      final fileToDelete = filesResponse.files.last;
      print('\nDeleting file: ${fileToDelete.fileName}');
      
      final deleteResponse = await client.deleteFile(fileToDelete.id);
      
      if (deleteResponse.success) {
        print('File deleted successfully!');
        print('Deleted: ${deleteResponse.deletedFile?.fileName}');
      }
    }

    // Example 6: Using file utilities
    print('\nFile utilities examples:');
    final filePath = '/path/to/your/document.pdf';
    
    print('File name: ${FileUtils.getFileName(filePath)}');
    print('File extension: ${FileUtils.getFileExtension(filePath)}');
    print('MIME type: ${FileUtils.getMimeType(filePath)}');
    print('Is document: ${FileUtils.isDocument(filePath)}');
    print('Is image: ${FileUtils.isImage(filePath)}');
    
    if (await FileUtils.fileExists(filePath)) {
      final size = await FileUtils.getFileSize(filePath);
      print('File size: ${FileUtils.formatFileSize(size)}');
    }

    // Example 7: File type validation
    final allowedTypes = ['image/', 'application/pdf'];
    if (FileUtils.isAllowedFileType(filePath, allowedTypes)) {
      print('File type is allowed');
    }

    // Example 8: Sanitize file name
    final unsafeFileName = 'my<file>name:with|invalid*chars?.txt';
    final safeFileName = FileUtils.sanitizeFileName(unsafeFileName);
    print('Sanitized file name: $safeFileName');

  } catch (e) {
    if (e is StorageBucketException) {
      print('Storage bucket error: ${e.message}');
      if (e.statusCode != null) {
        print('Status code: ${e.statusCode}');
      }
    } else {
      print('Unexpected error: $e');
    }
  } finally {
    // Always close the client to free resources
    client.close();
  }
} 