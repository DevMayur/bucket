# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added
- Initial release of Flutter Storage Bucket library
- `StorageBucketClient` for API interactions
- File upload functionality with progress tracking
- File download with progress tracking and save options
- File listing with pagination, search, and filtering
- File deletion capabilities
- `ApiCredentials` model for authentication
- `BucketFile` model with utility methods
- Response models for all API operations
- `FileUtils` class with helpful file operations
- Custom exception handling with `StorageBucketException`
- Comprehensive error handling for different HTTP status codes
- Support for uploading from file paths and bytes
- MIME type detection and validation
- File name sanitization utilities
- Full null safety support
- Comprehensive documentation and examples
- Unit tests for core functionality

### Features
- ✅ Upload files from file paths or bytes
- ✅ Download files to disk or memory
- ✅ List files with pagination and filtering
- ✅ Delete files by ID
- ✅ Progress tracking for uploads and downloads
- ✅ File type detection and validation
- ✅ Custom exception handling
- ✅ File utilities for common operations
- ✅ Full async/await support
- ✅ Type-safe API with null safety

### API Endpoints Supported
- `POST /api/v1/upload.php` - File upload
- `GET /api/v1/files.php` - List files
- `GET /api/v1/download.php` - Download files
- `DELETE /api/v1/delete.php` - Delete files

### Dependencies
- `dio: ^5.3.2` - HTTP client
- `mime: ^1.0.4` - MIME type detection
- `path: ^1.8.3` - Path manipulation
- `crypto: ^3.0.3` - Cryptographic operations 