/// Configuration constants for Storage Bucket API
/// 
/// ⚠️ IMPORTANT: Never commit real API credentials to version control!
/// Copy this file to constants_local.dart and add your real credentials there.
class ApiConstants {
  // API Configuration
  static const String apiKey = 'sk_780b15880c65e3ecde5912654fabb9dc59c8ad5ff82e76db';
  static const String apiSecret = 'a429b1224a710fc763f7d38a55cd38376d02b8083133bfbc148308482583a614';
  static const String baseUrl = 'https://dnyantra-cloud.in';
  static const String bucketId = '1';
  
  // API Endpoints (automatically constructed)
  static String get apiBaseUrl => '$baseUrl/api/v1';
  static String get uploadEndpoint => '$apiBaseUrl/upload.php';
  static String get filesEndpoint => '$apiBaseUrl/files.php';
  static String get downloadEndpoint => '$apiBaseUrl/download.php';
  static String get deleteEndpoint => '$apiBaseUrl/delete.php';
  
  // App Configuration
  static const String appName = 'Storage Bucket Demo';
  static const String appVersion = '1.0.0';
  
  // Default Settings
  static const int defaultFilesPerPage = 20;
  static const int maxFilesPerPage = 100;
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  // File Upload Settings
  static const int maxFileSize = 100 * 1024 * 1024; // 100 MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];
  
  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
  ];
  
  // Development/Test Configurations
  static const Map<String, ApiConfig> environments = {
    'development': ApiConfig(
      name: 'Development',
      apiKey: 'sk_dev_test_key',
      apiSecret: 'dev_test_secret',
      baseUrl: 'http://localhost:8000',
      bucketId: '1',
    ),
    'staging': ApiConfig(
      name: 'Staging',
      apiKey: 'sk_staging_key',
      apiSecret: 'staging_secret',
      baseUrl: 'https://staging.dnyantra-cloud.in',
      bucketId: '1',
    ),
    'production': ApiConfig(
      name: 'Production (https://dnyantra-cloud.in)',
      apiKey: apiKey,
      apiSecret: apiSecret,
      baseUrl: baseUrl,
      bucketId: bucketId,
    ),
  };
  
  // Get environment configuration
  static ApiConfig getEnvironment(String env) {
    return environments[env] ?? environments['development']!;
  }
  
  // Validation helpers
  static bool isValidApiKey(String key) {
    return key.isNotEmpty && key.startsWith('sk_');
  }
  
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

/// API Configuration model
class ApiConfig {
  final String name;
  final String apiKey;
  final String apiSecret;
  final String baseUrl;
  final String bucketId;
  
  const ApiConfig({
    required this.name,
    required this.apiKey,
    required this.apiSecret,
    required this.baseUrl,
    required this.bucketId,
  });
  
  String get apiBaseUrl => '$baseUrl/api/v1';
  
  bool get isValid => 
    ApiConstants.isValidApiKey(apiKey) &&
    apiSecret.isNotEmpty &&
    ApiConstants.isValidUrl(baseUrl) &&
    bucketId.isNotEmpty;
  
  @override
  String toString() => 'ApiConfig($name)';
} 