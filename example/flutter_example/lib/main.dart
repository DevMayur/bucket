import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_storage_bucket/flutter_storage_bucket.dart';

// Import constants
import 'config/constants.dart';

// Try to import local constants if available
// If you have created constants_local.dart, uncomment the next line
// import 'config/constants_local.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ApiConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StorageBucketDemo(),
    );
  }
}

class StorageBucketDemo extends StatefulWidget {
  const StorageBucketDemo({super.key});

  @override
  State<StorageBucketDemo> createState() => _StorageBucketDemoState();
}

class _StorageBucketDemoState extends State<StorageBucketDemo> {
  late StorageBucketClient _client;
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _apiSecretController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _bucketIdController = TextEditingController();
  
  List<BucketFile> _files = [];
  bool _isLoading = false;
  String? _statusMessage;
  double _uploadProgress = 0.0;
  double _downloadProgress = 0.0;
  bool _isConnected = false;
  String _selectedEnvironment = 'production';

  @override
  void initState() {
    super.initState();
    _loadDefaultConfiguration();
  }

  void _loadDefaultConfiguration() {
    // Load default configuration from constants
    // If you have constants_local.dart, you can use:
    // final config = LocalApiConstants.currentConfig;
    
    // For now, use the default constants or environment
    final config = ApiConstants.getEnvironment(_selectedEnvironment);
    
    _apiKeyController.text = config.apiKey;
    _apiSecretController.text = config.apiSecret;
    _baseUrlController.text = config.baseUrl;
    _bucketIdController.text = config.bucketId;
    
    // Show a helpful message about configuration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMessage(
        '📝 Using ${config.name} configuration. Update credentials below or create constants_local.dart for your real API keys.',
        isError: false,
      );
    });
  }

  void _switchEnvironment(String environment) {
    setState(() {
      _selectedEnvironment = environment;
    });
    
    final config = ApiConstants.getEnvironment(environment);
    _apiKeyController.text = config.apiKey;
    _apiSecretController.text = config.apiSecret;
    _baseUrlController.text = config.baseUrl;
    _bucketIdController.text = config.bucketId;
    
    _showMessage('Switched to ${config.name} environment');
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    _baseUrlController.dispose();
    _bucketIdController.dispose();
    if (_isConnected) {
      _client.close();
    }
    super.dispose();
  }

  void _connectToAPI() {
    if (_apiKeyController.text.isEmpty || 
        _apiSecretController.text.isEmpty || 
        _baseUrlController.text.isEmpty) {
      _showMessage('Please fill in all API credentials', isError: true);
      return;
    }

    try {
      final credentials = ApiCredentials(
        apiKey: _apiKeyController.text.trim(),
        apiSecret: _apiSecretController.text.trim(),
        baseUrl: _baseUrlController.text.trim(),
      );

      _client = StorageBucketClient(credentials);
      
      // Test the connection first
      _testConnection();
    } catch (e) {
      _showMessage('Failed to connect: $e', isError: true);
    }
  }

  Future<void> _testConnection() async {
    _showMessage('Testing connection...');
    
    try {
      final isConnected = await _client.testConnection();
      if (isConnected) {
        _isConnected = true;
        _showMessage('✅ Connected to API successfully!');
        setState(() {});
      }
    } catch (e) {
      _isConnected = false;
      setState(() {});
      
      if (e is StorageBucketException && e.message.contains('CORS')) {
        _showCorsErrorDialog(e.message);
      } else {
        _showMessage('Connection failed: $e', isError: true);
      }
    }
  }

  void _showCorsErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('CORS Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            const SizedBox(height: 16),
            const Text(
              'To fix this issue:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Configure CORS headers on your server'),
            const Text('2. Use Flutter mobile/desktop instead of web'),
            const Text('3. Contact your API administrator'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Server CORS Headers Needed:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Access-Control-Allow-Origin: *\n'
                    'Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS\n'
                    'Access-Control-Allow-Headers: Authorization, Content-Type',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCorsFixInstructions();
            },
            child: const Text('Show Fix Instructions'),
          ),
        ],
      ),
    );
  }

  void _showCorsFixInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Fix CORS'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add these headers to your PHP API files:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '<?php\n'
                  '// Add at the top of your PHP files\n'
                  'header("Access-Control-Allow-Origin: *");\n'
                  'header("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");\n'
                  'header("Access-Control-Allow-Headers: Authorization, Content-Type");\n'
                  '\n'
                  '// Handle preflight requests\n'
                  'if (\$_SERVER[\'REQUEST_METHOD\'] === \'OPTIONS\') {\n'
                  '    http_response_code(200);\n'
                  '    exit();\n'
                  '}\n'
                  '?>',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Alternative Solutions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Use Flutter mobile/desktop app instead of web'),
              const Text('• Set up a proxy server'),
              const Text('• Configure your web server (Apache/Nginx) for CORS'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _disconnect() {
    if (_isConnected) {
      _client.close();
      _isConnected = false;
      _files.clear();
      setState(() {});
      _showMessage('Disconnected from API');
    }
  }

  Future<void> _listFiles() async {
    if (!_isConnected || _bucketIdController.text.isEmpty) {
      _showMessage('Please connect to API and specify bucket ID', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bucketId = int.parse(_bucketIdController.text);
      final response = await _client.listFiles(bucketId, limit: 50);
      
      if (response.success) {
        setState(() {
          _files = response.files;
        });
        _showMessage('Loaded ${_files.length} files');
      } else {
        _showMessage('Failed to list files: ${response.message}', isError: true);
      }
    } catch (e) {
      _showMessage('Error listing files: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadFile() async {
    if (!_isConnected || _bucketIdController.text.isEmpty) {
      _showMessage('Please connect to API and specify bucket ID', isError: true);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bucketId = int.parse(_bucketIdController.text);
        
        setState(() {
          _uploadProgress = 0.0;
        });

        final response = await _client.uploadFile(
          bucketId,
          file.path,
          onUploadProgress: (sent, total) {
            setState(() {
              _uploadProgress = sent / total;
            });
          },
        );

        if (response.success) {
          _showMessage('File uploaded successfully: ${response.file?.fileName}');
          _listFiles(); // Refresh the file list
        } else {
          _showMessage('Upload failed: ${response.message}', isError: true);
        }
        
        setState(() {
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      _showMessage('Error uploading file: $e', isError: true);
      setState(() {
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _downloadFile(BucketFile file) async {
    if (!_isConnected) {
      _showMessage('Please connect to API', isError: true);
      return;
    }

    try {
      setState(() {
        _downloadProgress = 0.0;
      });

      // For demo purposes, we'll just download to bytes
      // In a real app, you might want to save to a specific directory
      final bytes = await _client.downloadFile(
        file.id,
        onDownloadProgress: (received, total) {
          setState(() {
            _downloadProgress = received / total;
          });
        },
      );

      if (bytes != null) {
        _showMessage('Downloaded ${file.fileName} (${bytes.length} bytes)');
      }
      
      setState(() {
        _downloadProgress = 0.0;
      });
    } catch (e) {
      _showMessage('Error downloading file: $e', isError: true);
      setState(() {
        _downloadProgress = 0.0;
      });
    }
  }

  Future<void> _deleteFile(BucketFile file) async {
    if (!_isConnected) {
      _showMessage('Please connect to API', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${file.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _client.deleteFile(file.id);
        
        if (response.success) {
          _showMessage('File deleted: ${file.fileName}');
          _listFiles(); // Refresh the file list
        } else {
          _showMessage('Delete failed: ${response.message}', isError: true);
        }
      } catch (e) {
        _showMessage('Error deleting file: $e', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Bucket Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Configuration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'API Configuration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Environment Selector
                    Row(
                      children: [
                        const Text('Environment: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedEnvironment,
                            isExpanded: true,
                            items: ApiConstants.environments.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text('${entry.value.name} (${entry.value.baseUrl})'),
                              );
                            }).toList(),
                            onChanged: _isConnected ? null : (value) {
                              if (value != null) _switchEnvironment(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: 'sk_your_api_key_here',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apiSecretController,
                      decoration: const InputDecoration(
                        labelText: 'API Secret',
                        hintText: 'your_api_secret_here',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        hintText: 'https://your-server.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bucketIdController,
                      decoration: const InputDecoration(
                        labelText: 'Bucket ID',
                        hintText: '123',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    
                    // Configuration Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Configuration Help',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Copy constants_local.dart.template to constants_local.dart\n'
                            '• Add your real API credentials to constants_local.dart\n'
                            '• The local file is gitignored for security',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isConnected ? null : _connectToAPI,
                            child: const Text('Connect'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isConnected ? _disconnect : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Disconnect'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // File Operations Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'File Operations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isConnected ? _listFiles : null,
                            icon: const Icon(Icons.refresh),
                            label: const Text('List Files'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isConnected ? _pickAndUploadFile : null,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload File'),
                          ),
                        ),
                      ],
                    ),
                    
                    // Progress indicators
                    if (_uploadProgress > 0) ...[
                      const SizedBox(height: 8),
                      Text('Upload Progress: ${(_uploadProgress * 100).toStringAsFixed(1)}%'),
                      LinearProgressIndicator(value: _uploadProgress),
                    ],
                    
                    if (_downloadProgress > 0) ...[
                      const SizedBox(height: 8),
                      Text('Download Progress: ${(_downloadProgress * 100).toStringAsFixed(1)}%'),
                      LinearProgressIndicator(value: _downloadProgress),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Message
            if (_statusMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Files List
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Files (${_files.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _files.isEmpty
                              ? const Center(
                                  child: Text('No files found. Connect to API and refresh to see files.'),
                                )
                              : ListView.builder(
                                  itemCount: _files.length,
                                  itemBuilder: (context, index) {
                                    final file = _files[index];
                                    return ListTile(
                                      leading: Icon(_getFileIcon(file)),
                                      title: Text(file.fileName),
                                      subtitle: Text(
                                        '${file.humanReadableSize} • ${file.mimeType}\n'
                                        'Uploaded: ${file.uploadedAt.toLocal().toString().split('.')[0]}',
                                      ),
                                      isThreeLine: true,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () => _downloadFile(file),
                                            icon: const Icon(Icons.download),
                                            tooltip: 'Download',
                                          ),
                                          IconButton(
                                            onPressed: () => _deleteFile(file),
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(BucketFile file) {
    if (file.isImage) return Icons.image;
    if (file.isVideo) return Icons.video_file;
    if (file.isAudio) return Icons.audio_file;
    if (file.isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }
} 