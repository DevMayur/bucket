/// Represents API credentials for storage bucket authentication
class ApiCredentials {
  /// The API key (starts with 'sk_')
  final String apiKey;
  
  /// The API secret
  final String apiSecret;
  
  /// Base URL for the storage bucket API
  final String baseUrl;

  const ApiCredentials({
    required this.apiKey,
    required this.apiSecret,
    required this.baseUrl,
  });

  /// Returns the authorization header value
  String get authorizationHeader => 'Bearer $apiKey:$apiSecret';

  /// Validates that the API key has the correct format
  bool get isValid {
    return apiKey.isNotEmpty && 
           apiSecret.isNotEmpty && 
           baseUrl.isNotEmpty &&
           apiKey.startsWith('sk_');
  }

  @override
  String toString() {
    return 'ApiCredentials(apiKey: ${apiKey.substring(0, 10)}..., baseUrl: $baseUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiCredentials &&
           other.apiKey == apiKey &&
           other.apiSecret == apiSecret &&
           other.baseUrl == baseUrl;
  }

  @override
  int get hashCode => Object.hash(apiKey, apiSecret, baseUrl);
} 