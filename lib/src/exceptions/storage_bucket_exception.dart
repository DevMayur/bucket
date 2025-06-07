/// Custom exception for Storage Bucket operations
class StorageBucketException implements Exception {
  /// Creates a new StorageBucketException with the given message
  const StorageBucketException(this.message, {this.statusCode, this.originalError});

  /// Creates a network error exception
  factory StorageBucketException.networkError(String message) {
    return StorageBucketException('Network Error: $message');
  }

  /// Creates a validation error exception
  factory StorageBucketException.validationError(String message) {
    return StorageBucketException('Validation Error: $message', statusCode: 400);
  }

  /// Creates an unauthorized error exception
  factory StorageBucketException.unauthorized(String message) {
    return StorageBucketException('Unauthorized: $message', statusCode: 401);
  }

  /// Creates a forbidden error exception
  factory StorageBucketException.forbidden(String message) {
    return StorageBucketException('Forbidden: $message', statusCode: 403);
  }

  /// Creates a not found error exception
  factory StorageBucketException.notFound(String message) {
    return StorageBucketException('Not Found: $message', statusCode: 404);
  }

  /// Creates a rate limit exceeded error exception
  factory StorageBucketException.rateLimitExceeded(String message) {
    return StorageBucketException('Rate Limit Exceeded: $message', statusCode: 429);
  }

  /// Creates a server error exception
  factory StorageBucketException.serverError(String message) {
    return StorageBucketException('Server Error: $message', statusCode: 500);
  }

  /// Creates a CORS error exception
  factory StorageBucketException.corsError(String message) {
    return StorageBucketException('CORS Error: $message');
  }

  final String message;
  final int? statusCode;
  final dynamic originalError;

  @override
  String toString() {
    final statusText = statusCode != null ? ' (Status: $statusCode)' : '';
    return 'StorageBucketException: $message$statusText';
  }
} 