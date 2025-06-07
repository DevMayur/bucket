# 🔧 API Configuration Setup Guide

This guide explains how to configure your API credentials for the Storage Bucket Flutter demo app.

## 📁 Files Overview

- `lib/config/constants.dart` - Default constants and environment configurations
- `lib/config/constants_local.dart.template` - Template for your real credentials
- `lib/config/constants_local.dart` - Your actual credentials (gitignored)

## 🚀 Quick Setup

### 1. Copy the Template

```bash
cd lib/config
cp constants_local.dart.template constants_local.dart
```

### 2. Edit Your Credentials

Open `lib/config/constants_local.dart` and replace the placeholder values:

```dart
class LocalApiConstants {
  // 🔑 Your Real API Credentials
  static const String apiKey = 'sk_live_your_actual_api_key';
  static const String apiSecret = 'your_actual_api_secret';
  static const String baseUrl = 'https://dnyantra-cloud.in';
  static const String bucketId = '123'; // Your actual bucket ID
  
  // ... rest of the file
}
```

### 3. Enable Local Constants in main.dart

Uncomment this line in `lib/main.dart`:

```dart
// import 'config/constants_local.dart';
```

Change it to:

```dart
import 'config/constants_local.dart';
```

### 4. Use Local Constants

Update the `_loadDefaultConfiguration()` method in `main.dart`:

```dart
void _loadDefaultConfiguration() {
  // Use your local configuration
  final config = LocalApiConstants.currentConfig;
  
  _apiKeyController.text = config.apiKey;
  _apiSecretController.text = config.apiSecret;
  _baseUrlController.text = config.baseUrl;
  _bucketIdController.text = config.bucketId;
}
```

## 🌍 Environment Configurations

The app includes three pre-configured environments:

### Development
- For local testing
- Usually points to `http://localhost:8000`
- Uses test credentials

### Staging  
- For testing before production
- Points to staging server
- Uses staging credentials

### Production
- For live application
- Points to production server
- Uses production credentials

## 🔄 Switching Environments

### Method 1: Using the Dropdown (UI)
1. Open the app
2. In the "API Configuration" section
3. Select environment from the dropdown
4. Credentials will auto-populate

### Method 2: Programmatically (Code)
```dart
// In constants_local.dart
static const String currentEnvironment = 'production'; // or 'development', 'staging'

static ApiConfig get currentConfig {
  return ApiConstants.getEnvironment(currentEnvironment);
}
```

### Method 3: Custom Configuration
```dart
// In constants_local.dart
static ApiConfig get currentConfig {
  return const ApiConfig(
    name: 'My Custom Config',
    apiKey: 'sk_your_key',
    apiSecret: 'your_secret',
    baseUrl: 'https://your-custom-domain.com',
    bucketId: '456',
  );
}
```

## 🔒 Security Best Practices

### ✅ Do This:
- ✅ Use `constants_local.dart` for real credentials
- ✅ Keep real API keys secret
- ✅ Use environment-specific configurations
- ✅ Validate API keys before using them
- ✅ Use different keys for dev/staging/production

### ❌ Don't Do This:
- ❌ Never commit real credentials to git
- ❌ Don't hardcode production keys in the main constants file
- ❌ Don't share API secrets in plain text
- ❌ Don't use production keys for development

## 🧪 Testing Your Configuration

### 1. Validation Check
The app automatically validates:
- API key format (must start with 'sk_')
- Base URL format (must be valid HTTP/HTTPS)
- All required fields are filled

### 2. Connection Test
1. Fill in your credentials
2. Click "Connect"
3. The app will test the connection
4. If successful, you can start using the API

### 3. Manual Testing
You can test your API manually:

```bash
curl -H "Authorization: Bearer sk_your_key:your_secret" \
     -H "Content-Type: application/json" \
     "https://your-server.com/api/v1/files.php?bucket_id=1&limit=1"
```

## 🔧 Troubleshooting

### Common Issues:

1. **Import Error**: Make sure you've created `constants_local.dart` and uncommented the import
2. **Invalid API Key**: Ensure your API key starts with 'sk_'
3. **Connection Failed**: Check your base URL and network connection
4. **CORS Error**: See the CORS setup guide for web deployment

### Environment Issues:

1. **Wrong Environment**: Double-check the environment dropdown selection
2. **Outdated Config**: Delete and recreate `constants_local.dart` from the template
3. **Mixed Credentials**: Ensure you're not mixing dev/staging/prod credentials

## 📝 Example Configurations

### Development Setup
```dart
static const ApiConfig developmentConfig = ApiConfig(
  name: 'Local Development',
  apiKey: 'sk_dev_test_key',
  apiSecret: 'dev_test_secret',
  baseUrl: 'http://localhost:8000',
  bucketId: '1',
);
```

### Production Setup
```dart
static const ApiConfig productionConfig = ApiConfig(
  name: 'Production',
  apiKey: 'sk_live_real_key_here',
  apiSecret: 'real_secret_here',
  baseUrl: 'https://dnyantra-cloud.in',
  bucketId: '123',
);
```

---

## 🎯 Next Steps

After setting up your constants:

1. ✅ Test the connection
2. ✅ Try uploading a file  
3. ✅ List your files
4. ✅ Download and delete files
5. ✅ Handle any CORS issues (see CORS_SETUP_GUIDE.md)

Your Flutter Storage Bucket SDK is now ready for use! 🚀 